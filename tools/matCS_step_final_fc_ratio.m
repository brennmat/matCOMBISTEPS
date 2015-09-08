function [ratio,err] = matCS_step_final_fc_ratio (run,step,item);

% function [ratio,err] = matCS_step_final_fc_ratio (run,step,item);
%
% Return the ratio of the final value and the FC signal of a given step / item (FC value used to calculate the ratio is dilution corrected). If the step contains no corresponding FINAL value, val and err are NaN.
%
% INPUT:
% step: step struct (see matCS_read_step), or a vector where each element corresponds to one step.
% item: item (string, e.g. NE22F)
%
% OUTPUT:
% ratio: FINAL value
% err: error of the FINAL value

% get FINAL and FC values (and errors):
[val,val_err] = matCS_step_final_value (step,item);
if isnan(val)
    ratio = err = NA;
else
    [fc,fc_err] = matCS_step_fc_value (run,step,item); % values are dilution corrected!
    
    % calculate ratio (and its error)
    ratio = val(:) ./ fc(:);
    err = sqrt ( (val_err./val).^2 + (fc_err./fc).^2 ) .* ratio;
end
