% Context from process

more off;
addpath ('helpers');
addpath ('stucts');

disp('* Managing');
disp('Have previous data?');
disp('1. Nope. Restart');
disp('2. Load');
answer = prompt('What will it be?  ');
if answer == 1
	% Init from data in process
	head = tree(K,costs,collective,counters,true);
	root = head;

	disp('** K default to Lower Bound');
	K = LB;

	% Set auto to blank
	auto = Auto();
else
	load('.backup');
end
change  = false;

while true

	% print out tree
		% Menu
			% Sample
			% Name
			% Plot
			% Set K
			% Plot cost
			% Manage subgroup
			% Prune
			% Auto Cluster
			% Quit
	
	disp('');
	disp('---');
	[_, head, root] = recurse(root, '', zeros(1,0), root.path, change, head);
	change = true;
	disp('---');

	% Save, just in case
	save('-binary', '.backup'); 

	% Print out menu
	disp('Choose something to do');
	disp('1. Sample');
	disp('2. Name');
	disp('3. Plot');
	disp('4. Change K');
	disp('5. Plot cost');
	disp('6. Manage Subgroups');
	disp('7. Prune tree');
	disp('8. Auto Cluster');
	disp('9. Write and quit');
	decision = prompt('What will it be?  ', auto.decision)

	% Set values from head for convience
	K = head.K;
	clusters = cell2mat(head.collective(K));
	counter  = cell2mat(head.counters(K));
	cost = head.costs;

	% Find bounds
	lb = sum(cost == 0) + 1;
	ub = size(cost,2);

	% 1. Sample
	if decision == 1
		disp('Sample time:')
		sampled = zeros(K,1);
		while true
			c = prompt('* enter a cluster number, 0 to exit:');
			if c == 0
				break
			end
			if c <=K && c>0
				if counter(c) == sampled(c)
					disp('** group already iterated through');
				else
					sampled(c) = sampled(c) + 1;
					disp(quotes(clusters(c,sampled(c))));
					Xn(clusters(c,sampled(c)),:)
				end
			else
				disp('** Bad k')
			end
		end
		continue;
	end

	% 2. Name
	if decision == 2
		while true
			c = prompt('enter a cluster index to name, or 0 to exit:');
			if c == 0
				break
			else 
				if c < 0 || c > K
					disp('* Bad index');
				else
					head.names{c} = input(strcat('* New name for Cluster "',head.names{c},'":'),'s');
					% Sanitize for csv
					head.names{c} = regexprep(head.names{c}, '[-|,]', ';');
				end
			end
		end
		continue;
	end

	% 3. Plot in lower dimensions
	if decision == 3
		disp('Plotting...')
		%% make usable
		Sigma = (Xn'*Xn)/(rows-1);
		[U,S,V] = svd(Sigma);
		Z = Xn*U(:,1:3);
		hold on
		for i = 1:K
			x = (i-1)/(K-1);
			r = b = g = 0;
			if (1-4*x^2) > 0
				g = (1-4*x^2);
			end
			if (1-4*(x-1)^2) > 0
				b = (1-4*(x-1)^2);
			end
			colors = [4*(-x^2+x),g,b];
			for j = 1:sum(clusters(i,:) ~= 0)
				k = clusters(i,j);
				plot3(Z(k,1),Z(k,2),Z(k,3) ,'Marker','*','color',colors)
			end
		end
		continue;
	end

	% 4. Change K
	if decision == 4
		K = 0;

		% Show bounds
		if !auto.activated
			disp(strcat('Lower bound:', num2str(lb)));
			disp(strcat('Upper bound:', num2str(ub)));
		else
			auto.set   = false;
			auto.get   = true;
			auto.decision = 8;
		end

		while K < lb || K > ub
			K = prompt('Pick a new K size:',auto.K);
		end
		for i = 1:K
			head.names{i} = num2str(i);
		end
		change = true;
		head.K = K;
		head.branches = [];
		continue;
	end

	% 5. Cost Plot
	if decision == 5
		hold on
		scatter(sum(cost == 0)+1:size(cost,2),cost(sum(cost == 0)+1:end))
		continue;
	end

	% 6. Change subgroup
	if decision == 6

		next = prompt('Enter a cluster number, or 0 to go up a level:',auto.current);
		if next > K || next < 0
			disp('* Bad next');
			continue;
		end

		if next == 0
			if head.root
				disp('* Cant go any higher');
			else
				root.path = root.path(1:size(root.path,2) - 1);
				change = false;
				if auto.activated
					auto.decision = 8;
				end
			end
		else
			% Normally would just use pointer head, but octave doesn't do memory addresses 
			if size(head.branches,2) >= next && size(head.branches(next).K,1) > 0
				head = head.branches(next);
			else

				[ub,lb] = bound(auto);

				[success, costs_,collective_,counters_] = kmeans(Xn, lb:ub, clusters(next,1:counter(next)));
				if success
					disp('** K default to Lower Bound');
					head = tree(lb,costs_,collective_,counters_);
				else
					disp('** Woops. You might want to try again');
					if auto.activated
						% Need 3 points to work
						if auto.lb + 2 ~= auto.ub
							auto.ub = auto.ub - 1;
						else
							if !head.root
								auto.depth = auto.depth - 1;
								auto.count(auto.depth) = auto.count(auto.depth) + 1;
								auto.decision = 8;
							else
								auto = Auto();
							end
						end
					end
					continue;
				end
			end

			if auto.activated
				auto.set   = true;
				auto.get   = false;
				auto.decision = 8;
			end

			root.path(size(root.path,2) + 1) = next;
		end
		continue;
	end

	% 7. Prune
	if decision == 7
		next = prompt('Choose a sub cluster to kill:');
		if next > 0 && size(head.branches,2) >= next
			head.branches([next]) = [];
		else
			disp('* Cluster does not exist');
		end
		continue;
	end


	% 9. Auto Cluster
	if decision == 8
		if !auto.activated

			auto.threshold = prompt('Pick a threshold value:');
			[auto.UB,auto.LB] = bound();

			if auto.LB + 2 < auto.UB
				disp('Need a min of 3 distinct Ks');
				continue;
			end

			auto.activated = true;

			auto.depth = 1;
			auto.set   = true;
			auto.get   = false;
		end

		if auto.set
			auto.decision = 4;
			% Find optimal clustering
			maximize  = 0;
			for c = lb+1:ub-1
				temp = (cost(c-1) - cost(c))/(cost(c) + cost(c+1));
				if temp > maximize
					maximize = temp;
					auto.K = c;
				end
			end
		end

		if auto.get
			auto.decision = 6;
			auto.ub = auto.UB;
			auto.lb = auto.LB;

			chosen = false;
			k = auto.count(auto.depth);
			while k <= K
				% Refactor this to something nicer
				if !(size(head.branches,2) >= k ...
					&& size(head.branches(k).K,1) > 0 ...
					|| counter(k) < auto.threshold)
						auto.current = k;
						chosen = true;
						break;
				end
				k = k + 1;
			end
			if !chosen
				auto.depth = auto.depth - 1;
				if head.root
					% We're done!
					auto = Auto();
					continue;
				else
					auto.current = 0;
				end
				disp(strcat('Coming up to:', num2str(auto.depth)));
			else
				auto.count(auto.depth) = k + 1;
				auto.depth = auto.depth + 1;
				auto.count(auto.depth) = 1;
				disp(strcat('Diving to depth:', num2str(auto.depth)));
			end
		end
	end


	% Exit
	if decision == 9
		proceed = prompt('Unnamed clusters will be ignored. If you want to continue press 1:');
		if proceed == 1
			break
		end
	end
end

% Dump to csv
file = strcat(input('* Name this session:','s'),'.csv');
disp('** Dumping to csv');
fputs(fopen(file, 'w'), csvrecursion(root,''));
fclose(file);