%GETSTRUCTURINGELEMENT  Returns Gaussian filter coefficients
%
%    elem = cv.getStructuringElement('OptionName', optionValue, ...)
%
%
% ## Output
% * __elem__ Output structuring element.
%
% ## Options
% * __Shape__ Element shape that could be one of 'Rect', 'Ellipse', or
%        'Cross'. Default 'Rect'.
% * __KSize__ Size of the structuring element. default 3.
% * __Anchor__ Anchor position within the element. The default value
%        (-1,-1) means that the anchor is at the center. Note that only the
%        shape of a cross-shaped element depends on the anchor position. In
%        other cases the anchor just regulates how much the result of the
%        morphological operation is shifted.
%
% The function constructs and returns the structuring element that can be
% further passed to cv.erode, cv.dilate or cv.morphologyEx. But you can
% also construct an arbitrary binary mask yourself and use it as the
% structuring element.
%
% See also cv.sepFilter2D cv.getDerivKernels cv.getGaussianKernel
%
