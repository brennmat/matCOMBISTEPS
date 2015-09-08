function f0 = matCS_run_fastcal_mean (run,machine,item)

% function f0 = matCS_run_fastcal_mean (run,machine,item)
%
% Return error-weighted mean of fast-cal signals corresponding to a given item measured on a given machine
%
% INPUT:
% run: run struct
% machine: machine name
% item: item name
%
% OUTPUT:
% f0: mean of fast-cal signals

[f,f_err] = matCS_run_fastcalsignals (run,machine,item);
if length(f) > 0
    f0 = sum(f./f_err) / sum(1./f_err);
else
    f0 = NaN;
end