function [val,err,unit] = matCS_step_final_value (step,item);

% function [val,err,unit] = matCS_step_final_value (step,item);
%
% Return the final value and error of a an item measured in a given step. If the step contains no corresponding FINAL value, val and err are NaN. Dilution factors are NOT considered (these should be applied to the STANDARD AMOUNTS, not the DETECTOR SIGNALS)
%
% INPUT:
% step: step struct (see matCS_read_step), or a vector where each element corresponds to one step.
% item: item (string, e.g. NE22F)
%
% OUTPUT:
% val: FINAL value
% err: error of the FINAL value

if ( length(step) > 1 )
    val = []; err = []; unit = {};
    for i = 1:length(step)
        [v,e,u] = matCS_step_final_value (step(i),item);
        val = [ val ; v ];
        err = [ err ; e ];
        unit{end+1} = u;
    end
else
    val = NaN; err = NaN; unit = "";
%    if isempty(step.final)
%        warning (sprintf("matCS_step_final_value: step contains no FINAL values (%s).",matCS_step_identity(step)));
%    else
if ~isempty(step.final)
        items = fieldnames (step.final);
        i = find(strcmp(upper(items),upper(item)));
%        if isempty(i)
%            warning (sprintf("matCS_step_final_value: step contains no FINAL data for item %s (%s).",item,matCS_step_identity(step)));
%        else
	if ~isempty(i)
		if isfield(step.final,items{i})
			x = getfield (step.final,items{i});
			if isfield(x,"val")
				val = x.val;
			else
				val = NA;
			end
			if isfield(x,"err")
				err = x.err;
			else
				err = NA;
			end
			if isfield(x,"unit")
				unit = x.unit;
			else
				unit = NA;
			end
		else
			warning (sprintf("matCS_step_final_value: step contains no FINAL data for item %s (%s).",item,matCS_step_identity(step)));
		end
	end
end
end
