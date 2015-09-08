function run = matCS_run_sort_steps (run,machine,step_number);

% function run = matCS_run_sort_steps (run,machine,step_number);
%
% Sort steps in run.
%
% INPUT:
% run: run struct (see matCS_process_run script)
%
% OUTPUT:
% run: same as input, but with steps according to their inlet time

[t,i] = sort (matCS_step_inlet_time(run.steps));
run.steps = run.steps(i);
