function FC_num = matCS_step_fc_pairing (step,item);

% function FC_num = matCS_step_fc_pairing (step,item);
%
% Return fast-cal pairing (i.e. step number) of fast cal associated with a given step/item.
%
% INPUT:
% step: step struct (see matCS_read_step), or a vector where each element corresponds to one step.
% item: item name (string, NOT a cell string). NOTE: item is the same for all steps.
%
% OUTPUT:
% FC_num: fast cal step number(s)

FC_num = [];

if strcmp(matCS_step_type(step),'F')
    error (sprintf('matCS_step_fc_pairing: this step (%s) is a fastcal. It makes no sense to pair this with another fastcal.',matCS_step_identity(step)))
end

items = matCS_step_final_items (step);
if ~any(find(strcmp(upper(items),upper(item))));
    warning (sprintf('matCS_step_fc_pairing: step (%s) has no such FINAL item (%s).',matCS_step_identity(step),item))
else
    x = step.final;
    x = getfield (x,item);
    FC_num = x.FC_stepnumbers;
end