function machine = matCS_step_machine (step);

% function machine = matCS_step_machine (step);
%
% Returns the machine field of the given step(s) in uppercase letters.
%
% INPUT:
% step: step struct (see matCS_read_step), or a vector where each element corresponds to one step.
%
% OUTPUT:
% machine: step machine (string, or cell string if step is a vector of multiple steps)

if ( length(step) > 1 )
    machine = {};
    for i = 1:length(step)
        machine{end+1} = matCS_step_machine(step(i));
    end
else
    machine = toupper (step.machine);
end