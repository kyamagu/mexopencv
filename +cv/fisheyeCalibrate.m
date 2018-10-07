%FISHEYECALIBRATE  Performs camera calibration (fisheye)
%
%     [K, D, rms] = cv.fisheyeCalibrate(objectPoints, imagePoints, imageSize)
%     [K, D, rms, rvecs, tvecs] = cv.fisheyeCalibrate(...)
%     [...] = cv.fisheyeCalibrate(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __objectPoints__ A cell array of cells of calibration pattern points in
%   the calibration pattern coordinate space `{{[x,y,z], ..}, ...}`.
% * __imagePoints__ A cell array of cells of the projections of calibration
%   pattern points `{{[x,y], ..}, ...}`. `numel(imagePoints)` and
%   `numel(objectPoints)` must be equal, and `length(imagePoints{i})` must be
%   equal to `length(objectPoints{i})` for each `i`.
% * __imageSize__ Size of the image used only to initialize the intrinsic
%   camera matrix `[w,h]`.
%
% ## Output
% * __K__ Output 3x3 floating-point camera matrix `[fx 0 cx; 0 fy cy; 0 0 1]`.
% * __D__ Output vector of distortion coefficients `[k1, k2, k3, k4]`.
% * __rms__ the overall RMS re-projection error.
% * __rvecs__ Output cell array of rotation vectors (see cv.Rodrigues)
%   estimated for each pattern view. That is, each k-th rotation vector
%   together with the corresponding k-th translation vector (see the next
%   output parameter description) brings the calibration pattern from the
%   model coordinate space (in which object points are specified) to the world
%   coordinate space, that is, a real position of the calibration pattern in
%   the k-th pattern view (`k=1:M`).
% * __tvecs__ Output cell array of translation vectors estimated for each
%   pattern view (cell array of 3-element vectors).
%
% ## Options
% * __CameraMatrix__ Input 3x3 camera matrix used as initial value for `K`. If
%   `UseIntrinsicGuess` is specified, some or all of `fx`, `fy`, `cx`, `cy`
%   must be initialized before calling the function.
% * __DistCoeffs__ Input 4 elements vector used as an initial values of `D`.
% * __UseIntrinsicGuess__ `K` contains valid initial values of `fx`, `fy`,
%   `cx`, `cy` that are optimized further. Otherwise, `(cx,cy)` is initially
%   set to the image center (`imageSize` is used), and focal distances are
%   computed in a least-squares fashion. default false
% * __RecomputeExtrinsic__ Extrinsic will be recomputed after each iteration
%   of intrinsic optimization. default false
% * __CheckCond__ The functions will check validity of condition number.
%   default false
% * __FixSkew__ Skew coefficient (alpha) is set to zero and stay zero.
%   default false
% * __FixK1__, ..., __FixK4__ Selected distortion coefficients are set to
%   zeros and stay zero. default false
% * __FixPrincipalPoint__ The principal point is not changed during the global
%   optimization. It stays at the center or at a different location specified
%   when `UseIntrinsicGuess` is set too. default false
% * __Criteria__ Termination criteria for the iterative optimization algorithm.
%   default `struct('type','Count+EPS', 'maxCount',100, 'epsilon',eps)`
%
% See also: cv.fisheyeStereoCalibrate, cv.fisheyeUndistortImage,
%  cv.calibrateCamera
%
