function [gas_amount,gas_amount_err,unit,poly,run] = matCS_gasamount (run,machine,item,X_FC_ratio,X_FC_ratio_err,RUEDI_totalpressurenormalize)

% function [gas_amount,gas_amount_err,unit,poly,run] = matCS_gasamount (run,machine,item,X_FC_ratio,X_FC_ratio_err,RUEDI_totalpressurenormalize)
%
% Fit a polynomial curve to the SC/FC ratios vs. gas amounts of a given item/machine, and calculate gas amounts from given S/FC ratios. This only uses the slow-cal data with usage flag = true.
% For RUEDI type measurements, to sum of the partial pressures can be normalized to the measured total pressure of the sample gas

% INPUT:
% run: struct containing the data of the run
% machine: machine name
% item: item name
% X_FC_ratio: ratio of X/fast-cal ratio (where X can be the value of a detector reading of anything: sample, blank, cal, whatever)
% X_FC_ratio_err: error of X_FC_ratio
% RUEDI_totalpressurenormalize (optional): if not zero, the sample partial pressures are scaled such that their sum corresponds to the observed total gas pressure in the sample (default: RUEDI_totalpressurenormalize = 0 )
%
% OUTPUT:
% gas_amount: gas amount(s) corresponding to X_FC_ratio (scalar or vector)
% gas_amount_err: absolute error(s) of gas_amount, estimated from gas_amount_err and the standard deviation of the measured slow-cal data relative to the interpolation from the polynomial (scalar or vector)
% unit: unit of gas amounts (string)
% poly: struct with polynomial info (as used for polyval)
% run: run struct (possibly with newly created 'calpoly_deg.MACHINE.ITEM' fields)

if ~exist('RUEDI_totalpressurenormalize','var')
	RUEDI_totalpressurenormalize = 0;
end

if any (findstr(item,'_'))
    warning (sprintf('matCS_gasamount: processing of item ratios (%s) does not yet work. The guru forgot why, but please ask him to fix this anyway.',item))
    gas_amount = gas_amount_err = repmat (NA,size(X_FC_ratio));
    unit = '--';
    poly = [];
else
    % get slow-cal data:    
    [gas_amount,SC_FC_ratio,SC_FC_ratio_err,stepnumbers,unit] = matCS_run_cal_data (run,machine,item,"use"); % determine SC/FC ratios    

    if isempty (gas_amount)
    	warning ("matCS_gasamount: all slow-cal data has usage flag = false. Cannot determine calibration curve...")
    	gas_amount = gas_amount_err = repmat (NA,size(X_FC_ratio));
    	unit = '?';
    	poly = [];

    else
        % set up weights for weighted fitting (must be strictly positive!)
        weights = 1 ./ abs(SC_FC_ratio_err);
        u = find (weights <= 0);
        if any(u)
            if (length(u) == length(weights)) % all weights are zero
            weights = repmat (1,size(weights));
            else
                weights(u) = min(weights);
            end
        end
        u = find (weights == Inf);
        if any(u)
            if (length(u) == length(weights)) % all weights are Inf
            weights = repmat (1,size(weights));
            else
                weights(u) = min(weights(find(weights < Inf)));
            end
        end

        % fit poly to cal data;
        [n,run] = matCS_run_calpoly_degree (run,machine,item);
        SC_FC_ratio = SC_FC_ratio(:); gas_amount = gas_amount(:); weights = weights(:);
	if length (SC_FC_ratio) <= n
		error (sprintf('matCS_gasamount: number of slow cals and blanks (%i) is too low to calculate calibration cuve using %i-order polynomial. Aborting...',length (SC_FC_ratio),n));
	end
        [p,s] = polyfit (SC_FC_ratio,gas_amount,n);
        poly.p = p; %% poly.s = s; %%%%%% poly.mu = mu;
        
        %%% % calculate gas amounts from poly:
        %%% [gas_amount,gas_amount_err] = polyval (p,X_FC_ratio,s); % best-estimate values
        %%% 
        %%% % error propagation:
        %%% g1                          = polyval (p,X_FC_ratio+abs(X_FC_ratio_err),s);
        %%% g2                          = polyval (p,X_FC_ratio-abs(X_FC_ratio_err),s);
        %%% gas_amount_err              = sqrt ( gas_amount_err.^2 + (g1-g2).^2 );
  
        gas_amount_err = std ( gas_amount(:) - polyval(p,SC_FC_ratio(:),s) ); % st-dev. of difference between true and interpolated SC gas amounts.
        
        gas_amount = polyval (p,X_FC_ratio); % best-estimate values
        gas_amount_err = repmat (gas_amount_err,size(gas_amount));
                
        % error propagation:
        g1                          = polyval (p,X_FC_ratio+abs(X_FC_ratio_err),s);
        g2                          = polyval (p,X_FC_ratio-abs(X_FC_ratio_err),s);
        gas_amount_err              = sqrt ( gas_amount_err.^2 + ((g1-g2)/2).^2 );
        
        % unit = 'ccSTP'; % wild guess
        % warning ('matCS_gasamount: assuming standard amounts are given in ccSTP. That's just a wild guess, and needs improvement...');


    end
end
