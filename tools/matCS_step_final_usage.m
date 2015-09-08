function [use_flag,step] = matCS_step_final_usage (step,item,use_flag);

% function [use_flag,step] = matCS_step_final_usage (step,item,use_flag);
%
% Return or set the "usage flag" of the FINAL value in given step / item pair (true or false). By default, a step does not have any "usage" information. In this calse, this function will return use_flag = true or create the field if needed.
%
% INPUT:
% step: step struct (see matCS_read_step), or a vector where each element corresponds to one step.
% item: item (string, e.g. NE22F)
% use_flag (optional): new value of the usage flag (boolean; if setting the flag value, otherwise leave empty)
%
% OUTPUT:
% use_flag: usage flag (boolean)
% step: modified step

if exist("use_flag")
	use_flag = logical (use_flag); % make sure it's a logical value
end

if isempty(step.final)
	% warning (sprintf("matCS_step_final_usage: step contains no FINAL values (%s).",matCS_step_identity(step)));
	use_flag = false; % nothing useful here, so don't use it
else
	items = fieldnames (step.final);
        i = find(strcmp(upper(items),upper(item)));
	if ~isempty(i)
		if exist("use_flag") % set use_flag to given value
			eval (sprintf("step.final.%s.use_flag = logical(%i);",items{i},use_flag));
		else % read use_flag value of given step:
			x = getfield (step.final,items{i});
			if ~isfield (x,"use_flag") % step has no use_flag field
				eval (sprintf("step.final.%s.use_flag = true;",items{i})); % create and set use_flag
				use_flag = true; % return default value
			else
				eval (sprintf("use_flag = step.final.%s.use_flag;",items{i})); % read use_flag
			end
		end
	else % no such FINAL item, so nothing useful there:
		use_flag = false;
	end
end

% make sure use_flag is boolean, not numeric:
use_flag = logical (use_flag);
