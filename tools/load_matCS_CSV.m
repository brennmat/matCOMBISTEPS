function [X,header,sample,time] = load_matCS_CSV (filename);

% function [X,header,sample,time] = load_matCS_CSV (filename);
%
% Loads data from a CSV results file produced by matCOMBISTEPS
%
% INPUT:
% 'filename': file name (incl. path) of the CSV file containing the data
%
% OUTPUT:
% X: data values (matrix)
% header: header (cell string with column titles)
% sample: sample name (first column)
% time: if date/time information in included in sample name, 'time' contains the corresponding datenum

[fid,msg] = fopen (filename);
if fid < 0
	error (msg);
end

X = [];
header = {};
sample = {};

n = 1;
while (l = fgetl (fid)) ~= -1
	disp (sprintf('load_matCS_CSV: reading line %i...',n));
	if ~strcmp (l(1),'%') % this is a comment line, ignore it
		l = strtrim(l); % remove white space
		
		fflush (stdout);
		
		if n < 3 % header line
			l = strsplit(l,';');			
			l = l(2:end); % remove 'LABCODE' column
			if length(header) == 0
				header = l;
			else
				header = { header ; l };
			end
			
		else
			l = strtrim (strsplit(l,';'));
			
			% parse sample name (first column)
			sample{end+1} = l{1};
			
			% parse data values
			x = [];
			for i = 2:length(l)
				x = [ x , str2num(l{i}) ];
			end
						
			X = [ X ; x ];
			
		end
		
		n = n+1;
				
	end
end
fclose (fid);

% parse date/time information (if possible)
disp ('load_matCS_CSV: parsing date/time information (if possible)...'); fflush (stdout);

time = repmat (NaN,size(sample));
for i = 1:length(sample)
	if length(sample{i}) > 19
		x = sample{i}(end-18:end);
		if ( strcmp(x(5),'-') & strcmp(x(8),'-') & strcmp(x(11),'_') & strcmp(x(14),':') & strcmp(x(17),':') ) % format is YYYY-MM-DD_hh:mm:ss
			time(i) = datenum(strrep (x,'_',' '));
		end
	end
end

% clean header entries from trailing spaces:
for i = 1:length(header{1})
	header{1}{i} = deblank (header{1}{i});
	header{1}{i} = fliplr (deblank(fliplr(header{1}{i})));
	header{2}{i} = deblank (header{2}{i});
	header{2}{i} = fliplr (deblank(fliplr(header{2}{i})));
end

disp ('load_matCS_CSV: ...done.');
