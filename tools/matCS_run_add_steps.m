function run = matCS_run_add_steps (run)

% function run = matCS_run_add_steps (run)
%
% Interactively add steps to a run.
%
% INPUT:
% run: struct containing the data of the run to which the steps will be added
%
% OUTPUT: run struct with steps added

f = input (sprintf("Enter name of data file including path (absolute or relative to current path %s, use '*' as wildcard): ",pwd),"s");
    steps = matCS_read_step (f);
        
    for i = 1:length(steps) % add pairing fields (empty FC and B pairing)
        items = matCS_step_final_items (steps(i));
        if ~any(strmatch(steps(i).type,"F","exact"))
            disp (sprintf("Adding empty FC pairs (machine %s, step %i, type %s)",steps(i).machine,steps(i).number,steps(i).type)); fflush (stdout); 
            for j = 1:length(items)
                eval (sprintf("steps(i).final.%s.FC_stepnumbers = [];",items{j}));
            end
        end
    end
    
    warning ('add empty pairing info fo B pairs -- not yet implemented.');


    if isempty (run.steps)
        run.steps = steps;
    else
        quit = 0;
        while ~quit
            ans = input (sprintf("Replace (R) all previous steps or append (A) to existing steps and replace duplicates? ",pwd),"s");
            switch upper(ans)
                case "R"
                    run.steps = steps;
                    disp ('Replaced all previous steps by new data. Check pairing etc.!')
                    quit = 1;
                case "A"
                    for i = 1:length(steps) % check if this step exists already (if yes: replace it, if not: append it) 
                        duplicate = 0;
                        for j = 1:length(run.steps) % check for duplicates
                            if (steps(i).number == run.steps(j).number)                 % same step number?
                            if strmatch(steps(i).type,run.steps(j).type,"exact")        % same step type?
                            if strmatch(steps(i).machine,run.steps(j).machine,"exact")  % same machine?
                                disp (sprintf('Replacing duplicate (machine %s, step %i, type %s)...',run.steps(j).machine,run.steps(j).number,run.steps(j).type)); fflush (stdout);
                                run.steps(j) = steps(i);
                                duplicate = 1;
                                break; % continue with next step
                            end end end % ends of ifs
                        end % end of for j = ...
                        if ~duplicate % no duplicate found
                            disp (sprintf('Adding step (machine %s, step %i, type %s)...',run.steps(j).machine,run.steps(j).number,run.steps(j).type)); fflush (stdout);
                            run.steps  = [ run.steps ; steps(i) ];
                        end
                    end % end for for i = ...
                    disp ('...finished')
%                   warning ('matCS_run_process, __add_steps: THIS RUN MAY NOW CONTAIN THE SAME STEPS MORE THAN ONCE! ADD A CHECK FOR THIS TO THE CODE!')
                    quit = 1;
            end
        end
    end
end