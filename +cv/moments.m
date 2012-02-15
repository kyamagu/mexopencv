%MOMENTS  Calculates all of the moments up to the third order of a polygon or rasterized shape
%
%    m = cv.moments(array)
%
% ## Input
% * __array__ Raster image (single-channel, 8-bit or floating-point 2D array).
%
% ## Output
% * __m__ Output moments.
%
% ## Options
% * __BinaryImage__ If it is true, all non-zero image pixels are treated as
%         1's. The parameter is used for images only.
%
% The function computes moments, up to the 3rd order, of a vector shape or a
% rasterized shape. The results are returned in the moments struct with the
% following fields:
%
%     'm00','m10','m01','m20','m11','m02','m30','m21','m12','m03'
%
% The moments of a contour are defined in the same way but computed using the
% Green's formula (see http://en.wikipedia.org/wiki/Green_theorem). So, due 
% a limited raster resolution, the moments computed for a contour are slightly
% different from the moments computed for the same rasterized contour.
%
% See also cv.HuMoments
%
