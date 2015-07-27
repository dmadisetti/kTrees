function csv = csvrecursion(parent,pathway)

	csv = '';

	% For joining up
	connector = '-';
	if parent.root
		connector = '';
	end

	% Spit out branches
	counter  = cell2mat(parent.counters(parent.K));
	clusters = cell2mat(parent.collective(parent.K));
	for i = 1:parent.K

		% Just so we don't have to name everything
		if size(num2str(i)) == size(parent.names{i}) && num2str(i) == parent.names{i}
			continue;
		end

		% Join indices
		nums = '';
		for j = 1:counter(i)
			nums = strcat(nums,num2str(clusters(i,j)),'-');
		end

		% Add to csv
		csv = strcat(csv,pathway,connector,parent.names{i},',',num2str(counter(i)),',',nums,"\n");
	end

	% Recurse for sub clusters
	for i = 1:size(parent.branches,2)
		% Name your branches
		if size(parent.branches(i).K,1) > 0 && !(size(num2str(i)) == size(parent.names{i}) && num2str(i) == parent.names{i})
			% Get Sub clusters
			csv = strcat(csv, csvrecursion(parent.branches(i),strcat(pathway,connector,parent.names{i})));
		end
	end

endfunction