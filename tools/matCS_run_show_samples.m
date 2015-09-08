function matCS_run_show_samples (run)

% function matCS_run_show_samples (run)
%
% Show sample data of a given item / machine (list of labcodes, step numbers, S/FC ratios with FC dilution correction, and gas amounts)
%
% INPUT:
% run: struct containing the data of the run
%
% OUTPUT:
% (none)


[items,machines] = matCS_run_items (run); % get a list of all items in this run
if (length (items) == 0)
    disp ('No items available!')
else
    quit = 0;
    while ~quit
        men = "ans = matCS_menu ('*** PROCESS RUN -- SHOW SAMPLE RESULTS -- CHOOSE ITEM ***'";
        for i = 1:length(items)
            men = sprintf ("%s , '%s @ %s'",men,items{i},machines{i});
        end
	men = sprintf ("%s );",men);
        eval (men);
        switch ans
            case 0 % exit
                quit = 1;
            otherwise % show sample data
                __matCS_show_samples (run,machines{ans},items{ans});
            end
    end
end


function run = __matCS_show_samples (run,machine,item) % show sample results of a given item / machine
% Print a list / table with LABCODE ; STEP-NUMBER ; S/FC RATIO ; ERR.S/FC RATIO ; GAS AMOUNT ; ERR. GAS AMOUNT

[X,i_X]     = matCS_filtersteps (run.steps,'machine',machine);
[X,i_X]     = matCS_filtersteps (X,'type','S');
labcodes    = matCS_step_labcode (X);
[R,R_err]   = matCS_step_final_fc_ratio (run,X,item); % get S/FC ratios and errors

k = find(~isnan(R));

if isempty(k)
    warning (sprintf("__matCS_show_samples: there are no samples with item %s measured on %s!",item,machine))
else
    labcodes = labcodes(k);
    R = R(k); R_err = R_err(k);
    [A,A_err,unit] = matCS_gasamount (run,machine,item,R,R_err);
    stepnumbers = matCS_step_number (X(k));
    analysistime = matCS_step_analysis_time (X(k));
    disp (sprintf("SAMPLE RESULTS (%s @ %s)",item,machine))
    printf ("Labcode \t Step \t \t Analysis time \t S/FC-0 \t err. S/FC-0 \t Gas amount (%s) \t err. Gas amount (%s)\n",unit,unit)
    for i = 1:length(labcodes) % print results
	tt = datestr (analysistime(i),'yyyy-mm-dd_HH:MM:SS');
        printf ("%s \t %i \t %s \t %g \t %g \t %g \t %g\n",labcodes{i},stepnumbers(i),tt,R(i),R_err(i),A(i),A_err(i));
    end

    % plot results in calibration curve
    plot (R,A,'o');
    title (sprintf('%s (%s)',item,machine));
    xlabel ('S/FC-0');
    ylabel (sprintf('Gas amount (%s)',unit));

    % plot results vs. analysis time
    figure();
    plot (analysistime,A,'o');
    title (sprintf('%s (%s)',item,machine));
    xlabel ('Analysis time (datenum)');
    ylabel (sprintf('Gas amount (%s)',unit));

end
