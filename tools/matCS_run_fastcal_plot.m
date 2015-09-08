function matCS_run_fastcal_plot (run,machine,item,x_axis)

% function matCS_run_fastcal_plot (run,machine,item,x_axis)
%
% Open new figure window, plot fastcal signals vs. time and return figure handle.
%
% INPUT:
% run: run struct
% machine: machine name
% item: item name
% x_axis: optional sting indicating x-axis ("time", "stepnumber"). Default: x_axis = "time"
%
% OUTPUT:
% (none)

if ~exist ('x_axis')
    warning ("matCS_run_fastcal_plot: x_axis type not specified. Assuming x_axis = time.")
    x_axis = 'time';
end

x_axis = tolower (x_axis);    

[s_use,s_use_err,t_use,unit1,stepnumbers_use] = matCS_run_fastcalsignals (run,machine,item,"use");
[s_nouse,s_nouse_err,t_nouse,unit2,stepnumbers_nouse] = matCS_run_fastcalsignals (run,machine,item,"nouse");

if strmatch(unit1,unit2,"exact")
	unit = unit1;
elseif length(unit1) > length(unit2)
	unit = unit1;
else
	unit = unit2;
end

if isempty(unit)
	unit = "-";
end

figure();

switch x_axis
    case 'time'
        x_use = t_use;
        x_nouse = t_nouse;
        x_label = 'Time (datenum)';
    case 'stepnumber'
        x_use = stepnumbers_use;
        x_nouse = stepnumbers_nouse;
        x_label = 'Step number';
    otherwise
        error (sprintf('matCS_run_fastcal_plot: unknown x-axis type: %s.',x_axis))
end

plot (x_use,s_use,'-bo',x_nouse,s_nouse,'ro');
dy = axis; dy = (dy(4)-dy(3))/20;
x = [ x_use(:) ; x_nouse(:) ];
s = [ s_use(:) ; s_nouse(:) ];
stepnumbers = [ stepnumbers_use(:) ; stepnumbers_nouse(:) ];
for i = 1:length(x)
	tt = text (x(i),s(i)-dy,['F' num2str(stepnumbers(i))]);
	set (tt,'horizontalalignment','center');
	line ([x(i) x(i)],[s(i) s(i)-dy*0.9]);
end
x_low  = min (x);
x_high = max (x);

% add markers for samples and slow cals
XX = matCS_filtersteps (run.steps,'machine',machine); % get all steps from this machine
val = matCS_step_final_value (XX,item); % get all final values...
XX = XX(find(~isnan(val))); % ...only keep those steps with final values for the given item.

samples = matCS_filtersteps (XX,'type','S');
cals = matCS_filtersteps (XX,'type','C');

switch x_axis
    case 'time'
	if length(samples) > 0
        	X_S = matCS_step_inlet_time (samples);
	else
		X_S = [];
	end
	
	if length(cals) > 0
	        X_C = matCS_step_inlet_time (cals);
	else
		X_C = [];
	end

    case 'stepnumber'
	if length(samples) > 0
	        X_S = matCS_step_number (samples);
	else
		X_S = [];
	end
	
	if length(cals) > 0
	        X_C = matCS_step_number (cals);
	else
		X_C = [];
	end

end

if length(X_S) > 0
	X_S = [ X_S(:) X_S(:) repmat(NaN,size(X_S)) ];
	Y_S = repmat([ min(s) max(s) NaN ],size(X_S,1),1);
	hold on
	plot (X_S',Y_S','r-');
	hold off
	x_low  = min ([min(X_S) x_low]);
	x_high = max ([max(X_S) x_high]);
end
if length(X_C) > 0
	X_C = [ X_C(:) X_C(:) repmat(NaN,size(X_C)) ];
	Y_C = repmat([ min(s) max(s) NaN ],size(X_C,1),1);
	hold on
	plot (X_C',Y_C','g-');
	hold off
	x_low  = min ([min(X_C) x_low]);
	x_high = max ([max(X_C) x_high]);
end

for i = 1:length(samples)
	tt = text (X_S(i,1),Y_S(i,2)+dy/2,['S' num2str(samples(i).number)]);
	set (tt,'horizontalalignment','left');
	set(tt,'rotation',90);
end
for i = 1:length(cals)
	tt = text (X_C(i,1),Y_C(i,1)-dy/2,['C' num2str(cals(i).number)]);
	set (tt,'horizontalalignment','right');
	set(tt,'rotation',90);
end

switch x_axis
    case 'time'
	axis ([x_low-0.05*(x_high-x_low) x_high+0.05*(x_high-x_low)]);
    case 'stepnumber'
	axis ([x_low-1 x_high+1]);
end

xlabel (x_label)
ylabel (sprintf('FC0-%s on %s (%s)',item,machine,unit));
switch x_axis
    case 'time'
	title (sprintf("%s-FC signals vs. time (mean = %g %s, stdev = %g %s)",item,mean(s),unit,std(s),unit));
    case 'stepnumber'
	title (sprintf("%s-FC signals vs. step number (mean = %g %s, stdev = %g %s)",item,mean(s),unit,std(s),unit));
end
end
