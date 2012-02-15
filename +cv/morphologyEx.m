%MORPHOLOGYEX  Performs advanced morphological transformations
%
%    dst = cv.morphologyEx(src, op)
%    dst = cv.morphologyEx(src, op, 'Element', [0,1,0;1,1,1;0,1,0], ...)
%
% ## Input
% * __src__ Source image.
% * __op__ Type of a morphological operation that can be one of the following:
% * __Open__ an opening operation
% * __Close__ a closing operation
% * __Gradient__ a morphological gradient
% * __Tophat__ top hat
% * __Blackhat__ black hat
%
% ## Output
% * __dst__ Destination image of the same size and type as src.
%
% ## Options
% * __Element__ Structuring element
% * __Anchor__ Position of the anchor within the element. The default value
%         [-1, -1] means that the anchor is at the element center.
% * __Iterations__ Number of times erosion and dilation are applied.
% * __BorderType__ Border mode used to extrapolate pixels outside of the
%         image. default 'Constant'
% * __BorderValue__ Border value in case of a constant border. The default
%         value has a special meaning.
%
% The function can perform advanced morphological transformations using an
% erosion and dilation as basic operations.
%
