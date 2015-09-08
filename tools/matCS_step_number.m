function stepnum = matCS_step_number (step);

% function stepnum = matCS_step_number (step);
%
% Return step number of a given step
%
% INPUT:
% step: step struct (see matCS_read_step), or array of step structs
%
% OUTPUT:
% stepnum = step number

if ( length(step) > 1 )
    stepnum = repmat (NaN,size(step));
    for i = 1:length(step)
        stepnum(i) = matCS_step_number(step(i));
    end
else
    if isempty(step)
	warning ("matCS_step_number: step is empty! Returning stepnum = NA...");
	stepnum = NA;
    else
        stepnum = step.number;
    end
end
