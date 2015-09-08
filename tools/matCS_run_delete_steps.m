function run = matCS_run_delete_steps (run)

% function run = matCS_run_delete_steps (run)
%
% Interactively delete steps from a run.
%
% INPUT:
% run: struct containing the data of the run from which the steps will be deleted
%
% OUTPUT: run struct with steps deleted

quit = 0;
while ~quit
    matCS_run_print_summary (run);
    ans = input ("Enter number of entry to remove or X to exit: ","s");
    switch upper(ans)
    case "X"
        quit = 1;
    otherwise
        i = str2num (ans);
        if ~isempty(i)
        ans
            if ( i > 0 & i <= length(run.steps) )
                disp (sprintf('Removing entry %i...',i)); fflush (stdout);
                if ( i == 1 )
                    run.steps = run.steps(2:end);
                elseif ( i == length(run.steps) )
                    run.steps = run.steps(1:end-1);
                else
                    run.steps = [ run.steps(1:i-1) ; run.steps(i+1:end) ];
                end
                warning ('propagate step deletion to FC and B pairing!')
            else
                disp (sprintf('No such entry (%i).',i)); fflush (stdout);
            end
        end
    end
end
end