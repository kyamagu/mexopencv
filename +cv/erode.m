%ERODE  Erodes an image by using a specific structuring element
%
%    dst = cv.erode(src)
%    dst = cv.erode(src, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ input image; the number of channels can be arbitrary, but the
%       depth should be one of `uint8`, `uint16`, `int16`, `single` or
%       `double`.
%
% ## Output
% * __dst__ output image of the same size and type as `src`.
%
% ## Options
% * __Element__ Structuring element used for erosion. By default, a 3x3
%       rectangular structuring element is used `ones(3)`. Kernel can be
%       created using cv.getStructuringElement
% * __Anchor__ Position of the anchor within the element. The default value
%       [-1, -1] means that the anchor is at the element center.
% * __Iterations__ Number of times erosion is applied. default 1
% * __BorderType__ Border mode used to extrapolate pixels outside of the
%       image. default 'Constant'
% * __BorderValue__ Border value in case of a constant border. The default
%       value has a special meaning which gets automatically translated to the
%       maximum value of the image class type (`intmax(class(img))` for
%       integer types and `realmax(class(img))` for floating-point types).
%       See cv.morphologyDefaultBorderValue
%
% The function erodes the source image using the specified structuring element
% that determines the shape of a pixel neighborhood over which the minimum is
% taken:
%
%    dst(x,y) = min_{(xp,yp): Element(xp,yp)!=0} src(x+xp, y+yp)
%
% Erosion can be applied several (`Iterations`) times. In case of
% multi-channel images, each channel is processed independently.
%
% See also: cv.dilate, cv.morphologyEx, cv.getStructuringElement, imerode
%
