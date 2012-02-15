%TRANSFORM  Performs the matrix transformation of every array element
%
%    dst = cv.transform(src, mtx)
%
% ## Input
% * __src__ Source array that must have as many channels (1 to 4) as columns
%        of mtx or columns -1 of mtx
% * __mtx__ floating-point transformation matrix.
%
% ## Output
% * __dst__ Destination array of the same size and depth as src. It has as
%        many channels as rows of mtx
%
% The function transform performs the matrix transformation of every
% element of the array src and stores the results in dst:
%
%    dst(I) = mtx * src(I)
%
% when columns of mtx = src channels, or
%
%    dst(I) = mtx * [src(I); 1]
%
% when columns of mtx = src channels +1.
%
% Every element of the N -channel array src is interpreted as N -element
% vector that is transformed using the M x N or M x (N+1) matrix mtx to
% M-element vector - the corresponding element of the destination array
% dst.
%
% The function may be used for geometrical transformation of N -dimensional
% points, arbitrary linear color space transformation (such as various
% kinds of RGB to YUV transforms), shuffling the image channels, and so
% forth.
%
% See also cv.warpAffine cv.warpPerspective cv.perspectiveTransform
%
