function [fc_val,fc_err,unit] = matCS_step_fc_value (run,step,item);

% function [fc_val,fc_err,unit] = matCS_step_fc_value (run,step,item);
%
% Return the dilution-corrected fast-cal value and its error to be used with a given item/final value in a given step as follows:
% * If the pairing information of the step is empty (default), the fast-cal value is determined by linear interpolation of the neighbouring fast-cal values (only fast-cal steps with use_flag = true are used). If there is only one fast cal available, this value will be used (without interpolation or anything). No manual pairing stuff considered (just set the FC usage flags properly and you should be fine!)
% * If the pairing information is not empty, the corresponding fast cal is used.
%
% MAYBE THIS SHOULD BE IMPROVED: USE ONLY ONE NEXT FASTCAL IF PREVIOUS FASTCAL IS NOT FROM THE SAME DAY?
%
% INPUT:
% run: run
% step: step (or array of steps) for which the FC value should be determined 
% item: item name for which the FC value(s) should be determined
%
% OUTPUT:
% fc_val: fast-cal signal
% fc_err: error of fast-cal signal
% unit: unit of signal

N = length (step);

% Check that none of the steps is a fastcal:
X = matCS_filtersteps (step,'type','F');
if length(X) > 0
    error ("matCS_step_fc_value: some of the given steps are fastcals. Cannot continue, because it makes no sense to determine a fastcal value for these steps.")
end

% Check if all steps are from the same machine:
if length(step) > 1
    m = matCS_step_machine (step);
    machine = unique(m);
    if length(machine) > 1
        error ("matCS_step_fc_value: all steps must be from the same machine!");
    end
    machine = machine{1};
else
    machine = matCS_step_machine(step);
end

% Prepare stuff:
[val,err,t,unit,stepnumbers] = matCS_run_fastcalsignals (run,machine,item,"use"); % get all fast-cal values with use_flag = true, values are dilution corrected

if ~any(val) % there are no suitable fastcal values available
	fc_val = fc_err = NA;
	unit = '';

else

[t,i] = sort (t);
val = val(i);
err = err(i);
stepnumbers = stepnumbers(i);
fc_val = fc_err = repmat (NA,N,1);

% Determine an index to those steps that actually have the given final item (the other steps will be ignored, and NA will be returned for these):
k = repmat (0,N,1);
for i = 1:N % build an index (k) to the steps which actually have the given FINAL item
    itms = matCS_step_final_items (step(i));
    if any(strcmp(itms,item)) % this step has a FINAL value for the given item / machine
        k(i) = 1;
    end
end

k = find (k); % k is now an index to those steps which do have the given item/machine combination
M = length (k);

% Find steps with explicit fastcal pairing and set their fastcal value
INTP = repmat (0,M,1);
for i = 1:M % loop through all steps in k to check if they have explicit fastcal pairing:
    x = getfield (step(k(i)).final,item);
    x = getfield (x,'FC_stepnumbers');
    if isempty(x) % use interpolation for this step
       INTP(i) = 1; 
    else % get the fastcal value corresponding to the pairing info
        % check if the fastcal is available:
        if length(x) > 1
            error (sprintf('matCS_step_fc_value: explicit fastcal pairing with more than one fastcal step is not (yet) supported (step: %s)!',matCS_step_identity(step(k(i)))));
        end
        u = find (stepnumbers == x);
        if isempty(u)
            warning (sprintf('matCS_step_fc_value: fastcal pairing of this step (%s) refers to inexistent or disabled fastcal. This may happen if you disabled the fastcal after pairing it with this step. Returning NA...',matCS_step_identity(step(k(i)))))
            fc_val(k(i)) = fc_err(k(i)) = NA;
        else
            % set value:            
            fc_val(k(i)) = val(u);
            fc_err(k(i)) = err(u);
        end
    end
end
INTP = find (INTP); % INTP is now an index to the steps which require interpolation in k

% B. Determine interpolated fastcal values for remaining steps (i.e. those without explicit fastcal pairing)
if length(INTP) > 0 % if there's anything left for interpolation
    t_step  = matCS_step_inlet_time(step(k(INTP)));

    if length (t) > 1
        fc_val(k(INTP))  = interp1 (t,val,t_step);
        fc_err(k(INTP))  = interp1 (t,err,t_step);
    else % only one single FC available, cannot interpolate
        fc_val(k(INTP)) = val;
	fc_err(k(INTP)) = err;
    end

    u = find (t_step < t(1));
    if ~isempty(u)    
        for i = 1:length(u)
            warning (sprintf('matCS_step_fc_value: there are no fastcals before this step (%s). Using nearest fastcal value...',matCS_step_identity(step(k(INTP(u(i)))))));
            fc_val(k(INTP(u(i)))) = val(1);
            fc_err(k(INTP(u(i)))) = err(1);
        end
    end
    
    u = find (t_step > t(end));
    if ~isempty(u)
        for i = 1:length(u)
            warning (sprintf('matCS_step_fc_value: there are no fastcals after this step (%s). Using nearest fastcal value...',matCS_step_identity(step(k(INTP(u(i)))))));
            fc_val(k(INTP(u(i)))) = val(end);
            fc_err(k(INTP(u(i)))) = err(end);
        end
    end
end

end
