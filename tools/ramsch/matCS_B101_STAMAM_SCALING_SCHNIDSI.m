function scalingfactor = matCS_B101_STAMAM_SCALING_SCHNIDSI (item);

% function scalingfactor = matCS_B101_STAMAM_SCALING_SCHNIDSI (item);
%
% Return a scaling factor for B101 standard amounts. FOR USE WITH CROSSCALIBRATION BETWEEN B101 AND B107 / SIMON SCHNIDER ONLY (overruling by brennmat accepted)! ADJUST SCALING FACTORS MANUALLY TO FIND SUITABLE VALUES, THEN USE THESE TO CHANGE THE STANDARD AMOUNTS OF B101
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
        scalingfactor = 0.035;
        
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
        warning (sprintf("matCS_B101_STAMAM_SCALING_SCHNIDSI: item (%s) unkonwn. Assuming scalinfactor = 1.",item));
        
end

disp (sprintf("matCS_B101_STAMAM_SCALING_SCHNIDSI: scaling standard amount of item %s in B101 by factor %g.",item,scalingfactor));

end % function
