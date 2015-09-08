function step = matCS_run_getstep (run,machine,step_number);

% function step = matCS_run_getstep (run,machine,step_number);
%
% Return step struct corresponding to given step (identified by machine and step number)
%
% INPUT:
% run: run struct (see matCS_process_run script)
% machine: machine name
% step_number: step number
%
% OUTPUT:
% step: step struct

step = [];
for i = 1:length(run.steps)
    if run.steps(i).number == step_number
        if strcmp (machine,run.steps(i).machine)
            step = run.steps(i);
        end
    end
end