function time = matCS_step_analysis_time (step);

% function time = matCS_step_analysis_time (step);
%
% Return the date/time of analysis of a given step. In general, the result is identical to matCS_step_inlet_time (step).
% Exceptions:
% - For steps with the (sub)string 'RUEDI' in their 'machine' field, the result is the mean of EVENT SEPARATION and EVENT PUMPOUT.
%
% INPUT:
% step: step struct (see matCS_read_step), or array of step structs
%
% OUTPUT:
% time: time of analysis (Matlab datenum)

if ( length(step) > 1 )
    time = repmat (NaN,size(step));
    for i = 1:length(step)
        time(i) = matCS_step_analysis_time(step(i));
    end
else
	if ~isempty(step)

		if any (findstr(upper(matCS_step_machine(step)),'RUEDI')) % this is a RUEDI measurement
			t_separation = matCS_step_separation_time (step); % beginning of data series used for Digest evaluation
			t_pumpout    = matCS_step_pumpout_time (step); % end of data series used for Digest evaluation
			time         = t_separation + 0.5*(t_pumpout-t_separation);
		else % this not a RUEDI measruement
			time = step.inlet_time;			
		end
	else
		warning ("matCS_step_analysis_time: step is empty! Returning time = NaN...")
		time = NaN;
	end
end
