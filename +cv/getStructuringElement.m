%GETSTRUCTURINGELEMENT  Returns a structuring element of the specified size and shape for morphological operations
%
%    elem = cv.getStructuringElement('OptionName', optionValue, ...)
%
%
% ## Output
% * __elem__ Output structuring element of specified shape and size.
%
% ## Options
% * __Shape__ Element shape, default 'Rect'. Could be one of:
%       * __Rect__ a rectangular structuring element: `E(i,j)=1`
%       * __Ellipse__ a cross-shaped structuring element: `E(i,j)=1` if
%             `i=Anchor(2)` or `j=Anchor(1)`, `E(i,j)=0` otherwise.
%       * __Cross__ an elliptic structuring element, that is, a filled ellipse
%             inscribed into the rectangle `[0, 0, KSize(1), KSize(2)]`.
% * __KSize__ Size of the structuring element `[w,h]`. default [3,3].
% * __Anchor__ Anchor position within the element. The default value (-1,-1)
%       means that the anchor is at the center. Note that only the shape of a
%       cross-shaped element depends on the anchor position. In other cases
%       the anchor just regulates how much the result of the morphological
%       operation is shifted.
%
% The function constructs and returns the structuring element that can be
% further passed to cv.erode, cv.dilate or cv.morphologyEx. But you can also
% construct an arbitrary binary mask yourself and use it as the structuring
% element.
%
% See also: cv.sepFilter2D, cv.getDerivKernels, cv.getGaussianKernel
%
