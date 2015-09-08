function run = matCS_run_results (run)

% function matCS_run_results (run)
%
% Calculate and export sample results of a given run.
%
% INPUT:
% run: struct containing the data of the run
%
% OUTPUT:
% (none)


[items,machines] = matCS_run_items (run); % get a list of all items / machines in this run
if (length (items) == 0)
	warning ("matCS_run_results: No items available in this run!")
else
	samples = matCS_filtersteps (run.steps,"type","S"); % all steps of type "S"    
	if length(samples) < 1
		warning ("matCS_run_results: No samples available in this run!")
	else


		% interactively select the items that should be processed:
		quit = 0;
		N = length(items);
		use = repmat (true,N,1);
		while ~quit
		    men = "";
		    for i = 1:N % build menu list of items
		        if use(i)
		            u = "used for export";
		        else
		            u = "NOT used for export";
		        end
		        if i == 1
		            men = sprintf ('"%s measured on %s: %s"',items{i},machines{i},u);
		        else
		            men = sprintf ('%s,"%s measured on %s: %s"',men,items{i},machines{i},u);
		        end
		    end
		    men = sprintf ('%s,"Toggle all"',men);
		    men = sprintf('k = matCS_menu("*** SET ITEMS FOR DATA EXPORT ***",%s);',men);
		    eval (men);
		    switch k
		        case 0 % exit
		            quit = 1;
		        case N+1 % toggle all
		            use = ~use;
		        otherwise % toggle usage flag of selected slow cal:
		            use(k) = ~use(k);
		    end % switch
		end % while loop to handle the menu
		% process selection from menu:
		itm = mach = {};
		for i = 1:length(items)
		    if use(i)
		        itm{end+1} = items{i};
		        mach{end+1} = machines{i};
		    end
		end        
		if length(itm) == 0
		    disp ('matCS_run_results: no items selected for export. Aborting...'); fflush(stdout);
		    return
		end
		% throw out unused items / machines:
		items = itm;
		machines = mach;
		

		% Get S/FC ratios for all sample steps and all items
		disp ('matCS_run_results: determining S/FC ratios. Please wait...'); fflush (stdout);
		ratios = ratios_err = res = res_err = repmat (NA,length(samples),length(items));
		for i = 1:length(items) % get S/FC ratios
		    disp (sprintf('...processing %s (%s)...',items{i},machines{i})); fflush (stdout);

		    [s,m] = matCS_filtersteps (samples,"machine",machines{i}); % all steps measured on the machine of the current item
		    [ratios(m,i),ratios_err(m,i)] = matCS_step_final_fc_ratio (run,samples(m),items{i}); % get S/FC ratios and errors
		end;
		disp ('...done.'); fflush (stdout);


		% Calculate gas amounts corresponding to S/FC ratios
		disp ('matCS_run_results: determining gas amounts (or isotope ratios). Please wait...'); fflush (stdout);
		units = {};
		for i = 1:length(items)
		    disp (sprintf('...processing %s (%s)...',items{i},machines{i})); fflush (stdout);
		    
	%            if strcmp(items{i},'CFC113E')
	%                keyboard
	%            end
	%            
	%            if strcmp(items{i},'HE4F')
	%                keyboard
	%            end
		    
		    %%% [res(:,i),res_err(:,i),units{i},dummy,run] = matCS_gasamount (run,machines{i},items{i},ratios(:,i),ratios_err(:,i));
		    

			[res(:,i),res_err(:,i),units{i}] = matCS_gasamount (run,machines{i},items{i},ratios(:,i),ratios_err(:,i)); 
		end
		disp ('...done.'); fflush (stdout);


		% Combine all steps / gas amounts into a list of unique lab codes
		labcodes = unique (matCS_step_labcode(samples));
		X = X_err = repmat (NA,length(labcodes),length(items)); % matrices for the final results (gas amounts and istotope ratios corresponding to the different labcodes)       
		for i = 1:length(labcodes) % process each labcode
			% build an index (k) to the sample steps with labcode{i}
			k = [];
			for j = 1:length(samples)
				if strcmp (labcodes{i},matCS_step_labcode(samples(j)))
					k = [ k j ];
				end
			end

			% warning ('matCS_run_results: DATA EXPORT IS WHACKY? WHY ARE SOME RESULTS MISSING / NA IN THE OUTPUT FILE? FIX THIS!')
			% I __think__ I fixed this. The for, while and if/else statements were not balanced in the right place (there was an 'end' missing, and anotherone was where no 'end' should have been).



			R = R_err = [];
		    	for j = 1:length(k) % combine results from different steps for labcode{i} (in array R):
		        	R     = [ R     ; res(k(j),:)     ];
		        	R_err = [ R_err ; res_err(k(j),:) ];
		    	end % for j = 1:length(k)
			if size(R,1) > 1 % there is more than one step associated with labcode{i}, so let's check for duplicate values of a given item/machine for labcode{i}:
			    	na = ~isnan (R); % index to all numeric values in R (i.e. values which are not NA or NaN)
				u  =  find (sum(na) > 1); % find entries in R that have more than one value
				if ~isempty(u) % there is at least one entry with more than one value
					for e = 1:length(u)
				    		LABCODE = labcodes{i};
				    		if isempty(LABCODE)
				        		LABDODE = '[NO LABCODE]';
						end
				    	end
					warning (sprintf('matCS_run_results: there are multiple sample steps with labcode %s containing FINAL values for item %s. Was the same labcode used twice for different samples by mistake? You should fix this to avoid loss of some of these data (remove steps from run, fix data files, and reload these steps)!',LABCODE,items{u(e)}));
				    	info = matCS_step_identity (samples(k));
				    	disp ('Steps involved:');
				    	disp(info); fflush (stdout);
					input ('Press ENTER to continue...','s');
			       	end % if ~isempty(u)
			end % if size(R,1) > 1
			for k = 1:size(R,2) % merge down R and R_err to one line for labcode{i}
				l = find(~isnan(R(:,k))); 	% find line with numeric value in k-th column
				if ~isempty(l)
					l = l(1);
					R(1,k)     = R(l,k);		% copy numeric value in k-th column to first line
					R_err(1,k) = R_err(l,k);	% copy numeric value in k-th column to first line
				end
			end
			X(i,:)     = R(1,:);
			X_err(i,:) = R_err(1,:);
		end % for i = 1:length(labcodes) // process each labcode


		% Export results to data file:
		name = [];
		while isempty (name)
			name = input ("Enter name of data file (e.g. 'MB14.csv'): ","s");
		end;
		disp (sprintf("Writing results to data file %s in %s...",name,pwd)); fflush (stdout);
		[fid,msg] = fopen (name,"wt");
		if fid == -1
			error (sprintf("Could not open file for writing: %s",msg))
		else
			% write main header line (with full item information):
		        fprintf (fid,"LABCODE ; ");
		        for i = 1:length(items)
		            if i < length(items)
		                fprintf (fid,"%s on %s (%s) ; ",items{i},machines{i},units{i});
		                fprintf (fid,"Err. %s on %s (%s) ; ",items{i},machines{i},units{i});
		            else
		                fprintf (fid,"%s on %s (%s) ; ",items{i},machines{i},units{i});
		                fprintf (fid,"Err. %s on %s (%s)\n",items{i},machines{i},units{i});
		            end
		        end % for i = 1...

		        % write 2nd header line (useful for ANTRAWA database):
		        fprintf (fid,"LAB_CODE ; ");
		        for i = 1:length(items)
				[el,mass] = matCS_decode_itemname (items{i});
				if length(el) == 2 % this is likely an element shorcut. Format this as requested by the ANTRAWA database:
					if ~strcmp(items{i},'SF6E')
						el(1) = toupper(el(1));
						el(2) = tolower(el(2));
					end
				end
		            	header = sprintf('%s_%i',el,mass);
				if i < length(items)
					fprintf (fid,"%s ; ",header);
					fprintf (fid,"%s_err ; ",header);
				else
					fprintf (fid,"%s ; ",header);
					fprintf (fid,"%s_err\n",header);
				end
			end % for i = 1...
		        
		        % write data values:
		        for i = 1:length(labcodes)                
				fprintf (fid,"%s ; ",labcodes{i});
				for j = 1:length(items)
				        if j < length(items)
				            fprintf (fid,"%g ; ",X(i,j));
				            fprintf (fid,"%g ; ",X_err(i,j));
				        else
				            fprintf (fid,"%g ; ",X(i,j));
				            fprintf (fid,"%g\n",X_err(i,j));
				        end % if / else
				end % for j = ...
			end % for i = ...
			fclose (fid);        
			disp ("...writing results to data file finished."); fflush (stdout);
		end % if data file ok for writing?


	end % if any samples in this run?
end % if any items in this run?
