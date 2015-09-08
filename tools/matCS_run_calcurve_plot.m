function [h,run] = matCS_run_calcurve_plot (run,machine,item,calplotopt)

% function [h,run] = matCS_run_calcurve_plot (run,machine,item,calplotopt)
%
% Open new figure window, plot calibration curve and return figure handle.
%
% INPUT:
% run: run struct
% machine: machine name
% item: item name
% calplotopt (optional): struct with flags to indicate different plot options. Study the code to find out more.
%
% OUTPUT:
% h: plot handle (vector)
% run: run struct (possibly with newly created 'calpoly_deg.MACHINE.ITEM' fields)

% get slow-cal data:
[g_use,r_use,r_use_err,stepnums_use]            = matCS_run_cal_data (run,machine,item,"use"); % get gas amounts and SC/FC ratios (and errors)
[g_nouse,r_nouse,r_nouse_err,stepnums_nouse]    = matCS_run_cal_data (run,machine,item,"nouse"); % get gas amounts and SC/FC ratios (and errors)

% determine calibration curve:
if isempty (r_use)
	warning ("matCS_run_calcurve_plot: there are not FINAL values with use-flags = true. Cannot determine a cal curve...")
	rr = gg = gg_err = []; unit = "";
else
	rr = linspace (0,max(r_use),30); rr_err = repmat(0,size(rr));
	[gg,gg_err,unit,poly,run] = matCS_gasamount (run,machine,item,rr,rr_err); % calculate gas amounts corresponding to rr by poly fitting
	%% mean(gg_err) % print mean error to terminal
end

if !exist("calplotopt")
	calplotopt.add_steplabels = true;
	calplotopt.use_new_window = true;
end

if calplotopt.use_new_window
	figure;
end
% plot shaded area indicating error range:
e_x = [ gg-gg_err fliplr(gg+gg_err) ];
e_y = [ rr fliplr(rr) ];
c = [1 1 1]*0.7;
h = patch(e_x,e_y,c,'edgecolor',c); hold on
h_use     = plot (g_use,r_use,'bo','markersize',4);
h_nouse   = plot (g_nouse,r_nouse,'ro','markersize',4);
h_curve   = plot (gg,rr,'k-');
%h_curve_1 = plot (gg-gg_err,rr,'k--');
%h_curve_2 = plot (gg+gg_err,rr,'k:');

if calplotopt.add_steplabels
	% plot labels:
	dx = axis; dx = (dx(2)-dx(1))/20;
	dy = axis; dy = (dy(4)-dy(3))/20;
	g = [ g_use(:) ; g_nouse(:) ];
	r = [ r_use(:) ; r_nouse(:) ];
	s = [ stepnums_use(:) ; stepnums_nouse(:) ];
	for i = 1:length(s)
		tt = text (g(i)+dx,r(i)-dy,num2str(s(i)));
		set (tt,'horizontalalignment','left');
		line ([g(i) g(i)+dx*0.9],[r(i) r(i)-dy*0.9]);
	end
end

hold off

% make sure the zero point is within the axis ranges:
r = axis;
if r(1) > 0
	r(1) = 0;
	axis (r);
end
if r(3) > 0
	r(3) = 0;
	axis (r);
end

xlabel (sprintf("SC gas amount (%s)",unit));
ylabel ("SC / FC-0 signal ratio");

N = length (poly.p) - 1;
pp = "x = ";
for i = 0:N
	if i < N
		if poly.p(i+2) < 0
			pm = "";
		else
			pm = "+";
		end
		if N-i > 1
			pp  = sprintf ("%s%g y^%i %s ",pp,poly.p(i+1),N-i,pm);
		else
			pp  = sprintf ("%s%g y %s ",pp,poly.p(i+1),pm);
		end
	else
		pp  = sprintf ("%s%g",pp,poly.p(i+1));
	end
end

title (sprintf("Calibration curve for %s on %s (%s)",item,machine,pp))
