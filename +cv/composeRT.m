%COMPOSERT  Combines two rotation-and-shift transformations
%
%    S = cv.composeRT(rvec1, tvec1, rvec2, tvec2)
%
% ## Input
% * __rvec1__ First rotation vector.
% * __tvec1__ First translation vector.
% * __rvec2__ Second rotation vector.
% * __tvec2__ Second translation vector.
%
% ## Output
% * __S__ Struct with the following fields
% * __rvec3__ Rotation vector of the superposition.
% * __tvec3__ Translation vector of the superposition.
%        dr3dr1, dr3dt1, dr3dr2, dr3dt2, dt3dr1, dt3dt1, dt3dr2, dt3dt2: Output
%            derivatives of rvec3 or tvec3 with regard to rvec1, rvec2, tvec1
%            and tvec2, respectively.
%
% The functions compute:
%
%    rvec3 = rodrigues^-1( rodorigues(rvec2) * rodrigues(rvec1) )
%    tvec3 = rodrigues(rvec2) * tvec1 + tvec2
%
% where rodrigues denotes a rotation vector to a rotation matrix transformation,
% and rodrigues^-1 denotes the inverse transformation. See cv.Rodrigues for
% details
%
% Also, the functions can compute the derivatives of the output vectors with
% regards to the input vectors (see cv.matMulDeriv). The functions are used
% inside cv.stereoCalibrate but can also be used in your own code where
% Levenberg-Marquardt or another gradient-based solver is used to optimize a
% function that contains a matrix multiplication.
%
% See also cv.Rodrigues cv.matMulDeriv cv.stereoCalibrate
%
