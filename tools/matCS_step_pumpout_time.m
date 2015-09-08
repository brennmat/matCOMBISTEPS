function time = matCS_step_pumpout_time (step);

% function time = matCS_step_pumpout_time (step);
%
% Return the time of "event pumpout" of a given step (properly wraps multi-day IONIC measurements to the date given in the data file).
%
% INPUT:
% step: step struct (see matCS_read_step), or array of step structs
%
% OUTPUT:
% time: time of "event pumpout" (Matlab datenum)

if ( length(step) > 1 )
    time = repmat (NaN,size(step));
    for i = 1:length(step)
        time(i) = matCS_step_pumpout_time(step(i));
    end
else
	if ~isempty(step)
		date = strsplit (step.date,"."); % date(1): day, date(2): month, date(3): year (YYYY)

		if length(date{3} == 2) % this is a two-digit year, assume 20XX
			date{3} = sprintf('20%s',date{3});
		end

        t = mod (step.pumpout_time,24*60*60);
		time = datenum (str2num(date{3}),str2num(date{2}),str2num(date{1}),0,0,t);
        
        % Assume that EVENT PUMPOUT always occurs on the date given in the data file (see also matCS_step_inlet_time about what happens if a measurement runs over midnight), so there is no need to compensate for any date changes
        
        t = mod (step.pumpout_time,24*60*60);
		time = datenum (str2num(date{3}),str2num(date{2}),str2num(date{1}),0,0,t);
		
	else
		warning ("matCS_step_pumpout_time: step is empty! Returning time = NaN...")
		time = NaN;
	end
end
