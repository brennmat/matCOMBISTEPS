function run = matCS_run_edit_fastcals (run)

% function run = matCS_run_edit_fastcals (run)
%
% Interactively manipulate fast cals
%
% INPUT:
% run: struct containing the data of the run
%
% OUTPUT:
% run: modified run


[items,machines] = matCS_run_items (run); % get a list of all items in this run
if (length (items) == 0)
    disp ('No FINAL items available!')
else
    quit = 0;
    while ~quit
        men = "ans = matCS_menu ('*** PROCESS RUN -- MANIPULATE FASTCALS -- CHOOSE ITEM ***'";
        for i = 1:length(items)
            men = sprintf ("%s , '%s @ %s'",men,items{i},machines{i});
        end
 %       men = sprintf ("%s , 'Exit');",men);
	men = sprintf ("%s );",men);
        eval (men);
        switch ans
            case 0 % exit
                quit = 1;
            otherwise % show calibration curve of item
		run = __matCS_run_edit_fastcal_item (run,machines{ans},items{ans});
            end
    end
end % if / else
end % function


function run = __matCS_run_edit_fastcal_item (run,machine,item) % manipulate / show calibration curve of a given machine/item
quit = 0;
men = sprintf ("ans = matCS_menu ('*** PROCESS RUN -- MANIPULATE FASTCALS (%s @ %s) ***'",item,machine);
men = sprintf ("%s , '%s'",men,"Plot fastcals vs. time");
men = sprintf ("%s , '%s'",men,"Plot fastcals vs. step number");
men = sprintf ("%s , '%s'",men,"Toggle fastcal usage");
men = sprintf ("%s , '%s'",men,"Modify fastcal pairing");
men = sprintf ("%s , '%s'",men,"Modify fastcal aliases");
%%% men = sprintf ("%s , '%s'",men,"Change fastcal pairing"); NO MORE MANUAL PAIRING!
men = sprintf ("%s );",men);
while ~quit
        eval (men);
        switch ans
            case 0 % exit
                quit = 1;
            case 1 % plot fastcals vs time
                matCS_run_fastcal_plot (run,machine,item,'time');
            case 2 % plot fastcals vs time
                matCS_run_fastcal_plot (run,machine,item,'stepnumber');
            case 3 % edit fastcal usage
                run = __matCS_run_edit_fastcal_usage (run,machine,item);
            case 4 % edit fastcal pairing
                run = __matCS_run_edit_fastcal_pairing (run,machine,item);
            case 5 % edit fastcal aliases
                run = __matCS_run_edit_fastcal_aliases (run,machine,item);
            end

end % while
end % function

function run = __matCS_run_edit_fastcal_usage (run,machine,item) % edit fast-cal usage flags for a given machine/item
% find fastcals for editing:
[fastcals,ii] = matCS_filtersteps(run.steps,"type","F");
[fastcals,jj] = matCS_filtersteps(fastcals,"machine",machine);
kk = [];
kk = find (~isnan(matCS_step_final_value(fastcals,item)));
fastcals = fastcals(kk);
j = ii(jj(kk)); % index to cal faststeps in run.steps

% run the editor:
quit = 0;
title = sprintf ("*** TOGGLE FASTCAL USAGE (%s @ %s) ***",item,machine);
N = length(fastcals);
while ~quit
	men = "";
	for i = 1:N % build menu list of fastcals
		use = matCS_step_final_usage (fastcals(i),item);
		if use
			use = "used";
		else
			use = "not used";
		end
		if i == 1
			men = sprintf ('"%s: %s"',matCS_step_identity(fastcals(i)),use);
		else
			men = sprintf ('%s,"%s: %s"',men,matCS_step_identity(fastcals(i)),use);
		end
	end
	men = sprintf ('%s,"Toggle all"',men);
	men = sprintf ('%s,"Do not use first FC of each day"',men);
	men = sprintf('k = matCS_menu("%s",%s);',title,men);
	eval (men);
	switch k
		case 0 % exit
			quit = 1;
		case N+1 % toggle all
			for i = 1:N % toggle usage flags
				u = matCS_step_final_usage (fastcals(i),item);
				[u,fastcals(i)] = matCS_step_final_usage (fastcals(i),item,not(u));
			end
		case N+2 % Don't use first FC of each day
			t = matCS_step_inlet_time (fastcals); t = t(:);
			[t,it] = sort(t);
			[y,m,d] = datevec (t); % get year, month and day of each fastcal
			d = datenum (y,m,d);
			id = find ([ 1 ; diff(d) ]); % index to first fast-cal per day (relative to sorted time t, i.e. relative to "it"
			id = it(id); % indext to first fast-cal per day (relative to "fastcals" vector)
			for i = 1:length(id)
				[u,fastcals(id(i))] = matCS_step_final_usage (fastcals(id(i)),item,false);
			end
		otherwise % toggle usage flag of selected slow cal:
			u = matCS_step_final_usage (fastcals(k),item);
			[u,fastcals(k)] = matCS_step_final_usage (fastcals(k),item,not(u));
	end % switch
end % while

% move modified usage flags back to original run data:
run.steps(j) = fastcals; 
end % function


function run = __matCS_run_edit_fastcal_pairing (run,machine,item) % edit fast-cal pairing for all steps of a given machine/item
% find steps for editing:
[X,i_X] = matCS_filtersteps (run.steps,'machine',machine);
[fastcals,i_fc] = matCS_filtersteps (X,'type','F'); fastcal_stepnumbers = matCS_step_number(fastcals);

% find non-fastcals, which have the current FINAL item:
%%% complement function seems to be removed from Octave 3.6!? use setdiff instead...
%%% u = complement(i_fc,1:length(X)); i_X = i_X(u); X = X(u); % these are the non-fastcals
u = setdiff( 1:length(X) , i_fc ); i_X = i_X(u); X = X(u);
u = matCS_step_final_items (X);
k = find(any(strcmp(u,item)')');
i_X = i_X(k); X = X(k); % these are the non-fastcals with FINAL items matching the current item

% show a menu/editor of all S/C/B in X with their fastcal pairing
quit = 0;
title = sprintf ("*** SET FASTCAL PAIRING (%s @ %s) ***",item,machine);
N = length(X);
while ~quit
	men = "";
	for i = 1:N % build menu list of fastcals
		pair = matCS_step_fc_pairing (X(i),item);
		if isempty(pair)
            pair = 'INTERPOLATE';
		else
            pair = sprintf ('FC step number %i',pair);
        end
        if i == 1
			men = sprintf ('"%s: %s"',matCS_step_identity(X(i)),pair);
		else
			men = sprintf ('%s,"%s: %s"',men,matCS_step_identity(X(i)),pair);
		end
	end
	men = sprintf ('%s,"Reset all to INTERPOLATE"',men);
	men = sprintf('k = matCS_menu("%s",%s);',title,men);
	eval (men);
	switch k
		case 0 % exit
			quit = 1;
		case N+1 % Reset all to INTERPOLATE
            for i = 1:length(X)
                eval (sprintf('X(i).final.%s.FC_stepnumbers = [];',item));
            end
		otherwise % modify pairing of given step
			fflush (stdout);
			n = input ('Enter step number of fastcal for this step (or leave empty to use interpolation): ', "s");
			n = str2num(n);
			if length(n) > 1
                warning ('matCS_run_edit_fastcals: only one fastcal allowed per step, using only first fastcal...');
                n = n(1);
            end
            if isempty(n)
                eval (sprintf('X(k).final.%s.FC_stepnumbers = [];',item));
			else
                u = find(fastcal_stepnumbers == n);
                if isempty(u) % this is not a fastcal, complain
                    warning ('matCS_run_edi_fastcals: the step number given is not a fastcal. Try again...')
                else % set fastcal pairing:
                    if ~matCS_step_final_usage (fastcals(u),item)
                        warning('matCS_run_edi_fastcals: this fastcal is set to ''unused''. Change fastcal usage or use another fastcal (the fastcal pairing for this has not been changed).')
                    else
                        eval (sprintf('X(k).final.%s.FC_stepnumbers = %i;',item,n));
                    end
                end
			end
	end % switch
end % while

% move modified usage flags back to original run data:
run.steps(i_X) = X; 
end % function



function run = __matCS_run_edit_fastcal_aliases (run,machine,item) % edit fast-cal aliasing for given item

[ALI,MACH] = matCS_run_fastcal_alias (run,machine,item); % get alias setting

% show a menu of all items available in fastcal steps:
[fc,k] = matCS_filtersteps (run.steps,'type','F');
X = run; X.steps = fc;
[itm,mach] = matCS_run_items (X);

if (length (itm) == 0)
    disp ('No fastcal FINAL items available!')
else
    title = sprintf ("*** SET FASTCAL ALIAS (%s @ %s) ***",item,machine);
    quit = 0;
    while ~quit
        men = "";
        for i = 1:length(itm)
        	if ( strcmp(itm{i},ALI) & strcmp(mach{i},MACH) )
	            men = sprintf ("%s , '%s @ %s <-- USING THIS AS FC-ALIAS FOR %s @ %s'",men,itm{i},mach{i},item,machine);
        	elseif ( strcmp(itm{i},item) & strcmp(mach{i},machine) )
        		if isempty (ALI)
        			men = sprintf ("%s , '%s @ %s <-- USING THIS (NO ALIAS)'",men,itm{i},mach{i});
        		else
		            men = sprintf ("%s , '%s @ %s'",men,itm{i},mach{i});
				end
			else
				men = sprintf ("%s , '%s @ %s'",men,itm{i},mach{i});
	        end
        end
        
		men = sprintf('k = matCS_menu("%s"%s);',title,men);
        eval (men);
        switch k
            case 0 % exit
                quit = 1;
            otherwise % select alias
            	[ALI,MACH,run] = matCS_run_fastcal_alias (run,machine,item,itm{k},mach{k}); % set alias
            end
    end % while
end % if / else

end % function
