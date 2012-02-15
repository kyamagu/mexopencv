%DILATE  Dilates an image by using a specific structuring element
%
%    dst = cv.dilate(src)
%    dst = cv.dilate(src, 'Element', [0,1,0;1,1,1;0,1,0], ...)
%
% ## Input
% * __src__ Source image.
%
% ## Output
% * __dst__ Destination image of the same size and type as src.
%
% ## Options
% * __Element__ Structuring element used for dilation. By default, a 3 x 3
%         rectangular structuring element is used
% * __Anchor__ Position of the anchor within the element. The default value
%         [-1, -1] means that the anchor is at the element center.
% * __Iterations__ Number of times dilation is applied.
% * __BorderType__ Border mode used to extrapolate pixels outside of the
%         image. default 'Constant'
% * __BorderValue__ Border value in case of a constant border. The default
%         value has a special meaning.
%
% The function dilates the source image using the specified structuring element
% that determines the shape of a pixel neighborhood over which the maximum is
% taken. The function supports the in-place mode. Dilation can be applied
% several ( iterations ) times. In case of multi-channel images, each channel
% is processed independently.
%
% See also cv.erode
%
