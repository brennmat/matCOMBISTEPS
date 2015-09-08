function [s,s_err,t,unit,stepnumbers] = matCS_run_fastcalsignals (run,machine,item,use_flag)

% function [s,s_err,t,unit,stepnumbers] = matCS_run_fastcalsignals (run,machine,item,use_flag)
%
% Return fast-cal signals corresponding to a given item measured on a given machine. The return values take into account the dilution information (as returned by matCS_step_dilution).
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
% s: fast-cal signal
% s_err: error of fast-cal signal
% t: time of fast-cal signal (Matlab datenum)
% unit: unit of signal (string)
% stepnumbers: fast-cal step numbers

X = matCS_filtersteps (run.steps,'type','F'); % extract all fastcals
X = matCS_filtersteps (X,'machine',machine); % extract steps with matching machine

if isempty (X)
	error (sprintf('matCS_run_fastcalsignals: there are no fastcals for item %s measured on machine %s.',item,machine))
end

val = matCS_step_final_value (X,item);
X = X(find(~isnan(val))); % extract steps which have a FINAL value of the current item

if ~strcmp(toupper(use_flag),"ALL") % extract steps with matching usage flags
    k = repmat (NA,size(X));
    for i = 1:length(X)
        k(i) = matCS_step_final_usage (X(i),item);
    end
    if strcmp(toupper(use_flag),'USE')
        k = find(k);
    elseif strcmp(toupper(use_flag),'NOUSE')
        k = find(~k);
    else
        warning (sprintf('matCS_run_fastcalsignals: unknown use_flag (%s). Assuming use_flag = ALL...',use_flag))
        k = [1:length(X)];
    end
    XX = X;
    X = X(k);
end

if length(X) > 0 % get data values:
    [s,s_err,unit] = matCS_step_final_value (X,item); % This DOES NOT take into account the dilution factor(s)
    dilution = matCS_step_dilution (X);
    s     = s ./ dilution;     % divide by dilution to take into account dilution factor
    s_err = s_err ./ dilution; % divide by dilution to take into account dilution factor
    t = matCS_step_inlet_time(X);
    stepnumbers = repmat (NA,size(X));
    for i = 1:length(X)
        stepnumbers(i) = X(i).number;
    end
    % sort by time:
    [t i] = sort (t);
    s = s(i);
    s_err = s_err(i);
    stepnumbers = stepnumbers(i);
    
    if length(unit) > 1
        unit = unit{1}; % all values have the same unit, so one is enough
    end
else % there are no matching steps
    s = s_err = t = stepnumbers = [];
    unit = '';
end
