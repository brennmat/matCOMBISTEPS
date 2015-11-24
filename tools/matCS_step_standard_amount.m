function [stamam,unit] = matCS_step_standard_amount (step,item);

% function [stamam,unit] = matCS_step_standard_amount (step,item);
%
% Return the standard amounts of item in step, if the step is of type C, F, B, or R. The result takes into account the pipette/bottle dilution as well as the manual_dilution factor. For steps of type "B" (blanks), stamam = 0 is returned. If the step type is not C, F, B, or R, a warning will be issued and the result will be NaN. If the step contains no standard amount for the given item, return NaN.
%
% INPUT:
% step: step struct (see matCS_read_step), or a vector where each element corresponds to one step.
%
% OUTPUT:
% stamam: standard amount
% unit: unit standard amount (string)

if ( length(step) > 1 )
	stamam = [];
	for i = 1:length(step)
	        [s,u{i}] = matCS_step_standard_amount(step(i),item);
	        stamam = [stamam ; s ];
	end
	t = matCS_step_type (step); % step types	
%	k = find (~strcmp (t,{'B','R'})); % index of the steps that are not blanks
	k = strcmp(t,'B') | strcmp(t,'R'); k = find (~k); % index of the steps that are not blanks or residuals
	if length (k) == 0 % all steps are blanks or residuals, so nothing is known about the unit. Use units = '';
		unit = '';
	else % at least some of the steps are not blanks, so they might have units
		unit = unique (u(k)); % unit(s) used with non-blanks
		if length (unit) > 1    % check if all units in u{i} are the same and put this in 'unit'
			warning (sprintf('matCS_step_standard_amount: different units used for item %s! You should fix this in your raw data files and re-import the files! Assuming unit = %s...',item,unit{1}));
		end
		unit = unit{1};
	end
	if strcmp (unit,'');
		unit = 'ccSTP';
		warning (sprintf('matCS_step_standard_amount: units of standard amounts not known. You should fix this in your raw data files and re-import the files! Assuming unit = ccSTP',item));
	end

else
    stamam = NaN; unit = '';
    if ~( strcmp(step.type,"F") || strcmp(step.type,"C")  || strcmp(step.type,"B") || strcmp(step.type,"R") )
        warning (sprintf("matCS_step_standard_amounts: step type is not C, F, B, or R (%s).",matCS_step_identity(step)));
    else
	if any(strcmp(step.type,{'B','R'})) % blanks and residuals have no gas
		stamam = 0;
		unit = '';
	else % it's a C or F
		if isempty (step.standard)
			warning (sprintf("matCS_step_standard_amounts: step contains no standard amounts (%s).",matCS_step_identity(step)));
		else
			items = fieldnames (step.standard);

			if findstr (matCS_step_machine(step),'ANTRAWA'); % fix / parse "wrong" item names in standard amounts:
			if ~isempty(j = strmatch("O32",items))
				items{j} = "O2";
				step.standard.O16 = step.standard.O32;
				warning (sprintf("matCS_step_standard_amount: wrong item name (O32) in standard amounts found, assuming O16 instead (step: %s).",matCS_step_identity(step)));
			end
			if ~isempty(j = strmatch("O16",items))
				items{j} = "O2";
				step.standard.O16 = step.standard.O2;
				warning (sprintf("matCS_step_standard_amount: wrong item name (O16) in standard amounts found, assuming O2 instead (step: %s).",matCS_step_identity(step)));
			end
			if ~isempty(j = strmatch("N28",items))
				items{j} = "N2";
				step.standard.N14 = step.standard.N28;
				warning (sprintf("matCS_step_standard_amount: wrong item name (N28) in standard amounts found, assuming N14 instead (step: %s).",matCS_step_identity(step)));
			end
			if ~isempty(j = strmatch("N14",items))
				items{j} = "N2";
				step.standard.N14 = step.standard.N2;
				warning (sprintf("matCS_step_standard_amount: wrong item name (N14) in standard amounts found, assuming N2 instead (step: %s).",matCS_step_identity(step)));
			end
			if ~isempty(j = strmatch("SF66",items))
				items{j} = "SF6";
				step.standard.SF6 = step.standard.SF66;
				warning (sprintf("matCS_step_standard_amount: wrong item name (SF66) in standard amounts found, assuming SF6 instead (step: %s).",matCS_step_identity(step)));
			end
			end
			
			u = item;
			while isempty(str2num(u(end))) % remove non-numeric letters (detector information) from end of item name to get isotope / element / molecule name
				if length(u) > 1
					u = u(1:end-1);
				else
					u = "";
				end
			end

			if length(u) > 1
				item = u;
			else
				error (sprintf("matCS_step_standard_amount: cannot parse item name %s to a meaningful isotope / element / molecule name.",item))
			end

			i = find(strcmp(upper(items),upper(item)));
			if isempty(i)
				warning (sprintf("matCS_step_standard_amounts: step contains no standard amount for item %s (%s)",item,matCS_step_identity(step)));

			else % standard amount is available
				xx = getfield (step.standard,items{i});
				if ~isstruct (xx) % this is an old fashioned data set without units in the standard amounts
					stamam = xx;
					unit   = '';
				else % this is a struct with value and unit
					stamam = xx.val;
					unit   = xx.unit;
				end

				stamam = stamam * matCS_step_dilution (step);
				
				% TWEAK TO HELP CROSS CALIBRATION OF B101 FROM B107
				if length(step.bottle) >= 3
				if strcmp(step.bottle(end-2:end),'101')
                    			% stamam = stamam * matCS_B101_STAMAM_SCALING_SCHNIDSI (item); % determined in run SS02
                    			stamam = stamam * matCS_B101_STAMAM_SCALING_BRENNMAT (item); % determined in run MB15
                		end
				end
                
            		end

				
				
			end % standard amount of given item is available
			            			
		end % any standard amounts in this step?
	end % was this a C or B type step?
end % if ( length(step) > 1 )

end % function
