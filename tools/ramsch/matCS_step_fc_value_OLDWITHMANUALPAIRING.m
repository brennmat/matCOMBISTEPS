function [fc_val,fc_err,unit] = matCS_step_fc_value (run,step,item);

% function [fc_val,fc_err,unit] = matCS_step_fc_value (run,step,item);
%
% Return the fast-cal value and its error to be used for a given item/final value in a given step. If fast-cal pairing of a step is empty, fc_val = 1, fc_err = 0 and unit = "" is returned
%
% INPUT:
% run: run
% step: step for which the FC value should be determined 
% item: item name for with the FC value should be determined
%
% OUTPUT:
% fc_val: fast-cal signal
% fc_err: error of fast-cal signal
% unit: unit of signal

if strmatch (matCS_step_type(step),"F")
    error ("matCS_step_fc_value: fast cals cannot be normalised!")
end

% determine fast-cal value to be used with the given step / item
itms = matCS_step_final_items (step);
if ~strmatch (item,itms)
    error (sprintf("matCS_step_fc_value: given step (%s) has no item %s",matCS_step_identity(step),item));
end
machine = step.machine;
[val,err,t,unit,fc_allsteps] = matCS_run_fastcalsignals (run,machine,item); % get all fast-cal values
fc_steps = matCS_step_final_fc_pairs (step,item);
if length (fc_steps) == 0
	warning (sprintf("matCS_step_fc_value: fast-cal pairing of step is empty (%s)! Assuming FC = 1...",matCS_step_identity(step)));
	fc_val = 1;
	fc_err = 0;
	unit = "";
else
    fc_val = fc_err = tt = repmat(NaN,length(fc_steps),1);
    for i = 1:length(fc_steps)
        j = find (fc_allsteps == fc_steps(i));
	if isempty(j)
		warning (sprintf("matCS_step_fc_value: fast-cal pairing contains non-existing fast cal (fast-cal step:, step: %s)!",fc_steps(i),matCS_step_identity(step)));
		fc_val(i) = NA;
		fc_err(i) = NA;
	else
	        fc_val(i) = val(j);
	        fc_err(i) = err(j);
	        tt(i)     = t(j);
	end
    end
    if length (fc_val) > 1 % interpolate FC signal
        t_step  = matCS_step_inlet_time(step);
        fc_val  = interp1 (tt,fc_val,t_step);
        fc_err  = interp1 (tt,fc_err,t_step);
    end
end
