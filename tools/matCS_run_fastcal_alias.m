function [aitem,amachine,run] = matCS_run_fastcal_alias (run,machine,item,aliasitem,aliasmachine)

% function [aitem,amachine,run] = matCS_run_fastcal_alias (run,machine,item,aliasitem,aliasmachine)
%
% Return (and set) alias item for fascalibration use.
%
% INPUT:
% run: run struct
% machine: machine name
% item: item name (for which alias is applied)
% aliasitem, aliasmachine (optional): item and machine name of alias
%
% OUTPUT:
% aitem, amachine: item / name of alias
% run: modified run

if ~isfield (run,"fc_aliases") % create empty alias table
	warning ("matCS_run_fastcal_alias: field 'fc_aliases' does not exist. Creating it...")
	run.fc_aliases = [];
end

if ~isfield (run.fc_aliases,item) % create empty alias entry for current item
	eval (sprintf ("run.fc_aliases.%s.item = '';",item));
	eval (sprintf ("run.fc_aliases.%s.machine = '';",item));
end

if exist ('aliasitem','var') % set alias
	if ( strcmp(aliasitem,item) & strcmp(aliasmachine,machine) ) % aliasing to itself, so no alias necessary
		aliasitem = '';
		aliasmachine = '';
	end
	eval (sprintf ("run.fc_aliases.%s.item = '%s';",item,aliasitem));
	eval (sprintf ("run.fc_aliases.%s.machine = '%s';",item,aliasmachine));
end

eval (sprintf ("aitem = run.fc_aliases.%s.item;",item));
eval (sprintf ("amachine = run.fc_aliases.%s.machine;",item));