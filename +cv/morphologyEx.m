%MORPHOLOGYEX  Performs advanced morphological transformations
%
%   dst = morphologyEx(src, op)
%   dst = morphologyEx(src, op, 'Element', [0,1,0;1,1,1;0,1,0], ...)
%
% The function can perform advanced morphological transformations using an
% erosion and dilation as basic operations.
%
% Input:
%     src: Source image.
%	  op: Type of a morphological operation that can be one of the following:
%	     'Open':     an opening operation
%	     'Close':    a closing operation
%	     'Gradient': a morphological gradient
%	     'Tophat':   “top hat”
%	     'Blackhat': “black hat”
% Output:
%     dst: Destination image of the same size and type as src.
% Options:
%     'Element': Structuring element
%     'Anchor': Position of the anchor within the element. The default value
%               [-1, -1] means that the anchor is at the element center.
%     'iterations': Number of times erosion and dilation are applied.
%     'BorderType': Border mode used to extrapolate pixels outside of the
%                   image. default 'Constant'
%     'borderValue': Border value in case of a constant border. The default
%                    value has a special meaning.