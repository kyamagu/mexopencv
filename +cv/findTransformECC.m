%FINDTRANSFORMECC  Finds the geometric transform (warp) between two images in terms of the ECC criterion
%
%    warpMatrix = cv.findTransformECC(templateImage, inputImage)
%    [warpMatrix,rho] = cv.findTransformECC(templateImage, inputImage)
%    [...] = cv.findTransformECC(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __templateImage__ single-channel template image; `uint8` or `single` array.
% * __inputImage__ single-channel input image which should be warped with the
%       final `warpMatrix` in order to provide an image similar to
%       `templateImage`, same type as `templateImage`.
%
% ## Output
% * __warpMatrix__ floating-point 2x3 or 3x3 mapping matrix (warp).
% * __rho__ correlation coefficient.
%
% ## Options
% * __MotionType__ parameter, specifying the type of motion:
%       * __Translation__ sets a translational motion model; `warpMatrix` is
%             2x3 with the first 2x2 part being the unity matrix and the rest
%             two parameters being estimated.
%       * __Euclidean__ sets a Euclidean (rigid) transformation as motion
%             model; three parameters are estimated; `warpMatrix` is 2x3.
%       * __Affine__ sets an affine motion model (DEFAULT); six parameters are
%             estimated; `warpMatrix` is 2x3.
%       * __Homography__ sets a homography as a motion model; eight parameters
%             are estimated; `warpMatrix` is 3x3.
% * __Criteria__ parameter, specifying the termination criteria of the ECC
%       algorithm; `Criteria.epsilon` defines the threshold of the increment
%       in the correlation coefficient between two iterations (a negative
%       `Criteria.epsilon` makes `Criteria.maxcount` the only termination
%       criterion). Default values are:
%       `struct()`
% * __Mask__ An optional mask to indicate valid values of `inputImage`.
%       Not set by default.
% * __InputWarpMatrix__ Initial estimate for `warpMatrix`. Not set by default
%
% The function estimates the optimum transformation (`warpMatrix`) with
% respect to ECC criterion ([EP08]), that is:
%
%    warpMatrix = argmax_{W} ECC(templateImage(x,y), inputImage(x',y'))
%
% where:
%
%    [x';y'] = W * [x;y;1]
%
% (the equation holds with homogeneous coordinates for homography). It returns
% the final enhanced correlation coefficient, that is the correlation
% coefficient between the template image and the final warped input image.
% When a 3x3 matrix is given with `MotionType` being one of 'Translation',
% 'Euclidean', or 'Affine', the third row is ignored.
%
% Unlike cv.findHomography and cv.estimateRigidTransform, the function
% cv.findTransformECC implements an area-based alignment that builds on
% intensity similarities. In essence, the function updates the initial
% transformation that roughly aligns the images. If this information is
% missing, the identity warp (unity matrix) should be given as input. Note
% that if images undergo strong displacements/rotations, an initial
% transformation that roughly aligns the images is necessary (e.g., a simple
% euclidean/similarity transform that allows for the images showing the same
% image content approximately). Use inverse warping in the second image to
% take an image close to the first one, i.e. use the flag `WarpInverse` with
% cv.warpAffine or cv.warpPerspective. Note that the function throws an
% exception if algorithm does not converges.
%
% ## References
% [EP08]:
% > Georgios D Evangelidis and Emmanouil Z Psarakis. "Parametric image
% > alignment using enhanced correlation coefficient maximization".
% > Pattern Analysis and Machine Intelligence, IEEE Transactions on,
% > 30(10):1858-1865, 2008.
%
% See also: cv.estimateRigidTransform, cv.findHomography
%
