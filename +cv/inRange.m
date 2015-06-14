%INRANGE  Checks if array elements lie between the elements of two other arrays
%
%    dst = cv.inRange(src, lowerb, upperb)
%
% ## Input
% * __src__ first input array.
% * __lowerb__ inclusive lower boundary array or a scalar.
% * __upperb__ inclusive upper boundary array or a scalar.
%
% ## Output
% * __dst__ output array of the same size as `src` and of logical type.
%
% The function checks the range as follows:
%
% - For every element of a single-channel input array:
%
%         dst(i,j,..) = lowerb(i,j,..,1) <= src(i,j,..,1) <= upperb(i,j,..,1)
%
% - For two-channel arrays:
%
%         dst(i,j,..) = lowerb(i,j,..,1) <= src(i,j,..,1) <= upperb(i,j,..,1) and
%                       lowerb(i,j,..,2) <= src(i,j,..,2) <= upperb(i,j,..,2)
%
% - and so forth.
%
% That is, `dst(i,j,...)` is set to true if `src(i,j,...,:)` is within the
% specified 1D, 2D, 3D, ... box and false otherwise.
%
% When the lower and/or upper boundary parameters are scalars, the indexes at
% `lowerb` and `upperb` in the above formulas should be omitted.
%
% See also: cv.threshold
%
