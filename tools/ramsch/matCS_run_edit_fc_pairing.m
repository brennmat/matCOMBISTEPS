function run = matCS_run_fc_pairing (run,machine,item)

% function run = matCS_run_fc_pairing (run,machine,item)
%
% Interactively set fast-cal pairing.
%
% INPUT:
% run: struct containing the data of the run
% machine: machine name
% item: item name
%
% OUTPUT: run struct with new/modified FC pairing

quit = 0;
while ~quit
    ans = matCS_menu ('*** PROCESS RUN -- FC PAIRING ***',...
                'Choose and apply default FC pairing',...
                'Show and edit FC pairing');
    switch ans
        case 0 % exit
            quit = 1;
        case 1 % default FC pairing
            run = __fc_pairing_default (run,machine,item);
        case 2 % show and edit FC pairing
            run = __fc_pairing_edit (run,machine,item);
    end
end
end


function run = __fc_pairing_edit (run,machine,item)
% find closest fast cals before and after each step (only if from the same day, otherwise only use one)
t = upper (matCS_step_type (run.steps));
i = strcmp ("F",t);
i_X  = find (not(i)); % index to non-FC steps

% only apply FC pairing to steps that acutually have FINAL items matching the current item
u = [];
for i = 1:length(i_X)  % filter items from i_X with non-empty FINALS values of the current item
    if any(strmatch(item,matCS_step_final_items(run.steps(i_X(i)))))
        u = [ u i_X(i) ];
    end
end
i_X = u; % index to non-FC steps with FINAL value of the current ITEM

quit = 0;
while ~quit
    men = sprintf("ans = matCS_menu ('*** CHOOSE STEP TO EDIT FC PAIRING FOR ITEM %s ***'",item);
    for i = 1:length(i_X)
        step_ident  = matCS_step_identity(run.steps(i_X(i)));
        fc_stepnums = num2str(matCS_step_fastcal_steps(run.steps(i_X(i)),item));
        men = sprintf ("%s , 'Fast-cal steps used for step [%s]: %s'",men,step_ident,fc_stepnums);
    end
    men = sprintf ("%s , 'Plot FC values...');",men);
    eval (men);
    switch ans
        case 0 % exit
            quit = 1;
        case length(i_X)+1 % exit
            matCS_run_fastcal_plot (run,machine,item);
        otherwise % edit step
		disp(sprintf("Editing step [%s]...",matCS_step_identity(run.steps(i_X(ans)))))
		n = input ("Enter fast-cal step number(s), separated by spaces: ","s");
		n = str2num(n);
		valid = 1;
		for i = 1:length(n)
			s = matCS_run_getstep (run,run.steps(i_X(i)).machine,n(i));
			if isempty (s)
			    valid = 0;
			    break
			elseif ~strcmp("F",matCS_step_type(s));
			    valid = 0;
			    break
			end
		end % for
		if valid
			eval (sprintf("run.steps(i_X(ans2)).final.%s.FC_stepnumbers = n;",item));
            	else
			warning ("matCS_run_fc_pairing: the given step number(s) do not correspond to fast cals. Ignoring this step...")
            	end % if valid
    end % switch
end % while
end % function


function run = __fc_pairing_default (run)
error ("matCS_run_edit_fc_pairing: function __fc_pairing_default needs to be revised (machine / item is known already!)"

[items,machines] = matCS_run_items (run); % get a list of all items in this run
if (length (items) == 1)
    disp ('No items available!')
else
    quit = 0;
    while ~quit
        men = "ans = matCS_menu ('*** PROCESS RUN -- CHOOSE ITEMS TO SET DEFAULT FC PAIRING ***'";
        for i = 1:length(items)
	    men = sprintf ("%s , '%s @ %s'",men,items{i},machines{i});
        end
        men = sprintf ("%s , 'All items (use same default pairing for all items)');",men);
        eval (men);
        switch ans
            case 0 % exit
                quit = 1;
            case length(items)+1 % all items
                disp (sprintf('%s -- DEFAULT FC PAIRING NOT YET IMPLEMENTED...',"ALL ITEMS"))
            otherwise % edit item
                item = items{ans};
		machine = machines{ans};

                % find closest fast cals before and after each step (only if from the same day, otherwise only use one)
                t = upper (matCS_step_type (run.steps));
                i = strcmp ("F",t);
                i_FC = find (i);
                i_X  = find (not(i));
                
                % only apply FC pairing to steps that acutually have FINAL items matching the current item
                u = [];
                for i = 1:length(i_X)                
                    if any(strmatch(item,matCS_step_final_items(run.steps(i_X(i)))))
                        u = [ u i_X(i) ];
                    end
                end
                i_X = u;
                
                % only use fast cals that actually have FINAL item matching the current item:
                u = [];
                for i = 1:length(i_FC)                
                    if any(strmatch(item,matCS_step_final_items(run.steps(i_FC(i)))))
                        u = [ u i_FC(i) ];
                    end
                end
                i_FC = u;
                
                % find suitable default fast-cals for all non-fast-cal steps
                t_FC = matCS_step_inlet_time (run.steps(i_FC));
                t_X  = matCS_step_inlet_time (run.steps(i_X));

                for i = 1:length(i_X)
                    tt = t_FC - t_X(i);
                    t1 = max(tt(find(tt < 0)));
			if ~isempty(t1)
				i1 = i_FC(find (tt == t1));
			else i1 = [];
		    end;
                    t2 = min(tt(find(tt > 0)));
			if ~isempty(t2)
				i2 = i_FC(find (tt == t2));
			else i2 = [];
		    end;

                    if ( isempty(i1) && isempty(2) )
                        warning (sprintf("matCS_run_fc_pairing: did not find any suitable default fast-cal steps for given step (%s)",matCS_step_identity(i_X(i))))
                        ii = [];
                    elseif isempty(i2)
                        ii = run.steps(i1).number;
                    elseif isempty(i1)
                        ii = run.steps(i2).number;
                    else
                        ii = [run.steps(i1).number run.steps(i2).number];
                    end
                    eval (sprintf("run.steps(i_X(i)).final.%s.FC_stepnumbers = ii;",item));
                end
            end
    end
end
end
