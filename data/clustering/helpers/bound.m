function [ub,lb] =  bound(auto)

	if nargin == 0
		auto = Auto();
	end

	while true
		lb = prompt('* Set a lower bound of Ks (2 or greater):',auto.lb);
		ub = prompt('* Set an upper bound of Ks:',auto.ub);

		if lb < 2 || ub < lb
			disp('Bad bounds');
		else
			break
		end
	end

endfunction