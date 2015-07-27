function [success, costs, collective, counters] = kmeans(X, Ks, points)
	disp('** Processing. This may take awhile')
	fflush(stdout);

	% Assume failure
	success = false;

	% Rows and cols for data
	[rows,cols] = size(X);

	% Our retrun values
	costs = [];
	collective = cell();
	counters = cell();

	% run k means for 3 - 10 ks
	for k = Ks

		disp(strcat('*** running:',num2str(k)))
		fflush(stdout);

		mcost = Inf;
		best  = zeros(k,cols);
		bestcount  = zeros(1,k);
		for q = 1:100

			% init random pos from data
			centroids = zeros(k, size(X, 2));
			choice = 1;
			copy = points;
			chosen = [];
			while choice <= k
				if size(copy,2) == 0
					disp('Not enough unique points to run this k')
					return;
				end
				cindex = floor(rand()*size(copy, 2)) + 1;
				index = copy(cindex);
				% delete to prevent collision
				copy([cindex]) = [];
				if !ismember(X(index,:), centroids, 'rows')
					centroids(choice,:) = X(index,:);
					choice = choice+1;
				end
			end

			cost     = 0;
			previous = zeros(k,cols);
			broke = false;

			while true
				if sum(sum(previous ~= centroids)) == 0
					break
				end
				previous = centroids;
				counter  = zeros(1,k);
				clusters = zeros(k,1);
	
				% assign to cluster
				for x = points

					% Should never happen
					% if x == 0

					index = 0;
					closest = Inf;
					for j = 1:k
						distance = norm(X(x,:) - centroids(j,:));
						if distance < closest
							index = j;
							closest = distance;
						end
					end
					counter(index) = counter(index) + 1;
					clusters(index,counter(index)) = x;
				end
	
				% set centroid
				for i = 1:k
					broke = broke || counter(i) == 0;
					avg = zeros(1,cols);
					for j = 1:counter(i)
						avg = avg + X(clusters(i,j),:);
					end
					centroids(i,:) = avg/counter(i);
				end

				if broke
					break
				end

			end

			if broke
				continue
			end
	
			% Compute cost
			for i = 1:k
				for j = 1:counter(i)
					cost = cost + norm(centroids(i,:) - X(clusters(i,j),:))^2;
				end
			end
	
			if cost < mcost
				mcost = cost;
				best = clusters;
				bestcount = counter;
			end
		end
		costs(k) = mcost;
		collective(k) = best;
		counters(k) = bestcount;
	end

	success = true;
end