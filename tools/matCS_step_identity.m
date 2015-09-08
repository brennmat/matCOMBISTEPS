function id = matCS_step_identity (step);

% function id = matCS_step_identity (step);
%
% Returns a string identifying the step (run, machine, step number, step type)
%
% INPUT:
% step: step struct (see matCS_read_step), or a vector where each element corresponds to one step.
%
% OUTPUT:
% id: cell string

if ( length(step) > 1 )
    id = {};
    for i = 1:length(step)
        id{end+1} = matCS_step_identity(step(i));
    end
else
    id = sprintf ("run: %s, machine: %s, number: %i, type: %s",step.run,step.machine,step.number,step.type);
end