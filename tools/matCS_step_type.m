function type = matCS_step_type (step);

% function type = matCS_step_type (step);
%
% Returns the step type (in uppercase letters).
%
% INPUT:
% step: step struct (see matCS_read_step), or a vector where each element corresponds to one step.
%
% OUTPUT:
% type: step type (string, or cell string if step is a vector of multiple steps)

if ( length(step) > 1 )
    type = {};
    for i = 1:length(step)
        type{end+1} = matCS_step_type(step(i));
    end
else
    type = toupper (step.type);
end