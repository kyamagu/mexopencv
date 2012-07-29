%CVTCOLOR  Converts an image from one color space to another
%
%    dst = cv.cvtColor(src, code)
%    dst = cv.cvtColor(src, code, 'DstCn', 1)
%
% ## Input
% * __src__ Source image: 8-bit unsigned, 16-bit unsigned (CV_16UC...), or
%          single-precision floating-point.
% * __code__ Color space conversion code string. e.g., 'RGB2GRAY'
%
% ## Output
% * __dst__ Destination image of the same size and depth as src.
%
% ## Options
% * __DstCn__ Number of channels in the destination image. If the parameter is
%             0, the number of the channels is derived automatically from src
%             and code.
%
% The function converts an input image from one color space to another. In case
% of a transformation to-from RGB color space, the order of the channels should
% be specified explicitly (RGB or BGR). Note that the default color format in
% OpenCV is often referred to as RGB but it is actually BGR (the bytes are
% reversed). So the first byte in a standard (24-bit) color image will be an
% 8-bit Blue component, the second byte will be Green, and the third byte will
% be Red. The fourth, fifth, and sixth bytes would then be the second pixel
% (Blue, then Green, then Red), and so on.
%
% The conventional ranges for R, G, and B channel values are:
%
%     0 to 255 for uint8 images
%     0 to 65535 for uint16 images
%     0 to 1 for float images
% 
% In case of linear transformations, the range does not matter. But in case of
% a non-linear transformation, an input RGB image should be normalized to the
% proper value range to get the correct results, for example, for RGB L\*u\*v\*
% transformation. For example, if you have a 32-bit floating-point image
% directly converted from an 8-bit image without any scaling, then it will have
% the 0..255 value range instead of 0..1 assumed by the function. So, before
% calling cvtColor, you need first to scale the image down:
%
%     img = cvtColor(img/255, 'BGR2Luv');
%
% If you use cvtColor with 8-bit images, the conversion will have some
% information lost. For many applications, this will not be noticeable but it
% is recommended to use 32-bit images in applications that need the full range
% of colors or that convert an image before an operation and then convert back.
%
