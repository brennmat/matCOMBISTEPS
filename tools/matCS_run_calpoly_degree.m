function [deg,run] = matCS_run_calpoly_degree (run,machine,item,deg)

% function deg = matCS_run_calpoly_degree (run,machine,item,deg)
%
% Return (and set) poly degree to be used for the cal curve.
%
% INPUT:
% run: run struct
% machine: machine name
% item: item name
% deg (optional): polynomial degree (integer)
%
% OUTPUT:
% deg: polynomial degree (integer)
% run: run struct (possibly with newly created 'calpoly_deg.MACHINE.ITEM' fields)

if ~isfield (run,"calpoly_deg")
	warning ("matCS_run_calpoly_deg: field 'calpoly_deg' does not exist. Creating it...")
	run.calpoly_deg = [];
end
if ~isfield (run.calpoly_deg,machine)
	warning (sprintf("matCS_run_calpoly_deg: field 'calpoly_deg.%s' does not exist. Creating it...",machine))
	eval (sprintf("run.calpoly_deg.%s = [];",machine));
end
eval (sprintf("u = run.calpoly_deg.%s;",machine));
if ~isfield (u,item)
	warning (sprintf("matCS_run_calpoly_deg: field 'calpoly_deg.%s.%s' does not exist. Creating it (assuming default value: 1)...",machine,item))
	eval (sprintf("run.calpoly_deg.%s.%s = 1;",machine,item));
end
clear u;

field = sprintf ("run.calpoly_deg.%s.%s",machine,item);

if exist ("deg") % change value in run struct:
	cmd = sprintf ("%s = %i;",field,deg);
	eval (cmd);
else % get value from run struct:
	cmd = sprintf ("deg = %s;",field);
	eval (cmd);
end
