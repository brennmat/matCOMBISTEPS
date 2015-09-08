function time = matCS_step_inlet_time (step);

% function time = matCS_step_inlet_time (step);
%
% Return the time of "event inlet" of a given step
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
		time = datenum (str2num(date{3}),str2num(date{2}),str2num(date{1}),0,0,step.inlet_time);
	else
		warning ("matCS_step_inlet_time: step is empty! Returning time = NaN...")
		time = NaN;
	end
end
