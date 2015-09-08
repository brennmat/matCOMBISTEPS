function time = matCS_step_peak_times (step,item);

% function time = matCS_step_peak_times (step,item);
%
% Return the time of PEAK readings (properly wraps multi-day IONIC measurements to the date given in the data file).
%
% INPUT:
% step: step struct (see matCS_read_step), or array of step structs
% item: item name
%
% OUTPUT:
% time: time of peak readings (Matlab datenum)

if ( length(step) > 1 )
    time = [];
    for i = 1:length(step)
        time = [ time ; matCS_step_peak_times(step(i),item) ];
    end
else
	if ~isempty(step)
		date = strsplit (step.date,"."); % date(1): day, date(2): month, date(3): year (YYYY)

		if length(date{3} == 2) % this is a two-digit year, assume 20XX
			date{3} = sprintf('20%s',date{3});
		end
                
        if ~any(strcmp(fieldnames(step),'peaks'))
            error ('matCS_step_peak_times: step does not contain any PEAK data.')
        end
        if ~any(strcmp(fieldnames(step.peaks),item))
            error (sprintf('matCS_step_peak_times: step does not contain any PEAK data for item %s.',item))
        end
        P = getfield(step.peaks,item);
                t = P.t;
        
        
        if ( max(t)-min(t) > 24*60*60 )
            warning ('matCS_step_peak_times: peaks were measured on different days (dates). I am assuming the last peak reading was on the date given in the data file, but that may not be right.  Be careful...')
        end
        
        while max(t) > 24*60*60 % Ionic was started on previous day or earlier
            t = t - 24*60*60; % remove one day
        end
		time = datenum (str2num(date{3}),str2num(date{2}),str2num(date{1}),0,0,t);
	else
		warning ("matCS_step_peak_times: step is empty! Returning time = NaN...")
		time = NaN;
	end
end
