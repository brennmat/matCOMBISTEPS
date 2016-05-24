function time = matCS_step_inlet_time (step);

% function time = matCS_step_inlet_time (step);
%
% Return the time of "event inlet" of a given step (properly wraps multi-day IONIC measurements to the date given in the data file).
%
% INPUT:
% step: step struct (see matCS_read_step), or array of step structs
%
% OUTPUT:
% time: time of "event inlet" (Matlab datenum)

if ( length(step) > 1 )
    time = repmat (NaN,size(step));
    for i = 1:length(step)
        time(i) = matCS_step_inlet_time(step(i));
    end
else
	if ~isempty(step)
		date = strsplit (step.date,"."); % date(1): day, date(2): month, date(3): year (YYYY)

		if length(date{3} == 2) % this is a two-digit year, assume 20XX
			date{3} = sprintf('20%s',date{3});
		end
		
        t = mod (step.inlet_time,24*60*60);
		time = datenum (str2num(date{3}),str2num(date{2}),str2num(date{1}),0,0,t);
        
        % Check if measurement was running over midnight, and try to recover timing
        %
        % EXAMPLE: file MB06S148.N2O2ArCO2 (measured with miniRUEDI-1 during midnight on 3.2.2015/4.2.2015
      	% 	- EVENT INLET 86264.76 { marks start of measurement, was on 3.2.2015
      	% 	- EVENT SEPARATION 86264.76 { marks start of measurement, was on 3.2.2015
      	% 	- EVENT PUMPOUT 86435.68 { marks end of measurement, was on 4.2.2015
      	% 	- run MB06 04.02.15 MINIRUEDI { this is the date AFTER the end of the measurement	
             	
        day_inlet = floor (step.inlet_time/60/60/24); % start of measurement
        day_pumpout = floor (step.pumpout_time/60/60/24); % end of measurement
        if day_pumpout > day_inlet % measurement was running over midnight
        	time = time - (day_pumpout-day_inlet); % subtract offset
        	% warning (sprintf('matCS_step_inlet_time: measurement was running over midnight (file: %s). The inlet time was adjusted by assuming the date given in the file corresponds to the end of the measurement. Please be careful...',step.file));
        end
        
	else
		warning ("matCS_step_inlet_time: step is empty! Returning time = NaN...")
		time = NaN;
	end
end
