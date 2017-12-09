%COPYTO  Copies the matrix to another one
%
%     dst = cv.copyTo(src)
%     dst = cv.copyTo(src, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Input matrix.
%
% ## Output
% * __dst__ Destination matrix of the same size and type as `src`.
%
% ## Options
% * __Dest__ Used to initialize destination matrix. Not set by default.
% * __Mask__ Optional operation mask of the same size as `src`. Its non-zero
%   elements indicate which matrix elements need to be copied. The mask has to
%   be of type `uint8` or `logical` and can have 1 or multiple channels.
%   Not set by default.
%
% The method copies the matrix data to another matrix. Before copying the data,
% the destination matrix is allocated if needed, initialized with all zeros.
%
% See also: cv.convertTo, roipoly, poly2mask
%
