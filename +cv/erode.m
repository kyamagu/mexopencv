%ERODE  Erodes an image by using a specific structuring element
%
%   dst = erode(src)
%   dst = erode(src, 'Element', [0,1,0;1,1,1;0,1,0], ...)
%
% The function erodes the source image using the specified structuring element
% that determines the shape of a pixel neighborhood over which the minimum is
% taken. The function supports the in-place mode. Erosion can be applied
% several ( iterations ) times. In case of multi-channel images, each channel
% is processed independently.
%
% Input:
%     src: Source image.
% Output:
%     dst: Destination image of the same size and type as src.
% Options:
%     'Element': Structuring element used for erosion. By default, a 3 x 3
%                rectangular structuring element is used
%     'Anchor': Position of the anchor within the element. The default value
%               [-1, -1] means that the anchor is at the element center.
%     'iterations': Number of times erosion is applied.
%     'BorderType': Border mode used to extrapolate pixels outside of the
%                   image. default 'Constant'
%     'borderValue': Border value in case of a constant border. The default
%                    value has a special meaning.
%