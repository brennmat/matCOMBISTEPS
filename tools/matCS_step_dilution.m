function dilution = matCS_step_dilution (step);

% function dilution = matCS_step_dilution (step);
%
% Return the dilution factor of a step for step. This takes into account the pipette/bottle dilution, slug number, and manual_dilutin factor. Bottle/pipette dilution is analysed only for step types F and C.  The result is therefore (dilution factor)^slug * manual_dilution. For step types other than F or C, NaN is returned.
%
% INPUT:
% step: step struct (see matCS_read_step), or a vector where each element corresponds to one step.
%
% OUTPUT:
% dilution: dilution factor

if ( length(step) > 1 )
	dilution = [];
	for i = 1:length(step)
		dilution = [ dilution ; matCS_step_dilution(step(i)) ];
	end
else
	dilution = 1;
	if any(strcmp(fieldnames(step),"manual_dilution"))
		dilution = step.manual_dilution;
	else
		dilution = 1;
	end
	
	if ( strcmp(step.type,"F") || strcmp(step.type,"C") )
        	% FUNKY USE OF getfield!? dilution = dilution * getfield(step.dilution) ^ getfield(step.slug);
		dilution = dilution * step.dilution^step.slug;
	end
end
