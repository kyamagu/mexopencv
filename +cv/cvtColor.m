%CVTCOLOR  Converts an image from one color space to another
%
%    dst = cv.cvtColor(src, code)
%    dst = cv.cvtColor(src, code, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Input image: 8-bit unsigned, 16-bit unsigned, or
%          single-precision floating-point.
% * __code__ Color space conversion code string, e.g., 'RGB2GRAY'.
%       The following codes are supported:
%       * __BGR2BGRA__, __RGB2RGBA__: add alpha channel to RGB and BGR image
%       * __BGRA2BGR__, __RGBA2RGB__: remove alpha channel from RGB and BGR
%         image
%       * __BGR2RGBA__, __RGB2BGRA__, __RGBA2BGR__, __BGRA2RGB__, __BGR2RGB__,
%         __RGB2BGR__, __BGRA2RGBA__, __RGBA2BGRA__: convert between RGB and
%         BGR color spaces (with or without alpha channel)
%       * __BGR2GRAY__, __RGB2GRAY__, __GRAY2BGR__, __GRAY2RGB__,
%         __GRAY2BGRA__, __GRAY2RGBA__, __BGRA2GRAY__, __RGBA2GRAY__: convert
%         between RGB/BGR and grayscale
%       * __BGR2BGR565__, __RGB2BGR565__, __BGR5652BGR__, __BGR5652RGB__,
%         __BGRA2BGR565__, __RGBA2BGR565__, __BGR5652BGRA__, __BGR5652RGBA__:
%         convert between RGB/BGR and BGR565 (16-bit images)
%       * __GRAY2BGR565__, __BGR5652GRAY__: convert between grayscale and
%         BGR565 (16-bit images)
%       * __BGR2BGR555__, __RGB2BGR555__, __BGR5552BGR__, __BGR5552RGB__,
%         __BGRA2BGR555__, __RGBA2BGR555__, __BGR5552BGRA__, __BGR5552RGBA__:
%         convert between RGB/BGR and BGR555 (16-bit images)
%       * __GRAY2BGR555__, __BGR5552GRAY__: convert between grayscale and
%         BGR555 (16-bit images)
%       * __BGR2XYZ__, __RGB2XYZ__, __XYZ2BGR__, __XYZ2RGB__: convert between
%         RGB/BGR and CIE XYZ
%       * __BGR2YCrCb__, __RGB2YCrCb__, __YCrCb2BGR__, __YCrCb2RGB__: convert
%         between RGB/BGR and luma-chroma (aka YCC)
%       * __BGR2YUV__, __RGB2YUV__, __YUV2BGR__, __YUV2RGB__: convert between
%         RGB/BGR and YUV
%       * __BGR2HSV__, __RGB2HSV__, __HSV2BGR__, __HSV2RGB__, **BGR2HSV_FULL**,
%         **RGB2HSV_FULL**, **HSV2BGR_FULL**, **HSV2RGB_FULL**: convert between
%         RGB/BGR and HSV (hue saturation value)
%       * __BGR2HLS__, __RGB2HLS__, __HLS2BGR__, __HLS2RGB__, **BGR2HLS_FULL**,
%         **RGB2HLS_FULL**, **HLS2BGR_FULL**, **HLS2RGB_FULL**: convert between
%         RGB/BGR and HLS (hue lightness saturation)
%       * __BGR2Lab__, __RGB2Lab__, __Lab2BGR__, __Lab2RGB__, __LBGR2Lab__,
%         __LRGB2Lab__, __Lab2LBGR__, __Lab2LRGB__: convert between RGB/BGR
%         and CIE Lab
%       * __BGR2Luv__, __RGB2Luv__, __Luv2BGR__, __Luv2RGB__, __LBGR2Luv__,
%         __LRGB2Luv__, __Luv2LBGR__, __Luv2LRGB__: convert between RGB/BGR
%         and CIE Luv
%       * **YUV2RGB_NV12**, **YUV2BGR_NV12**, **YUV2RGB_NV21**,
%         **YUV2BGR_NV21**, __YUV420sp2RGB__, __YUV420sp2BGR__,
%         **YUV2RGBA_NV12**, **YUV2BGRA_NV12**, **YUV2RGBA_NV21**,
%         **YUV2BGRA_NV21**, __YUV420sp2RGBA__, __YUV420sp2BGRA__,
%         **YUV2RGB_YV12**, **YUV2BGR_YV12**, **YUV2RGB_IYUV**,
%         **YUV2BGR_IYUV**, **YUV2RGB_I420**, **YUV2BGR_I420**,
%         __YUV420p2RGB__, __YUV420p2BGR__, **YUV2RGBA_YV12**,
%         **YUV2BGRA_YV12**, **YUV2RGBA_IYUV**, **YUV2BGRA_IYUV**,
%         **YUV2RGBA_I420**, **YUV2BGRA_I420**, __YUV420p2RGBA__,
%         __YUV420p2BGRA__, **YUV2GRAY_420**, **YUV2GRAY_NV21**,
%         **YUV2GRAY_NV12**, **YUV2GRAY_YV12**, **YUV2GRAY_IYUV**,
%         **YUV2GRAY_I420**, __YUV420sp2GRAY__, __YUV420p2GRAY__:
%         YUV 4:2:0 family to RGB
%       * **YUV2RGB_UYVY**, **YUV2BGR_UYVY**, **YUV2RGB_Y422**,
%         **YUV2BGR_Y422**, **YUV2RGB_UYNV**, **YUV2BGR_UYNV**,
%         **YUV2RGBA_UYVY**, **YUV2BGRA_UYVY**, **YUV2RGBA_Y422**,
%         **YUV2BGRA_Y422**, **YUV2RGBA_UYNV**, **YUV2BGRA_UYNV**,
%         **YUV2RGB_YUY2**, **YUV2BGR_YUY2**, **YUV2RGB_YVYU**,
%         **YUV2BGR_YVYU**, **YUV2RGB_YUYV**, **YUV2BGR_YUYV**,
%         **YUV2RGB_YUNV**, **YUV2BGR_YUNV**, **YUV2RGBA_YUY2**,
%         **YUV2BGRA_YUY2**, **YUV2RGBA_YVYU**, **YUV2BGRA_YVYU**,
%         **YUV2RGBA_YUYV**, **YUV2BGRA_YUYV**, **YUV2RGBA_YUNV**,
%         **YUV2BGRA_YUNV**, **YUV2GRAY_UYVY**, **YUV2GRAY_YUY2**,
%         **YUV2GRAY_Y422**, **YUV2GRAY_UYNV**, **YUV2GRAY_YVYU**,
%         **YUV2GRAY_YUYV**, **YUV2GRAY_YUNV**: YUV 4:2:2 family to RGB
%       * __RGBA2mRGBA__, __mRGBA2RGBA__: alpha premultiplication
%       * **RGB2YUV_I420**, **BGR2YUV_I420**, **RGB2YUV_IYUV**,
%         **BGR2YUV_IYUV**, **RGBA2YUV_I420**, **BGRA2YUV_I420**,
%         **RGBA2YUV_IYUV**, **BGRA2YUV_IYUV**, **RGB2YUV_YV12**,
%         **BGR2YUV_YV12**, **RGBA2YUV_YV12**, **BGRA2YUV_YV12**:
%         RGB to YUV 4:2:0 family
%       * __BayerBG2BGR__, __BayerGB2BGR__, __BayerRG2BGR__, __BayerGR2BGR__,
%         __BayerBG2RGB__, __BayerGB2RGB__, __BayerRG2RGB__, __BayerGR2RGB__,
%         __BayerBG2GRAY__, __BayerGB2GRAY__, __BayerRG2GRAY__,
%         __BayerGR2GRAY__: Demosaicing
%       * **BayerBG2BGR_VNG**, **BayerGB2BGR_VNG**, **BayerRG2BGR_VNG**,
%         **BayerGR2BGR_VNG**, **BayerBG2RGB_VNG**, **BayerGB2RGB_VNG**,
%         **BayerRG2RGB_VNG**, **BayerGR2RGB_VNG**: Demosaicing using
%         Variable Number of Gradients
%       * **BayerBG2BGR_EA**, **BayerGB2BGR_EA**, **BayerRG2BGR_EA**,
%         **BayerGR2BGR_EA**, **BayerBG2RGB_EA**, **BayerGB2RGB_EA**,
%         **BayerRG2RGB_EA**, **BayerGR2RGB_EA**: Edge-Aware Demosaicing
%
% ## Output
% * __dst__ Output image of the same row/column size and depth as `src`.
%
% ## Options
% * __DstCn__ Number of channels in the destination image. If the parameter is
%             0, the number of the channels is derived automatically from
%             `src` and `code`.
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
% * 0 to 255 for `uint8` images
% * 0 to 65535 for `uint16` images
% * 0 to 1 for floating-point images (`single` and `double`)
%
% In case of linear transformations, the range does not matter. But in case of
% a non-linear transformation, an input RGB image should be normalized to the
% proper value range to get the correct results, for example, for `RGB` to
% `L*u*v*` transformation. For example, if you have a 32-bit floating-point
% image directly converted from an 8-bit image without any scaling, then it
% will have the 0..255 value range instead of 0..1 assumed by the function.
% So, before calling cv.cvtColor, you need first to scale the image down:
%
%     img = cvtColor(img./255, 'BGR2Luv');
%
% If you use cv.cvtColor with 8-bit images, the conversion will have some
% information lost. For many applications, this will not be noticeable but it
% is recommended to use 32-bit images in applications that need the full range
% of colors or that convert an image before an operation and then convert
% back.
%
% If conversion adds the alpha channel, its value will set to the maximum of
% corresponding channel range: 255 for `uint8`, 65535 for `uint16`, and 1 for
% `single`.
%
% ---
%
% # Color Conversions
%
% ## RGB &#8660; GRAY
%
% Transformations within RGB space like adding/removing the alpha channel,
% reversing the channel order, conversion to/from 16-bit RGB color (`R5:G6:B5`
% or `R5:G5:B5`), as well as conversion to/from grayscale using:
%
%    RGB[A] to Gray: Y = 0.299*R + 0.587*G + 0.114*B
%
% and
%
%    Gray to RGB[A]: R = Y, G = Y, B = Y, A = max(ChannelRange)
%
% The conversion from a RGB image to gray is done with:
%
%    bwsrc = cv.cvtColor(src, 'RGB2GRAY');
%
%  More advanced channel reordering can also be done with cv.mixChannels.
%
% See also: 'BGR2GRAY', 'RGB2GRAY', 'GRAY2BGR', 'GRAY2RGB'
%
% ## RGB &#8660; CIE XYZ.Rec 709 with D65 white point
%
%    [X;Y;Z] = [0.412453, 0.357580, 0.180423;
%               0.212671, 0.715160, 0.072169;
%               0.019334, 0.119193, 0.950227] * [R;G;B]
%
%    [R;G;B] = [3.240479, -1.53715, -0.498535;
%              -0.969256,  1.875991, 0.041556;
%               0.055648, -0.204043, 1.057311] * [X;Y;Z]
%
% `X`, `Y`, and `Z` cover the whole value range (in case of floating-point
% images, `Z` may exceed 1).
%
% See also: 'BGR2XYZ', 'RGB2XYZ', 'XYZ2BGR', 'XYZ2RGB'
%
% ## RGB &#8660; YCrCb JPEG (or YCC)
%
%    Y = 0.299*R + 0.587G + 0.114B
%    Cb = (R-Y)*0.713 + delta
%    Cr = (B-Y)*0.564 + delta
%    R = Y + 1.403*(Cr-delta)
%    G = Y - 0.714*(Cr-delta) - 0.344*(Cb-delta)
%    B = Y + 1.773*(Cb-delta)
%
% where
%
%            / 128    for 8-bit images
%    delta = | 32768  for 16-bit images
%            \ 0.5    for floating-point images
%
% `Y`, `Cr`, and `Cb` cover the whole value range.
%
% See also: 'BGR2YCrCb', 'RGB2YCrCb', 'YCrCb2BGR', 'YCrCb2RGB'
%
% ## RGB &#8660; HSV
%
% In case of 8-bit and 16-bit images, `R`, `G`, and `B` are converted to the
% floating-point format and scaled to fit the 0 to 1 range.
%
%    V = max(R,G,B)
%    S = / (V - min(R,G,B)) / V               if V != 0
%        \ 0                                  otherwise
%        / 60*(G-B) / (V - min(R,G,B))        if V=R
%    H = | 120 + 60*(B-R) / (V - min(R,G,B))  if V=G
%        \ 240 + 60*(R-G) / (V - min(R,G,B))  if V=B
%
% If `H<0` then `H=H+360`. On output `0<=V<=1`, `0<=S<=1`, `0<=H<=360`.
%
% The values are then converted to the destination data type:
%
% * 8-bit images: `V=255*V`, `S=255*S`, `H=H/2` (to fit to 0 to 255)
% * 16-bit images: (currently not supported) `V=65535*V`, `S=65535*S`, `H=H`
% * 32-bit images: `H`, `S`, and `V` are left as is
%
% See also: 'BGR2HSV', 'RGB2HSV', 'HSV2BGR', 'HSV2RGB'
%
% ## RGB &#8660; HLS
%
% In case of 8-bit and 16-bit images, `R`, `G`, and `B` are converted to the
% floating-point format and scaled to fit the 0 to 1 range.
%
%    Vmax = max(R,G,B)
%    Vmin = min(R,G,B)
%    L = (Vmax + Vmin)/2
%    S = / (Vmax - Vmin)/(Vmax + Vmin)      if L <  0.5
%        \ (Vmax - Vmin)/(2-(Vmax + Vmin))  if L >= 0.5
%        / 60*(G-B) / (Vmax - Vmin)         if Vmax=R
%    H = | 120 + 60*(B-R) / (Vmax - Vmin)   if Vmax=G
%        \ 240 + 60*(R-G) / (Vmax - Vmin)   if Vmax=B
%
% If `H<0` then `H=H+360`. On output `0<=L<=1`, `0<=S<=1`, `0<=H<=360`.
%
% The values are then converted to the destination data type:
%
% * 8-bit images: `L=255*L`, `S=255*S`, `H=H/2` (to fit to 0 to 255)
% * 16-bit images: (currently not supported) `L=65535*L`, `S=65535*S`, `H=H`
% * 32-bit images: `H`, `S`, and `L` are left as is
%
% See also: 'BGR2HLS', 'RGB2HLS', 'HLS2BGR', 'HLS2RGB'
%
% ## RGB &#8660; CIE L*a*b*
%
% In case of 8-bit and 16-bit images, `R`, `G`, and `B` are converted to the
% floating-point format and scaled to fit the 0 to 1 range.
%
%    [X;Y;Z] = [0.412453, 0.357580, 0.180423;
%               0.212671, 0.715160, 0.072169;
%               0.019334, 0.119193, 0.950227] * [R;G;B]
%
%    X = X/Xn, where Xn = 0.950456
%    Z = Z/Zn, where Zn = 1.088754
%
%    L = / 116 * Y^(1/3) - 16   for Y >  0.008856
%        \ 903.3 * Y            for Y <= 0.008856
%
%    a = 500*(f(X) - f(Y)) + delta
%    b = 200*(f(Y) - f(Z)) + delta
%
% where
%
%    f(t) = / t^(1/3)           for t <  0.008856
%           \ 7.787*t + 16/116  for t >= 0.008856
%
% and
%
%    delta = / 128  for 8-bit images
%            \ 0    for floating-point images
%
% This outputs `0<=L<=100`, `-127<=a<=127`, `-127<=b<=127`. The values are
% then converted to the destination data type:
%
% * 8-bit images: `L=L*255/100`, `a=a+128`, `b=b+128`
% * 16-bit images: (currently not supported)
% * 32-bit images: `L`, `a`, and `b` are left as is
%
% See also: 'BGR2Lab', 'RGB2Lab', 'Lab2BGR', 'Lab2RGB'
%
% ## RGB &#8660; CIE L*u*v*
%
% In case of 8-bit and 16-bit images, `R`, `G`, and `B` are converted to the
% floating-point format and scaled to fit 0 to 1 range.
%
%    [X;Y;Z] = [0.412453, 0.357580, 0.180423;
%               0.212671, 0.715160, 0.072169;
%               0.019334, 0.119193, 0.950227] * [R;G;B]
%
%    L = / 116 * Y^(1/3) - 16   for Y >  0.008856
%        \ 903.3 * Y            for Y <= 0.008856
%
%    u' = 4*X/(X + 15*Y + 32*Z)
%    v' = 9*Y/(X + 15*Y + 32*Z)
%
%    u = 13*L*(u' - un), where un = 0.19793943
%    v = 13*L*(v' - vn), where vn = 0.46831096
%
% This outputs `0<=L<=100`, `-134<=u<=220`, `-140<=v<=122`.
%
% The values are then converted to the destination data type:
%
% * 8-bit images: `L=255/100*L`, `u=255/354*(u+134), `v=255/262*(v+140)`
% * 16-bit images: (currently not supported)
% * 32-bit images: `L`, `u`, and `v` are left as is
%
% The above formulae for converting RGB to/from various color spaces have been
% taken from multiple sources on the web, primarily from the Charles Poynton
% site http://www.poynton.com/ColorFAQ.html
%
% See also: 'BGR2Luv', 'RGB2Luv', 'Luv2BGR', 'Luv2RGB'
%
% ## Bayer &#8660; RGB
%
% The Bayer pattern is widely used in CCD and CMOS cameras. It enables you to
% get color pictures from a single plane where `R`, `G`, and `B` pixels
% (sensors of a particular component) are interleaved as follows:
%
%    R   G   R   G   R
%    G  (B) (G)  B   G
%    R   G   R   G   R
%    G   B   G   B   G
%    R   G   R   G   R
%
% The output RGB components of a pixel are interpolated from 1, 2, or 4
% neighbors of the pixel having the same color. There are several
% modifications of the above pattern that can be achieved by shifting the
% pattern one pixel left and/or one pixel up. The two letters `C1` and `C2` in
% the conversion constants `Bayer(C1)(C2)2BGR` and `Bayer(C1)(C2)2RGB`
% indicate the particular pattern type. These are components from the second
% row, second and third columns, respectively. For example, the above pattern
% has a very popular "BG" type.
%
% See also: 'BayerBG2BGR', 'BayerGB2BGR', 'BayerRG2BGR', 'BayerGR2BGR',
%           'BayerBG2RGB', 'BayerGB2RGB', 'BayerRG2RGB', 'BayerGR2RGB'
%
%
% See also: rgb2gray, rgb2hsv, rgb2lab, rgb2ntsc, rgb2xyz, rgb2ycbcr,
%  hsv2rgb, lab2rgb, lab2xyz, xyz2lab, xyz2rgb, ycbcr2rgb, ntsc2rgb,
%  makecform, applycform, cv.demosaicing
%
