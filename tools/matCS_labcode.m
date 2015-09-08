function labcode = matCS_labcode (sticker);

% function labcode = matCS_labcode (sticker);
%
% Extract the lab code from a sticker.
%
% INPUT:
% sticker: cell string containing the lines of a sticker block. The first line is assumed to contain the lab code.
%
% OUTPUT:
% labcode: lab code (string)

labcode = sticker{1};