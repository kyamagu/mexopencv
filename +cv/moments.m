%MOMENTS  Calculates all of the moments up to the third order of a polygon or rasterized shape
%
%    mo = cv.moments(array)
%    mo = cv.moments(array, 'OptionName', optionValue, ...)
%
% ## Input
% * __array__ Raster image (single-channel, 8-bit or floating-point 2D array),
%       or a cell array of 2D points (of `int32` or `single` type) of the
%       form `{[x,y], ...}`.
%
% ## Output
% * __mo__ Output moments. A structure with the following fields:
%       * Spatial moments: __m00__, __m10__, __m01__, __m20__, __m11__,
%           __m02__, __m30__, __m21__, __m12__, __m03__
%       * Central moments: __mu20__, __mu11__, __mu02__, __mu30__, __mu21__,
%           __mu12__, __mu03__
%       * Central normalized moments: __nu20__, __nu11__, __nu02__, __nu30__,
%           __nu21__, __nu12__, __nu03__
%
% ## Options
% * __BinaryImage__ If it is true, all non-zero image pixels are treated as
%         1's. The parameter is used for images only. default false
%
% The function computes moments, up to the 3rd order, of a vector shape or a
% rasterized shape. The results are returned in the moments struct `mo`.
%
% The spatial moments `m_ji` are computed as:
%
%     m_ji = \sum_{x,y} (array(x,y) * x^j * y^i)
%
% The central moments `mu_ji` are computed as:
%
%     mu_ji = \sum_{x,y} (array(x,y) * (x-xbar)^j * (y-ybar)^i)
%
% where `(xbar, ybar)` is the mass center:
%
%     xbar = m10/m00, ybar = m01/m00
%
% The The normalized central moments `nu_ji` are computed as:
%
%     nu_ji = mu_ji / m00^((i+j)/2+1)
%
% NOTE: `mu00 = m00`, `nu00 = 1`, `nu10 = mu10 = mu01 = mu10 = 0`, hence the
% values are not stored.
%
% The moments of a contour are defined in the same way but computed using the
% Green's formula (see http://en.wikipedia.org/wiki/Green_theorem). So, due
% a limited raster resolution, the moments computed for a contour are slightly
% different from the moments computed for the same rasterized contour.
%
% NOTE: Since the contour moments are computed using Green formula, you may
% get seemingly odd results for contours with self-intersections, e.g. a zero
% area (`m00`) for butterfly-shaped contours.
%
% See also: cv.HuMoments, cv.contourArea, cv.arcLength
%
