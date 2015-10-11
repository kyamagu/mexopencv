%BOUNDINGRECT  Calculates the up-right bounding rectangle of a point set
%
%    rct = cv.boundingRect(points)
%    rct = cv.boundingRect(mask)
%
% ## Input
% * __points__ Input 2D point set, stored in numeric array
%       (Nx2/Nx1x2/1xNx2) or cell array of 2-element vectors (`{[x,y], ...}`).
%       Supports integer (`int32`) and floating point (`single`) classes.
% * __mask__ Binary mask, a 1-channel NxM 8-bit or logical matrix.
%
% ## Output
% * __rct__ Output rectangle `[x,y,w,h]`.
%
% The function calculates and returns the minimal up-right bounding rectangle
% for the specified point set.
%
