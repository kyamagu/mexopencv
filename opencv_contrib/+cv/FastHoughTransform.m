%FASTHOUGHTRANSFORM  Calculates 2D Fast Hough transform of an image
%
%     dst = cv.FastHoughTransform(src)
%     dst = cv.FastHoughTransform(src, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ The source (input) image.
%
% ## Output
% * __dst__ The destination image, result of transformation.
%
% ## Options
% * __DDepth__ The depth of destination image. Default `int32`.
% * __Op__ The operation to be applied. This specifies binary operations, that
%   is such ones which involve two operands. Formally, a binary operation `f`
%   on a set `S` is a binary relation that maps elements of the Cartesian
%   product `SxS` to `S`: `f: SxS -> S`. Default 'Addition'. One of
%   * __Minimum__ Binary minimum operation. The constant specifies the binary
%     minimum operation `f` that is defined as follows: `f(x, y) = min(x, y)`.
%   * __Maximum__ Binary maximum operation. The constant specifies the binary
%     maximum operation `f` that is defined as follows: `f(x, y) = max(x, y)`.
%   * __Addition__ Binary addition operation. The constant specifies the binary
%     addition operation `f` that is defined as follows: `f(x, y) = x + y`.
%   * __Average__ Binary average operation. The constant specifies the binary
%     average operation `f` that is defined as follows: `f(x, y) = (x + y)/2`.
% * __AngleRange__ The part of Hough space to calculate. Each member specifies
%   primarily direction of lines (horizontal or vertical) and the direction of
%   angle changes. Direction of angle changes is from multiples of 90 to odd
%   multiples of 45. The image considered to be written top-down and
%   left-to-right. Angles are started from vertical line and go clockwise.
%   Separate quarters and halves are written in orientation they should be in
%   full Hough space. Default `ARO_315_135`. One of:
%   * **ARO_0_45** Vertical primarily direction and clockwise angle changes.
%   * **ARO_45_90** Horizontal primarily direction and counterclockwise angle
%     changes.
%   * **ARO_90_135** Horizontal primarily direction and clockwise angle
%     changes.
%   * **ARO_315_0** Vertical primarily direction and counterclockwise angle
%     changes.
%   * **ARO_315_45** Vertical primarily direction.
%   * **ARO_45_135** Horizontal primarily direction.
%   * **ARO_315_135** Full set of directions.
%   * **ARO_CTR_HOR** `90 +/- atan(0.5)`, interval approximately from `64.5`
%     to `116.5` degrees. It is used for calculating Fast Hough Transform for
%     images skewed by `atan(0.5)`.
%   * **ARO_CTR_VER** `0 +/- atan(0.5)`, interval approximately from `333.5`
%     (`-26.5`) to `26.5` degrees. It is used for calculating Fast Hough
%     Transform for images skewed by `atan(0.5)`.
% * __MakeSkew__ Specifies to do or not to do skewing of Hough transform
%   image. The enum specifies to do or not to do skewing of Hough transform
%   image so it would be no cycling in Hough transform image through borders
%   of image. Default 'Deskew'. One of:
%   * __Raw__ Use raw cyclic image.
%   * __Deskew__ Prepare deskewed image.
%
% The function calculates the fast Hough transform for full, half or quarter
% range of angles.
%
% See also: cv.HoughPoint2Line, cv.HoughLines, hough, houghlines, houghpeaks
%
