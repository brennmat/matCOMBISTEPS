function run = matCS_run_edit (run)

% function run = matCS_run_edit (run)
%
% This function is used to interactively process a run. This is done by the following consecutive steps:
% 1. Load data files
% 2. Determine pairing of S, C and B with fast cals
% 4. Determine pairing of S and C with blanks
% 5. Calculate gas amounts in samples
%   5.1: normalize S, C and B with fast cals
%   5.2: subtract blanks from S and C
%   5.3: determine gas amounts as function of detector signals and apply the inverse of this function on the sample signals
% 6. Export results to a data file
%
% INPUT:
% run (optional): struct containing all data and information on the run. If 'run' is not specified, an empty run is initialized (the user may load an existing run from disk)
%
% OUTPUT:
% run: struct containing the processed run


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Main function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

quit = 0;

if nargout == 0
	warning ("matCS_run_edit was invoked with no output arguments.");
	ans = input ("Continue anyway (Y/N)?","s");
	if ~strcmp(upper(ans),"Y")
		quit = 1;
		disp ("Aborting...")
	end
end

if ~quit
if ~exist("run","var") % init an empty run
    disp ("Creating new empty run..."); fflush (stdout);
    run = [];
    run.file = [];
    run.steps = [];
end
end

% show main menu

while ~quit
    ans = matCS_menu ('*** PROCESS RUN -- MAIN MENU ***',...
                'Add or replace steps (load data files)',...
                'Remove steps',...
                'Fast cals',...
%                'Blanks',...
                'Slow cals and blanks',...
                'Show samples',...
                'Export results',...
                'Show run overview',...
		'Sort steps');
%                'Save current state',...
%                'Load previous state'
%    		);

    try % in case an error occurrs we don't want to loose all the work.
    switch ans
        case 0 % Exit
		quit = 1;
		disp ("Remember to save your changes to this run!")
        case 1 % add/replace steps
            run = matCS_run_add_steps (run);
        case 2 % delete steps
            run = matCS_run_delete_steps (run);
        case 3 % fast cals
            run = matCS_run_edit_fastcals (run);
        case 4 % slow cals and blanks
            run = matCS_run_edit_cals (run);
        case 5 % Show sample data
            run = matCS_run_show_samples (run);
        case 6 % Export sample results
            run = matCS_run_results (run);
        case 7 % Export results
            matCS_run_print_summary (run);
	    case 8 % sort steps
	        run = matCS_run_sort_steps (run);
 %       case 7 % save current state
 %           run = matCS_run_save (run);
 %       case 8 % load run from disk
 %           run = matCS_run_load;
 %       case 9 % Exit
        otherwise
            warning ('matCS_run_edit: NOT YET IMPLEMENTED! COMPLAIN!')
    end

    catch
    	warning (sprintf("An error occurred: %s. Please ask a magician to fix this.",lasterr))
    end

end
