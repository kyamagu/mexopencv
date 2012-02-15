%HUMOMENTS  Calculates seven Hu invariants
%
%    m = cv.HuMoments(mo)
%
% ## Input
% * __mo__ Input moments computed with cv.moments().
%
% ## Output
% * __hu__ Output Hu invariants.
%
% The function calculates seven Hu invariants (introduced in [Hu62]; see also
% http://en.wikipedia.org/wiki/Image_moment).
%
% These values are proved to be invariants to the image scale, rotation, and
% reflection except the seventh one, whose sign is changed by reflection. This
% invariance is proved with the assumption of infinite image resolution. In
% case of raster images, the computed Hu invariants for the original and
% transformed images are a bit different.
%
% See also cv.moments
%
