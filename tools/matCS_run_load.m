function run = matCS_run_load ()

% function run = matCS_run_load (run)
%
% Interactively load run data from disk.
%
% INPUT:
% (none)
%
% OUTPUT: run loaded from disk

quit = 0;
while ~quit
    % f = input (sprintf("Enter full name of data file including path (absolute or relative to current path %s): ",pwd),"s");
    f = input (sprintf("Enter full name of data file including path (absolute or relative to current path)\n   current path %s\n   Enter path-to-file: ",pwd),"s");
    [dir,name,ext] = fileparts (f);
    if ~strcmp(ext,'.mat')
        f = sprintf ("%s.mat",f);
    end
    f = tilde_expand (f);
    if ~exist (f,"file")
        disp (sprintf('File %s does not exist, try again.',f));
    else
        run = load (f);
        run = run.run;
        run.file = f;
        quit = 1;
    end
end
end