function labcode = matCS_step_labcode (step);

% function labcode = matCS_step_labcode (step);
%
% Returns the labcode (string, in uppercase letters) of a sample step. Other step types result in a warning and an empty labcode.
%
% INPUT:
% step: step struct (see matCS_read_step), or a vector where each element corresponds to one step.
%
% OUTPUT:
% labcode: cell string

if ( length(step) > 1 )
    labcode = {};
    for i = 1:length(step)
        labcode{end+1} = matCS_step_labcode(step(i));
    end
else
    type = matCS_step_type(step);
    if strcmp(type,'S')
	if length(step.sticker) > 0
	        labcode = toupper(step.sticker{1});
	else
		warning (sprintf('matCS_step_labcode: step has no sticker! Returning empty labcode (%s).',matCS_step_identity(step)));
		labcode = '';
	end
    else
        warning (sprintf('matCS_step_labcode: labcodes are suported with steps of type S only (step: %s). Returning empty labcode.',matCS_step_identity(step)));
        labcode = '';
    end
end
