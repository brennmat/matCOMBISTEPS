function [items,machines] = matCS_step_final_items (s);

% function [items,machines] = matCS_step_final_items (s);
%
% Return a list of the items with FINAL lines step and the corresponding machines (where the items were measured). step may be a vector of multiple steps. In this case, each row 'items' corresponds to a single step.
%
% INPUT:
% step: step struct (see matCS_read_step), or a vector where each element corresponds to one step.
%
% OUTPUT:
% items: cell string containing the items
% machines: cell string containing the machine name corresponding to each step

if ( length(s) > 1 )
    items = {};
    machines = {};
    for i = 1:length(s)
        [it,mach] = matCS_step_final_items (s(i));
        for j = 1:length(it) % this is ugly, but I don't know how to do it nicely...
            items{i,j} = it{j};
        end
	machines{i} = mach;
    end
else
    if isempty(s.final)
        items    = {};
        machines = {};
    else
        items    = fieldnames (s.final);
        items    = unique (items)';
	machines = s.machine;
    end
end
