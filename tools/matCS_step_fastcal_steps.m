function fc_steps = matCS_step_fastcal_steps (step,item);

% function type = matCS_step_fastcal_steps (step,item);
%
% Returns the fast-cal step numbers to be used for a given FINAL item and step
%
% INPUT:
% step: step struct (see matCS_read_step)
% item: FINAL item%
% OUTPUT:
% fc_steps: fast-cal step numbers of the given FINAL item / step

fc_steps = eval (sprintf ("step.final.%s.FC_stepnumbers;",item));

    