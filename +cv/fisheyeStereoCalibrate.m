%FISHEYESTEREOCALIBRATE  Performs stereo calibration (fisheye)
%
%     S = cv.fisheyeStereoCalibrate(objectPoints, imagePoints1, imagePoints2, imageSize)
%     [...] = cv.fisheyeStereoCalibrate(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __objectPoints__ A cell array of cells of the calibration pattern points
%   `{{[x,y,z], ..}, ...}`.
% * __imagePoints1__ A cell array of cells of the projections of the
%   calibration pattern points `{{[x,y], ..}, ...}`, observed by the first
%   camera.
% * __imagePoints2__ A cell array of cells of the projections of the
%   calibration pattern points `{{[x,y], ..}, ...}`, observed by the second
%   camera.
% * __imageSize__ Size of the image used only to initialize intrinsic camera
%   matrix `[w,h]`.
%
% ## Output
% * __S__ scalar struct having the following fields:
%   * __cameraMatrix1__ Output first camera matrix
%     `[fx1 0 cx1; 0 fy1 cy1; 0 0 1]`.
%   * __distCoeffs1__ Output vector of distortion coefficients
%     `[k1, k2, k3, k4]` of 4 elements.
%   * __cameraMatrix2__ Output second camera matrix
%     `[fx2 0 cx2; 0 fy2 cy2; 0 0 1]`. The parameter is similar to `K1`.
%   * __distCoeffs2__ Output lens distortion coefficients for the second
%     camera. The parameter is similar to `D1`.
%   * __R__ Output 3x3 rotation matrix between the 1st and the 2nd camera
%     coordinate systems.
%   * __T__ Output 3x1 translation vector between the coordinate systems of
%     the cameras.
%   * __reprojErr__ output final re-projection error (scalar).
%
% ## Options
% * __CameraMatrix1__, __CameraMatrix2__ Initial camera matrices. If any of
%   `UseIntrinsicGuess`, `FixIntrinsic` (default) are specified, some or all
%   of the matrix components must be initialized. See the flags description
%   for details.
% * __DistCoeffs1__, __DistCoeffs2__ Initial lens distortion coefficients.
% * __FixIntrinsic__ Fix `K1`, `K2` and `D1`, `D2` so that only `R`, `T`
%   matrices are estimated. default true
% * __UseIntrinsicGuess__ `K1`, `K2` contains valid initial values of `fx`,
%   `fy`, `cx`, `cy` that are optimized further. Otherwise, `(cx,cy)` is
%   initially set to the image center (`imageSize` is used), and focal
%   distances are computed in a least-squares fashion. default false
% * __RecomputeExtrinsic__ Extrinsic will be recomputed after each iteration
%   of intrinsic optimization. default false
% * __CheckCond__ The functions will check validity of condition number.
%   default false
% * __FixSkew__ Skew coefficient (alpha) is set to zero and stay zero.
%   default false
% * __FixK1__, ..., __FixK4__ Selected distortion coefficients are set to
%   zeros and stay zero. default false
% * __Criteria__ Termination criteria for the iterative optimization algorithm.
%   default `struct('type','Count+EPS', 'maxCount',100, 'epsilon',eps)`
%
% See also: cv.fisheyeCalibrate, cv.fisheyeStereoRectify, cv.stereoCalibrate
%
