function run = matCS_run_edit_cals (run)

% function matCS_run_edit_cals (run)
%
% Interactively show / edit calibration curves (sensor signals vs. gas amounts)
%
% INPUT:
% run: struct containing the data of the run
%
% OUTPUT:
% run: modified run

% get a list of all items in this run
[items,machines] = matCS_run_items (run); 

if (length (items) == 0) % don't edit anything
    disp ('No FINAL items available!')

else % show a menu of the different items
    quit = 0;
    while ~quit
        men = "ans = matCS_menu ('*** PROCESS RUN -- MANIPULATE CALIBRATION CURVES -- CHOOSE ITEM ***'";
        for i = 1:length(items)
            men = sprintf ("%s , '%s @ %s'",men,items{i},machines{i});
        end
        men = sprintf ("%s );",men);
        eval (men);
        switch ans
            case 0 % exit
                quit = 1;
            otherwise % show calibration curve of item
                run = __matCS_run_edit_calcurve_item (run,machines{ans},items{ans});
        end % switch
    end % while
end % if / else

end % function


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% helper functions %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function run = __matCS_run_edit_calcurve_item (run,machine,item) % manipulate / show calibration curve of a given machine/item
quit = 0;
men = sprintf ("ans = matCS_menu ('*** PROCESS RUN -- MANIPULATE OR SHOW CALIBRATION CURVE (%s @ %s) ***'",item,machine);
men = sprintf ("%s , '%s'",men,"Show curve");
men = sprintf ("%s , '%s'",men,"Change slow-cal usage");
men = sprintf ("%s , '%s'",men,"Change degree of poly for cal curve");
men = sprintf ("%s );",men);
while ~quit
        eval (men);
        switch ans
            case 0 % exit
                quit = 1;
            case 1 % show calibration curve of item
                [dummy,run] = matCS_run_calcurve_plot (run,machine,item); % run may get some new calpoly_deg.MACHINE.ITEM fields
            case 2 % edit slow-cal usage
                run = __matCS_run_edit_slowcal_usage (run,machine,item);
    	    case 3 % change poly degree
                run = __matCS_run_edit_calcurve_polydeg (run,machine,item);
            end
end % while
end % function


function run = __matCS_run_edit_calcurve_polydeg (run,machine,item)
n = matCS_run_calpoly_degree (run,machine,item); % get cal-poly degree of current item
n = input (sprintf("Enter poly degree for cal curve (%s@%s -- current value: %i): ",item,machine,n),'s');
n = str2num (n);
if ~isempty(n)
    n = round (n);
end
if n > -1
    [n,run] = matCS_run_calpoly_degree (run,machine,item,n);
else
	warning ('You entered a wrong value, did not change anything.')
end % if
end % function


function run = __matCS_run_edit_slowcal_usage (run,machine,item) % edit slow-cal usage flags for a given machine/item
% find cals for editing:
[cals,ii] = matCS_filtersteps(run.steps,"type","C");
[blanks,jj] = matCS_filtersteps(run.steps,"type","B");
[residuals,kk] = matCS_filtersteps(run.steps,"type","R");
cals = [ cals ; blanks ; residuals ]; ii = [ ii ; jj ; kk ];
[cals,jj] = matCS_filtersteps(cals,"machine",machine);
kk = find (~isnan(matCS_step_final_value(cals,item)));
cals = cals(kk);
j = ii(jj(kk)); % index to cal steps in run.steps

% run the editor:
quit = 0;
title = sprintf ("*** TOGGLE SLOW-CAL USAGE (%s @ %s) ***",item,machine);
while ~quit
	men = "";
	for i = 1:length(cals) % build menu list of cals
		use = matCS_step_final_usage (cals(i),item);
		if use
			use = "used";
		else
			use = "not used";
		end
		if i == 1
			men = sprintf ('"%s: %s"',matCS_step_identity(cals(i)),use);
		else
			men = sprintf ('%s,"%s: %s"',men,matCS_step_identity(cals(i)),use);
		end
	end
	men = sprintf('k = matCS_menu("%s",%s);',title,men);
	eval (men);
	switch k
		case 0 % exit
			quit = 1;
		otherwise % toggle usage flag of selected slow cal:
			u = matCS_step_final_usage (cals(k),item);
			[u,cals(k)] = matCS_step_final_usage (cals(k),item,not(u));
	end % switch
end % while

% move modified usage flags back to original run data:
run.steps(j) = cals; 
end % function