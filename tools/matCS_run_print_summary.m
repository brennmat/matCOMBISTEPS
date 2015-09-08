function run = matCS_run_print_summary (run)

% function matCS_run_print_summary (run)
%
% Print summary of a run.
%
% INPUT:
% run: struct containing the data of the run to which the steps will be added
%
% OUTPUT:
% (none)

fflush (stdout);
disp (sprintf("Number of steps: %i",length(run.steps)))
for i = 1:length(run.steps)
%    info = sprintf("Entry %i: Machine = %s, step number = %i, file = %s, type = %s, run = %s, date = %s, manual dilution = %g", i, run.steps(i).machine, run.steps(i).number, run.steps(i).file, run.steps(i).type, run.steps(i).run, run.steps(i).date, run.steps(i).manual_dilution);
    info = sprintf("%i: Machine = %s, step = %i, file = %s, type = %s, run = %s, date = %s, manual dilution = %g", i, run.steps(i).machine, run.steps(i).number, run.steps(i).file, run.steps(i).type, run.steps(i).run, run.steps(i).date, run.steps(i).manual_dilution);
    switch upper(run.steps(i).type)
        case "C"
            info = sprintf ("%s, bottle = %s, dilution = %g", info, run.steps(i).bottle, run.steps(i).dilution);
        case "S"
	    info = sprintf ("%s, lab code = %s", info,  matCS_step_labcode(run.steps(i)));
    end
    disp (info);
    fflush (stdout);
end
end
