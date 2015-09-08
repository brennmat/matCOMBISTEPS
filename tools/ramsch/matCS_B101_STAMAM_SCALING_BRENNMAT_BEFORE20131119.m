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

    case {"HE"}
        scalingfactor = 0.05888;
        
    case {"NE"}
        scalingfactor = 0.71;
        
    case {"AR"}
        scalingfactor = 0.74;
        
    case {"KR"}
        scalingfactor = 0.50;
        
    case {"XE"}
        scalingfactor = 0.9;
        
    case {"N2"}
        scalingfactor = 0.85;
        
    case {"O2"}
        scalingfactor = 0.89;
        
    case {"SF"}
        scalingfactor = 1.21;
                
    otherwise
        warning (sprintf("matCS_B101_STAMAM_SCALING_BRENNMAT: item (%s) unkonwn. Assuming scalinfactor = 1.",item));
        
end

disp (sprintf("matCS_B101_STAMAM_SCALING_BRENNMAT: scaling standard amount of item %s in B101 by factor %g.",item,scalingfactor));

end % function
