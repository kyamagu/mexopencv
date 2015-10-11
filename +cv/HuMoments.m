%HUMOMENTS  Calculates seven Hu invariants
%
%    hu = cv.HuMoments(mo)
%
% ## Input
% * __mo__ Input moments computed with cv.moments().
%
% ## Output
% * __hu__ Output Hu invariants, a vector of length 7.
%
% The function calculates seven Hu invariants (introduced in [Hu62]; see also
% http://en.wikipedia.org/wiki/Image_moment), defined as:
%
%    hu[0] =  eta_20 + eta_02
%    hu[1] = (eta_20 - eta_02)^2 + 4*eta_11^2
%    hu[2] = (eta_30 - 3*eta_12)^2 + (3*eta_21 - eta_03)^2
%    hu[3] = (eta_30 + eta_12)^2 + (eta_21 + eta_03)^2
%    hu[4] = (eta_30 - 3*eta_12)*(eta_30 + eta_12)*[(eta_30 + eta_12)^2 - 3*(eta_21 + eta_03)^2] +
%            (3*eta_21 - eta_03)*(eta_21 + eta_03)*[3*(eta_30 + eta_12)^2-(eta_21 + eta_03)^2]
%    hu[5] = (eta_20 - eta_02)*[(eta_30 + eta_12)^2 - (eta_21 + eta_03)^2] +
%            4*eta_11(eta_30 + eta_12)*(eta_21 + eta_03)
%    hu[6] = (3*eta_21 - eta_03)*(eta_21 + eta_03)*[3*(eta_30 + eta_12)^2-(eta_21 + eta_03)^2] -
%            (eta_30 - 3*eta_12)*(eta_21 + eta_03)*[3*(eta_30 + eta_12)^2-(eta_21 + eta_03)^2]
%
% where `eta_ji` stands for `mo.nu[ji]`.
%
% These values are proved to be invariants to the image scale, rotation, and
% reflection except the seventh one, whose sign is changed by reflection. This
% invariance is proved with the assumption of infinite image resolution. In
% case of raster images, the computed Hu invariants for the original and
% transformed images are a bit different.
%
% ## References
% [Hu62]:
% > Ming-Kuei Hu. "Visual pattern recognition by moment invariants".
% > Information Theory, IRE Transactions on, 8(2):179-187, 1962.
%
% See also: cv.moments, cv.matchShapes
%
