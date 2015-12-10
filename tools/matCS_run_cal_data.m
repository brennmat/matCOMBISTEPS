function [gas_amount,SC_FC_ratio,SC_FC_ratio_err,step_numbers,unit] = matCS_run_cal_data (run,machine,item,use_flag)

% function [gas_amount,SC_FC_ratio,SC_FC_ratio_err,step_numbers,unit] = matCS_run_cal_data (run,machine,item,use_flag)
%
% Return dilution-corrected gas amounts and fast-cal corrected detector signals of slow cals and blanks (this is useful to establish a calibration curve).
%
% INPUT:
% run: run struct
% machine: machine name
% item: item name
% use_flag: string to indicate which cals are to be used:
%	- "all" for all cals
%	- "use" for all cals with usage-flag "true" (see matCS_step_final_usage)
%	- "nouse" for all cals with usage-flag "false" (see matCS_step_final_usage)
%
% OUTPUT:
% gas_amount: gas amounts (vector)
% SC_FC_ratio: slow-cal / fast-cal ratios of detector signals (vector)
% SC_err: error of SC_FC_ratio (vector)
% steps_numbers: step numbers
% unit: unit string

SC_FC_ratio = SC_FC_ratio_err = gas_amount = [];

if ~exist("use_flag")
	warning ("matCS_run_cal_data: missing input parameter 'use_flag'. Assuming 'use_flag = use'. Be careful!")
	use_flag = "use";
end

switch lower(use_flag) % parse use flag
	case "all"
		use_flag = [0 1];
	case "use"
		use_flag = 1;
	case "nouse"
		use_flag = 0;
	otherwise
		error (sprintf("matCS_run_cal_data: unknown 'use_flag' flag: %s",use_flag))
end
use_flag = logical (use_flag);

ss = matCS_filtersteps (run.steps,"type","C"); % find slow cals
bb = matCS_filtersteps (run.steps,"type","B"); % find blanks
rr = matCS_filtersteps (run.steps,"type","R"); % find residuals
ss = [ ss(:) ; bb(:) ; rr(:) ]; % combine slow cals and blanks
ss = matCS_filtersteps (ss,"machine",machine); % find steps of this machine

% filter use flag
k = [];
for i = 1:length(ss)
	if any (matCS_step_final_usage (ss(i),item) ==  use_flag) % if the usage flag for this FINAL matches...
		k = [ k ; i ];
	end
end
ss = ss(k);

step_numbers = [];
if length(ss) == 0
    gas_amount = SC_FC_ratio = SC_FC_ratio_err = [];
else
    for i = 1:length(ss)
	   step_numbers = [ step_numbers ; ss(i).number ];
    end

    [SC_FC_ratio,SC_FC_ratio_err] = matCS_step_final_fc_ratio (run,ss,item); % get SC/FC ratios (this includes dilution correction of FC signals)

    [gas_amount,unit]             = matCS_step_standard_amount(ss,item); % this includes the dilution correction of standard amounts

    % keep only entries with numerical values in both gas amounts and signals
    i = find ( (~isnan(SC_FC_ratio)) & (~isnan(gas_amount)) );
    step_numbers    = step_numbers(i);
    SC_FC_ratio     = SC_FC_ratio(i);
    SC_FC_ratio_err = SC_FC_ratio_err(i);
    gas_amount      = gas_amount(i);
   
end
