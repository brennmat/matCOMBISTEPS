function [items,machines] = matCS_run_items (run);

% function [items,machines] = matCS_run_items (run);
%
% Return a list of the items / machine pairs in a given run.
%
% INPUT:
% run: run struct (see matCS_process_run script)
%
% OUTPUT:
% items: cell string containing the items
% machine: cell string containing the machine names corresponding to the items

if length(run.steps) == 0
	items = {};
	machines = {};
else

	[it,mach] = matCS_step_final_items (run.steps);
	[n,m] = size(it);
	u = {};
	for i = 1:n for j = 1:m % collect all item / machine pairs
		if ~isempty(it{i,j})
			if n > 1
				mm = mach{i};
				ii = it{i,j};
			else
				mm = mach;
				if m > 1
					ii = it{i,j}
				else
					ii = it;
				end
			end
			u{end+1} = sprintf("%s@%s",ii,mm);
		end
	end end
	u = unique(u);
	items = machines = {};
	for i = 1:length(u)
		v = strsplit (u{i},'@');
		items{end+1}    = v{1};
		machines{end+1} = v{2};
	end
end
