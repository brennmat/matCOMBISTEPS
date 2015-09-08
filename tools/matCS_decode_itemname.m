function [element,mass,detector] = matCS_decode_itemname (item)

% function [element,mass,detector] = matCS_decode_itemname (item)
%
% Decode item name. This does not (yet) work for item ratios, but might be possible in the future (e.g. return vectors for 'mass' and 'detector').

% INPUT:
% item: item name (string, e.g. "AR40F")
%
% OUTPUT:
% element: element name (string, e.g. "AR")
% mass: item mass (number, e.g. 40)
% detector: detector name (string, e.g. "M")

if any (findstr(item,'_'))
    warning (sprintf('matCS_decode_itemname: processing of item ratios (%s) does not yet work. Ask the guru to fix this.',item))
    element = '';
    mass = NaN;
    detector = '';
else
    k = repmat([],size(item));
    for i = 1:length(item) % build an index (k) to the numerical entries in item
        u = str2num(item(i));
        k(i) = ~(isempty(u) || iscomplex(u));
    end
    p = find(diff(k));
    if length(p) > 2
        warning (sprintf('matCS_decode_itemname: item name (%s) has too many numbers in it.',item))
    end
    mass = str2num(item(find(k)));
    element = item(1:p(1));
    if p(2) >= length(item)
        warning (sprintf('matCS_decode_itemname: item name (%s) is missing detector name.',item))
        detector = '';
    else
        detector = item(p(2)+1:end);
    end
end