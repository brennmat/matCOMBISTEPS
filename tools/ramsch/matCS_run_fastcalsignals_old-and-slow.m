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

s = s_err = t = stepnumbers = [];
unit = {};

disp ('matCS_run_fastcalsignals: please ask the guru to make this code faster...'); fflush (stdout);
% Speed this up by first filtering out the useless steps:
% 1. fiter out fastcals
% 2. filter out steps with given machine
% 3. filter out fastcals with the given "use" flag
% Then use only the remaining steps to run the following loop. Or maybe this will then easily be feasable without using a loop at all!

for i = 1:length(run.steps) % THIS LOOP IS SLOOOW, SHOULD BE MADE FASTER (OR AVOIDED) USING THE APPROACH DESCRIBED ABOVE!
    if strmatch (run.steps(i).machine,machine)
        if strmatch (upper(run.steps(i).type),"F")
            items = matCS_step_final_items (run.steps(i));
            item = upper(item);
            if ~isempty(strmatch(item,items,"exact"))
                if strmatch (tolower(use_flag),"all") % ignore the use flag of this step
                    use = true;
                else % check if the use_flag of this step matches
                    use = matCS_step_final_usage (run.steps(i),item);
                    if strmatch (tolower(use_flag),"nouse")
                        use = ~use;
                    end
                end
                if use
                    [x,x_err,u] = matCS_step_final_value (run.steps(i),item); % This DOES NOT take into account the dilution factor(s)
                    dilution = matCS_step_dilution (run.steps(i));
                    t     = [ t ; matCS_step_inlet_time(run.steps(i))];
                    s     = [ s ; x / dilution ]; % divide by dilution to take into account dilution factor
                    s_err = [ s_err ; x_err / dilution ]; % divide by dilution to take into account dilution factor
                    unit{end+1} = u;
                    stepnumbers = [ stepnumbers ; run.steps(i).number ];
                end
            end
        end
    end
end

% remove FCs with s or s_err equal to NaN:
k = find(~isnan(s_err./s));
s = s(k);
s_err = s_err(k);
t = t(k);

% sort by time:
[t i] = sort (t);
s = s(i);
s_err = s_err(i);
stepnumbers = stepnumbers(i);

if length(unit) > 0
	unit = unit{1}; % all values have the same unit, so one is enough
else
	unit = "";
end
