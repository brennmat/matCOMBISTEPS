function run = matCS_run_save (run)

% function run = matCS_run_save (run)
%
% Interactively save run data to disk.
%
% INPUT:
% run: struct containing the data of the run to which the steps will be added
%
% OUTPUT: run struct with updated "file" field

if isempty (run.file)
    run.file = input (sprintf("Enter full name of data file including path (absolute or relative to current path %s): ",pwd),"s");
    if ~findstr(run.file,'.mat');
        run.file = sprintf ("%s.mat",run.file);
        run.file = tilde_expand (run.file);
    end
end
quit = 0;
while ~quit
    ans = menu ('*** PROCESS RUN -- SAVE RUN ***',...
                sprintf('Change file name or path (currently: %s)',run.file),...
                'Save changes',...
                'Abort');
    switch ans
        case 1
            run.file = input (sprintf("Enter full name of data file including path (absolute or relative to current path %s): ",pwd),"s");
            [dir,name,ext] = fileparts (run.file);
            if strcmp(ext,'.mat');
                run.file = sprintf ("%s.mat",run.file);
                run.file = tilde_expand (run.file);
            end
        case 2
            save ("-V7",run.file,"run");
            quit = 1;
        case 3
            quit = 1;
    end
end
end