function s = matCS_read_step (file,options);

% function s = matCS_read_step (file,options);
%
% Load data of a step / file and return a struct containing this data. The input parameter file may contain a wildcard (*) to specifiy a set of files. In this case, s will be a vector of structs containing the data, where each element of the vector corresponds to one step.
%
% INPUT:
% file: string with the path/name of the file to load. Either the full path to the file must be specified or the file name only. If only the filename is given, then the first file in the search path matching this file name is used. If file contains a wildcard, all files matching the pattern are loaded.
% options (optional): string(s) to trigger non-default options. More than one option can be triggered by specifying multiple option strings as a cell string. Possible values:
%    'PEAKS': also read PEAK values (PEAKS are ignored by default to speed up execution)
%    'ZEROS': also read ZERO values (ZEROS are ignored by default to speed up execution)
%    'MOVE_IMPORTED': move data files to IMPORTED folder after reading the file (useful to keep track of new data files that need to be imported and those that have been imported already)
%
% OUTPUT:
% The output stuct (s) is made up by the following fields:
%    file: file name
%    extension: file suffix, which usually hints at the items measured
%    run: analysis run (string)
%    number: step number 
%    type: step type ('S' for sample, 'B' for blank, 'C' for slow cal, 'F' for fast cal, 'X' for anything else)
%    date: date of the analysis (string)
%    inlet_time: time of gas inlet (seconds after midnight)
%    final: struct containing the FINAL values resulting from the regression after analysis, with the following fields:
%        final.XY.val: best-estimate value of the FINAL line corresponding to item XY
%        final.XY.err: error value of the FINAL line corresponding to item XY
%        final.XY.unit: unit of numbers
%    manual_dilution: factor of manual dilution (e.g. if gas was diluted in a non-standard way, of if more than one slug was taken from the pipette). Numbers > 1 indicate that more gas was expanded into the analysis system (MS, GC), values < 1 indicate that less gas was expanded. A value of 1 is assumed if 
%    no value is specified in the data file.
%   machine: name of the machine used for analysis
%    bottle: 'name' of the reservoir containing the cal gas (this will be empty if not applicable)
%    dilution: dilution factor of the reservoir/pipette combination (this will be empty if not applicable)
%    standard.EL-M: standard amount of an item (e.g. HE-4, or SF-6, or Xe-132; this will be empty if not applicable)
%    slug: slug number taken from the reservoir
%    sticker: sticker lines (cell string, the first line usually contains the lab code, e.g. AW,123,456)
%    collectors: collector lines (cell string of size N x 2). The first column contains the collector name(s), the second column the unit(s) of the collector signals.
%    itemdefinitions: item lines (cell array of size N x 4):
%       column-1: name of item/collector pair (string, e.g. HE4F)
%       column-2: element name (string, e.g. HE)
%       column-3: mass (number, e.g. 4.0026)
%       column-4: collector name (string, e.g. F)
%   peaks: PEAK values (see also 'options' input)
%   zeros: ZEROS values (see also 'options' input
        

if nargin > 2
    error ("matCS_read_step: wrong number of input arguments.")
end

if nargin == 1, options = ''; end % no options given, assume defaults

READ_PEAKS = any(strcmp(upper(options),'PEAKS'));
READ_ZEROS = any(strcmp(upper(options),'ZEROS'));
MOVE_IMPORTED = any(strcmp(upper(options),'MOVE_IMPORTED'));

% determine file(s) to be loaded:
if exist ('OCTAVE_VERSION') % running GNU Octave
    files = glob (tilde_expand(file)); % cell string containing all file names matching 'file'

else % running Matlab
    u = dir(file);
    p = fileparts(file); % base path
    for i = 1:length(u)
        files{i} = fullfile (p,u(i).name);
    end

end % if exist ('OCTAVE_VERSION')

% check for wildcards in file:
if length(files) > 1 % more than one file, so loop through all files
    s = [];
    for i = 1:length(files)
        u = matCS_read_step(files{i},options);
        if ~isempty(u) % only append if loading data file was successful
            s = [ s ; u ];
        end
    end
    return % return to caller, don't execute code below, which is for single files only
end


% initialize an empty step:

s.file = '';
s.extension = '';
s.run = '';
s.number = [];
s.type = '';
s.date = '';
s.inlet_time = [];
s.final = [];
s.manual_dilution = 1;
s.bottle = '';
s.dilution = [];
s.slug = [];
s.standard = [];
s.sticker = {};
s.collectors = {};
s.itemdefinitions = {};

try

    file = tilde_expand (file);
    
    [fid,msg] = fopen (file,'rt');
    
    if (fid == -1)
        error (sprintf("matCS_read_step: could not open file %s (%s).",file,msg))
    end
    
    disp (sprintf('matCS_read_step: %s...',file)); fflush (stdout);
    
    [dummdy,name,ext] = fileparts (file);
    s.file = [name ext];
    s.extension = ext(2:end);

    HAVEPEAKS = 0;
    HAVEZEROS = 0;
    
    while (ischar (line = fgetl (fid)))
        % check for comments:
        if any (i = findstr(line,'{'))
            if i > 1
                line = line(1:i-1);
            else
                line = '';
            end
        end
        
        % format line for easier processing afterwards
        line = deblank (line); % remove trailing blanks
        line = fliplr (deblank(fliplr(line))); % remove leading blanks
        line = strrep(line,"\t",' '); % replace tabs by spaces
        ll   = line; % keep upper/lower case of original (for units and stuff)
        line = upper (line); % make sure it's uppercase
        LIN = line(1:min(3,length(line)));
        switch LIN
            case 'PEA'
                if READ_PEAKS
                    x = strsplit (line,' ',true);
                    item = x{2};
                    val = str2num (x{3});
                    t   = str2num (x{4});
                    if ~HAVEPEAKS % struct s does not yet have a 'peaks' field
                        cmd1 = sprintf('s.peaks.%s.val = val;',item);
                        cmd2 = sprintf('s.peaks.%s.t = t;',item);
                        HAVEPEAKS = 1;
                    else  % struct s already has a 'peaks' field                    
                        if ~strcmp(item,fieldnames(s.peaks)) % first peak value for this item, create the item field
                            cmd1 = sprintf('s.peaks.%s.val = val;',item);
                            cmd2 = sprintf('s.peaks.%s.t = t;',item);
                        else % append to existing data
                            cmd1 = sprintf('s.peaks.%s.val = [ s.peaks.%s.val ; val ];',item,item);
                            cmd2 = sprintf('s.peaks.%s.t = [ s.peaks.%s.t ; t ];',item,item);
                        end
                    end     
                    eval (cmd1); eval (cmd2);                    
                end % if READ_PEAKS
            case 'ZER'
                if READ_ZEROS
                    x = strsplit (line,' ',true);
                    item = x{2};
                    val = str2num (x{3});
                    t   = str2num (x{4});
                    if ~HAVEZEROS % struct s does not yet have a 'zeros' field
                        cmd1 = sprintf('s.zeros.%s.val = val;',item);
                        cmd2 = sprintf('s.zeros.%s.t = t;',item);
                        HAVEZEROS = 1;
                    else  % struct s already has a 'zeros' field                    
                        if ~strcmp(item,fieldnames(s.zeros)) % first zero value for this item, create the item field
                            cmd1 = sprintf('s.zeros.%s.val = val;',item);
                            cmd2 = sprintf('s.zeros.%s.t = t;',item);
                        else % append to existing data
                            cmd1 = sprintf('s.zeros.%s.val = [ s.zeros.%s.val ; val ];',item,item);
                            cmd2 = sprintf('s.zeros.%s.t = [ s.zeros.%s.t ; t ];',item,item);
                        end
                    end
                    eval (cmd1); eval (cmd2);
                end % if READ_ZEROS
            case "FIN"
                x = strsplit (line,' ',true);
                item = x{2};
                val = str2num (x{3});
                err = str2num (x{4});
                if length (x) > 4
                    unit = x{5};
                else
                    unit = ''; % some items/collectors (e.g. isotope ratios from the same collectors) don't have units
                end
                item = strrep (item,'/','_'); % replace "/" by "_" in ratios
                if any(findstr(item,"PEAKS"))
                    warning (sprintf("matCS_read_step: ignoring FINAL line with item \"PEAKS\" (file: %s, FINAL line: %s).",file,line));
                elseif any(findstr(item,"ZEROS"))
                    warning (sprintf("matCS_read_step: ignoring FINAL line with item \"ZEROS\" (file: %s, FINAL line: %s).",file,line));            
                else
                    eval (sprintf("s.final.%s.val = %g;",item,val));
                    eval (sprintf("s.final.%s.err = %g;",item,err));
                    eval (sprintf("s.final.%s.unit = '%s';",item,unit));
                end
            case "MAN"
                if findstr (line,'MANUAL_DILUTION')
                    x = strsplit (line,' ',true);
                    s.manual_dilution = str2num (x{2});
                end
            case "TYP"
                x = strsplit (line,' ',true);
                s.type = x{2};
                s.number = str2num (x{3});            
            case "RUN"
                x = strsplit (line,' ',true);
                s.run = x{2};
                s.date = x{3};
                s.machine = x{4};
            case "EVE"
                if findstr(line,'INLET')
                     x = strsplit (line,' ',true);
                     s.inlet_time = str2num (x{3});
                elseif findstr(line,'SEPARATION')
                     x = strsplit (line,' ',true);
                     s.separation_time = str2num (x{3});
                elseif findstr(line,'PUMPOUT')
                     x = strsplit (line,' ',true);
                     s.pumpout_time = str2num (x{3});
                end
            case "STA"                  
                if findstr (line,'STANDARD')
                    x  = strsplit (line,' ',true);
                    xx = strsplit (ll,' ',true);   % use ll instead of line to get original upper/lower case string
                    if isempty(str2num(x{4}))  % replace with "not available" if the standard-amount value is strange (i.e. not numeric)
                        x{4} = 'NA'; 
                    end
                    eval (sprintf("s.standard.%s%s.val = %s;",x{2},x{3},x{4}));
                    if length(x) > 4 % unit given with number
                        eval (sprintf("s.standard.%s%s.unit = '%s';",x{2},x{3},xx{5}));
                    else % no unit given, assuming ccSTP
                        warning (sprintf("matCS_read_step: no units given with STANDARD line (file: %s, line: %s). Assuming unit = ccSTP.",file,line));
                        eval (sprintf("s.standard.%s%s.unit = 'ccSTP';",x{2},x{3}));
                    end
                end  
            case "STI"
                if length (findstr(line,'STICKER'))
                    x = strsplit (line,' ',true);
                    s.sticker{end+1} = x{2};
                end
            case "LAB"
                if length (findstr(line,'LABCODE'))
                    x = strsplit (line,' ',true);
                    s.labcode = x{2};
                end
            case "COL"
                if length (findstr(line,'COLLECTOR'))
                    x = strsplit (line,' ',true);
                    s.collectors{end+1,1} = x{2}; % collector name (e.g. "F" for Faraday)
                    s.collectors{end,2} = x{3}; % units of collector signal (e.g. "A" for Ampere)
                end
            case "ITE"
                if length (findstr(line,'ITEM'))
                    x = strsplit (line,' ',true);
                    s.itemdefinitions{end+1,1} = x{2}; % name of item/collector pair (e.g. "HE4F")
                    s.itemdefinitions{end,2} = x{3}; % element name (e.g. "HE")
                    s.itemdefinitions{end,3} = str2num(x{4}); % element mass (e.g. 4.0026)
                    s.itemdefinitions{end,4} = x{5}; % collector name (e.g. "F")
                end
            case "BOT"
                if length (findstr (line,'BOTTLE'))
                   x = strsplit (line,' ',true);
                   if length(x) < 5
                        warning (sprintf("matCS_read_step: ignoring incomplete BOTTLE line (file: %s, BOTTLE line: %s).",file,line));
                   else
                       s.bottle = x{2};
                       s.slug = str2num (x{4});
                       s.dilution = str2num (x{5});
                   end
                end
    	    case "GEM"
    		if findstr(line,'RUEDI TOTALPRESSURE')
                     x = strsplit (line,' ',true);
                     s.RUEDI_TOTALPRESSURE.val = str2num (x{3});
                     s.RUEDI_TOTALPRESSURE.unit = str2num (x{4});
                elseif findstr(line,'RUEDI')
                     warning (sprintf('matCS_read_step: line with unknown RUEDI key (%s). Ignoring it...',line));
                end
            end
    end
    
    disp ('   ...finished.'); fflush (stdout);
    
    fclose (fid);
    
    if MOVE_IMPORTED % Move file to "IMPORTED" folder:
        i = findstr (file,filesep);
        if any(i) % file path is not current working directory
            u = file(1:i(end));
            filename = file(i(end)+1:end);
        else % file path is current working directory
            u = sprintf("%s%s",pwd,filesep);
            filename = file;
        end
        basedir = u;
        importdir = sprintf("%sIMPORTED%s",u,filesep);
        if ~exist(importdir,"dir") % make sure the IMPORTED directory exists
            [status, msg, msgid] = mkdir (importdir);
        end
        [status, msg, msgid] = movefile (sprintf("%s%s",basedir,filename), sprintf("%s%s",importdir,filename),'f'); % move the file to the IMPORTED directory (and overwrite previous files without asking)
        if status
            disp (sprintf("matCS_read_step: Moved file %s from %s to %s.",filename,basedir,importdir)); fflush(stdout);
        else
            warning (sprintf("matCS_read_step: could not move file %s from %s to %s: %s",filename,basedir,importdir,msg));
        end
    end % if MOVE_IMPORTED
    
    % if this is a RUEDI sample file without a proper and unique labcode, use the provided sticker and the time/date of the measurement to make a (hopefully) unique sample identifier
	if any (findstr(upper(s.machine),'RUEDI'))
	if strcmp (matCS_step_type(s),'S');
		tt           =  datestr(matCS_step_analysis_time(s),'yyyy-mm-dd_HH:MM:SS');
		s.sticker{1} = sprintf ('%s_%s',s.sticker{1},tt);
		disp (sprintf('matCS_read_step: determined unique sample ID (labcode/sticker) for RUEDI data as: %s',s.sticker{1}))

		warning ('matCS_read_step: NEED TO TREAT TOTAL MIMS PRESSURE HERE (SCALING OF STANDARD AMOUNTS, USE RUEDI TOTALPRESSURE KEY...?). NOT YET IMPLEMENTED...');
		
	end
	end
	
catch
    warning (sprintf("matCS_read_step: could not load data, skipping this file (%s).",file))
    s = [];

end_try_catch
    
