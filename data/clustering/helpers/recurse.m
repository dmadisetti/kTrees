function [found, head, node] =  recurse(parent,depth,pathway,desired,change,current)

	if parent.root
		disp('Cluster Tree:');
	else
		disp(depth);
	end

	found = false;
	head  = 0;
	if change && size(desired,2) > 0 && size(desired(1:end - 1)) == size(pathway) && (pathway == desired(1:end - 1) || size(desired(1:end - 1)) == [1,0])
		if size(parent.branches,1) < desired(end) || size(parent.branches(desired(end)).K,1) == 0
			parent.branches(desired(end)) = current;
		end
	end

	if size(desired) == size(pathway) && (pathway == desired || size(desired) == [1,0])
		disp(strcat(depth,'* You are here'));
		if change
			parent = current;
		end
		head = parent;
		found = true;
	end

	% Spit out pathway
	if isempty(pathway)
		disp('* Root');
	else
		pathstring = strcat(depth,'Pathway');
		for p = pathway
			pathstring = strcat(pathstring,'->',num2str(p));
		end
		disp(pathstring);
	end

	% Spit out branches
	counter  = cell2mat(parent.counters(parent.K));
	for i = 1:parent.K
		% Depth first display to show tree
		disp(strcat(depth,'Cluster ', num2str(i) ,'->',parent.names{i},':',num2str(counter(i))));
	end

	depth = strcat(depth,'....');
	index = size(pathway,2) + 1;
	for i = 1:size(parent.branches,2)
		if size(parent.branches(i).K,1) > 0
			pathway(index) = i;
			[inside, temp, parent.branches(i)] = recurse(parent.branches(i),depth,pathway,desired,change,current);
			if inside
				head  = temp;
				found = true;
			end
		end
	end

	node = parent;

endfunction