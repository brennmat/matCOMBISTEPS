function [steps_filtered,k] = matCS_filtersteps (steps,field,value);

% function [steps_filtered,k] = matCS_filtersteps (steps,field,value);
%
% Return steps with field matching a given value.
%
% INPUT:
% steps: array of step structs
% field: name of struct field
% value: value of struct field
%
% OUTPUT:
% steps_filtered: steps where "field = value"
% k: index to the filtered steps in the original steps, i.e.: steps_filtered = steps(k).

steps_filtered = k = [];
for i = 1:length(steps)
	if isfield (steps(i),field)
		fieldvalue = getfield (steps(i),field);
		match = false;
		if isnumeric (fieldvalue)
			match = (fieldvalue == value);
		elseif ischar (fieldvalue)
			match = any (strmatch(fieldvalue,value,"exact"));
		else
			warning (sprintf("matCS_filtersteps: don't know how to handle variable type of field %s!",field));
		end
		if match % add this step to the list:
			k = [ k ; i ];
		end
	else
		warning (sprintf("matCS_filtersteps: step does not contain field '%s' (%s)",field,matCS_step_identity(steps(i))))
	end
end
steps_filtered = steps(k);
