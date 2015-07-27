function number = prompt(message,auto)

	% If auto
	if nargin == 2 && auto ~= -1
		number = auto;
		return
	end

	while true
		try
			number = input(message);
			if isnumeric(number) && size(number) == [1 1]
				break;
			end
		catch
			msg = lasterror.message;
			if !(strfind (msg, 'undefined'))
				disp('A simple number will do');			  
			endif
		end_try_catch
		disp('Try entering a number');
	end
end