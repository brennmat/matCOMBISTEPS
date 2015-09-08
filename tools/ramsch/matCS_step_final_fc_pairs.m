function fc_step_numbers = matCS_step_final_fc_pairs (step,item);

% function fc_step_numbers = matCS_step_final_fc_pairs (step,item);
%
% Return the step numbers of the fast cal(s) associated with the given item / step.
%
% INPUT:
% step: step struct (see matCS_read_step), or a vector where each element corresponds to one step.
% item: item (string, e.g. NE22F)
%
% OUTPUT:
% fc_step_numbers: fast-cal step numbers (same machine etc.)

fc_step_numbers = [];
if isempty(step.final)
	warning (sprintf("matCS_step_final_value: step contains no FINAL values (%s).",matCS_step_identity(step)));
else
	items = fieldnames (step.final);
        i = find(strcmp(upper(items),upper(item)));
        if isempty(i)
		warning (sprintf("matCS_step_final_value: step contains no final data for item %s (%s).",item,matCS_step_identity(step)));
        else
		x = getfield (step.final,items{i});
		if isfield (x,"FC_stepnumbers")
			fc_step_numbers = x.FC_stepnumbers;
		end
	end
end
