function scalingfactor = matCS_B101_STAMAM_SCALING_BRENNMAT (item);

% function scalingfactor = matCS_B101_STAMAM_SCALING_BRENNMAT (item);
%
% Return a scaling factor for B101 standard amounts. IDEA: MAKE REPL4 RESULTS CONSISTENT WITH ASW CONCENTRATIONS.
%>
% Corrected (true) standard amount of B101 = scalinfactor x uncorrected-standard-amount
%
% INPUT:
% item: item name.
%
% OUTPUT:
% scalingfactor: scaling factor for standard amount of given item.

item = upper(item);
ITM = item([1:2]);

switch ITM

%%    case {"HE"}
%%        scalingfactor = 0.5131; % from air sample (AG,26,1001)
%%        
%%    case {"NE"}
%%        scalingfactor = 0.60214; % from air sample (AG,26,1001)
%%        
%%    case {"AR"}
%%        scalingfactor = 0.728; % from air sample (AG,26,1001)
%%        
%%    case {"KR"}
%%        scalingfactor = 0.44692; % from air sample (AG,26,1001)
%%        
%%    case {"XE"}
%%        scalingfactor = 0.35486; % from air sample (AG,26,1001)
%%        
%%    case {"N2"}
%%        scalingfactor = 0.84608; % from air sample (AG,26,1001)
%%        
%%    case {"O2"}
%%        scalingfactor = 0.90466; % from air sample (AG,26,1001)
%%        
%%    case {"SF"}
%%        scalingfactor = 1.21; % from EMPA-Standard

    case {"HE"}
        scalingfactor = 0.56740; % from REPL4 samples in MB15 (assuming ASW)
        
    case {"NE"}
        scalingfactor = 0.30101; % from REPL4 samples in MB15 (assuming ASW)
        
    case {"AR"}
        scalingfactor = 0.78346; % from REPL4 samples in MB15 (assuming ASW)
        
    case {"KR"}
        scalingfactor = 0.56210; % from REPL4 samples in MB15 (assuming ASW)
        
    case {"XE"}
        scalingfactor = 0.53691; % from REPL4 samples in MB15 (assuming ASW)
        
    case {"N2"}
        scalingfactor = 0.7016; % from REPL4 samples in MB15 (assuming ASW)
        
    case {"O2"}
        scalingfactor = 0.75025; % from REPL4 samples in MB15 (assuming ASW)
        
    case {"SF"}
        scalingfactor = 0.75407;  % from REPL4 samples in MB15 (assuming ASW)


    otherwise
        warning (sprintf("matCS_B101_STAMAM_SCALING_BRENNMAT: item (%s) unkonwn. Assuming scalinfactor = 1.",item));
        
end

%% scalingfactor = scalingfactor * 1.3294;

disp (sprintf("matCS_B101_STAMAM_SCALING_BRENNMAT: scaling standard amount of item %s in B101 by factor %g.",item,scalingfactor));

end % function
