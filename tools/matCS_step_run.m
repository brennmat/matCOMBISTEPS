function run = matCS_step_run (step);

% function run = matCS_step_run (step);
%
% Returns the run field of the given step(s) in uppercase letters.
%
% INPUT:
% step: step struct (see matCS_read_step), or a vector where each element corresponds to one step.
%
% OUTPUT:
% run: step run (string, or cell string if step is a vector of multiple steps)

if ( length(step) > 1 )
    run = {};
    for i = 1:length(step)
        run{end+1} = matCS_step_run(step(i));
    end
else
    run = toupper (step.run);
end