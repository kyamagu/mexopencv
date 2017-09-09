%NIBLACKTHRESHOLD  Performs thresholding on input images using Niblack's technique or some of the popular variations it inspired
%
%     dst = cv.niBlackThreshold(src, k)
%     dst = cv.niBlackThreshold(src, k, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Source 8-bit single-channel image.
% * __k__ The user-adjustable parameter used by Niblack and inspired
%   techniques. For Niblack, this is normally a value between 0 and 1
%   (its absolute value) that is multiplied with the standard deviation and
%   subtracted from the mean (`mean + k * std`).
%
% ## Output
% * __dst__ Destination image of the same size and the same type as `src`.
%
% ## Options
% * __MaxValue__ Non-zero value assigned to the pixels for which the condition
%   is satisfied, used with the `Binary` and `BinaryInv` thresholding types.
%   default 255
% * __Type__ Thresholding type, default 'Binary'. One of:
%   * __Binary__    `dst(x,y) = (src(x,y) > thresh) ? maxValue : 0`
%   * __BinaryInv__ `dst(x,y) = (src(x,y) > thresh) ? 0 : maxValue`
%   * __Trunc__     `dst(x,y) = (src(x,y) > thresh) ? thresh : src(x,y)`
%   * __ToZero__    `dst(x,y) = (src(x,y) > thresh) ? src(x,y) : 0`
%   * __ToZeroInv__ `dst(x,y) = (src(x,y) > thresh) ? 0 : src(x,y)`
% * __BlockSize__ Size of a pixel neighborhood that is used to calculate a
%   threshold value for the pixel: 3, 5, 7, and so on. default 5
% * __Method__ Binarization method to use. By default, Niblack's technique is
%   used. Other techniques can be specified:
%   * __Niblack__ Classic Niblack binarization. See [Niblack1985].
%   * __Sauvola__ Sauvola's technique. See [Sauvola1997].
%   * __Wolf__ Wolf's technique. See [Wolf2004].
%   * __Nick__ NICK technique. See [Khurshid2009].
%
% The function transforms a grayscale image to a binary image according to the
% formulae:
%
% * __Binary__
%
%                  | maxValue, if src(x,y) > T(x,y)
%       dst(x,y) = |
%                  | 0, otherwise
%
% * __BinaryInv__
%
%                  | 0, if src(x,y) > T(x,y)
%       dst(x,y) = |
%                  | maxValue, otherwise
%
% * __Trunc__
%
%                  | T(x,y), if src(x,y) > T(x,y)
%       dst(x,y) = |
%                  | src(x,y), otherwise
%
% * __ToZero__
%
%                  | src(x,y), if src(x,y) > T(x,y)
%       dst(x,y) = |
%                  | 0, otherwise
%
% * __ToZeroInv__
%
%                  | 0, if src(x,y) > T(x,y)
%       dst(x,y) = |
%                  | src(x,y), otherwise
%
% where `T(x,y)` is a local threshold calculated individually for each pixel.
%
% The threshold value `T(x,y)` is determined based on the binarization method
% chosen. For classic Niblack, it is the mean minus `k` times standard
% deviation of `BlockSize x BlockSize` neighborhood of `(x,y)`.
%
% ## References
% [Niblack1985]:
% > Wayne Niblack. "An introduction to digital image processing".
% > Strandberg Publishing Company, 1985.
%
% [Sauvola1997]:
% > Jaakko Sauvola, Tapio Seppanen, Sami Haapakoski, and Matti Pietikainen.
% > "Adaptive document binarization". In Document Analysis and Recognition,
% > Proceedings of the Fourth International Conference on, volume 1,
% > pages 147-152. IEEE, 1997.
%
% [Wolf2004]:
% > Christian Wolf and J-M Jolion. "Extraction and recognition of artificial
% > text in multimedia documents". Pattern Analysis & Applications,
% > 6(4):309-326, 2004.
%
% [Khurshid2009]:
% > Khurram Khurshid, Imran Siddiqi, Claudie Faure, and Nicole Vincent.
% > "Comparison of niblack inspired binarization methods for ancient
% > documents". In IS&T/SPIE Electronic Imaging, pages 72470U-72470U.
% > International Society for Optics and Photonics, 2009.
%
% See also: cv.threshold, cv.adaptiveThreshold, adaptthresh
%
