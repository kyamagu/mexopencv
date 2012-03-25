%STEREOCALIBRATE  Finds the camera intrinsic and extrinsic parameters from several views of a calibration pattern
%
%    S = cv.stereoCalibrate(objectPoints, imagePoints1, imagePoints2, imageSize)
%    [...] = cv.stereoCalibrate(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __objectPoints__ A cell array of cells of calibration pattern points in the
%        calibration pattern coordinate space.
% * __imagePoints1__ A cell array of cells of the projections of calibration
%        pattern points, observed by the first camera.
% * __imagePoints2__ A cell array of cells of the projections of calibration
%        pattern points, observed by the second camera.
% * __imageSize__ Size of the image used only to initialize the intrinsic camera
%        matrix. [w,h].
%
% ## Output
% * __S__ struct having the following fields:
%     * __cameraMatrix1__ Input/output first camera matrix A = [fx, 0, cx; 0, 
%            fy, cy; 0, 0, 1]. If any of 'UseIntrinsicGuess' ,
%            'FixAspectRatio' , 'FixIntrinsic' (default) , or
%            'FixFocalLength' are specified, some or all of the matrix
%            components must be initialized.
%     * __distCoeffs1__ vector of distortion coefficients [k1,k2,p1,p2,k3,k4,
%            k5,k6] of 4, 5, or 8 elements. The output vector length
%            depends on the options.
%     * __cameraMatrix2__ second camera matrix. The parameter is similar to
%            cameraMatrix1
%     * __distCoeffs2__ lens distortion coefficients for the second camera.
%            The parameter is similar to distCoeffs1.
%     * __R__ rotation matrix between the 1st and the 2nd camera coordinate
%            systems.
%     * __T__ translation vector between the coordinate systems of the
%            cameras.
%     * __E__ essential matrix.
%     * __F__ fundamental matrix.
%     * __d__ Output final re-projection error.
%
% ## Options
% * __CameraMatrix1__, __CameraMatrix2__: Initial camera matrices.
% * __DistCoeffs1__, __DistCoeffs2__: Initial lens distortion coefficients.
% * __TermCrit__ Termination criteria for the iterative optimization
%     algorithm. struct with 'type', 'maxCount', 'epsilon' fields.
% * __FixIntrinsic__ Fix cameraMatrixN and distCoeffsN so that only R, T,
%     E , and F matrices are estimated. default true.
% * __UseIntrinsicGuess__ Optimize some or all of the intrinsic parameters
%     according to the specified flags. Initial values are provided by
%     the user. default false.
% * __FixPrincipalPoint__ Fix the principal points during the optimization.
%     default false.
% * __FixFocalLength__ Fix fx and fy. default false
% * __FixAspectRatio__ Optimize fy and fix the ratio fx/fy. default false.
% * __SameFocalLength__ Enforce same fx and fy for two cameras. default
%     false.
% * __ZeroTangentDist__ Set tangential distortion coefficients for each
%     camera to zeros and fix there. default false.
% * __FixK1__, __FixK2__, ..., __FixK6__: Do not change the corresponding
%     radial distortion coefficient during the optimization. If
%     `UseIntrinsicGuess` is set, the coefficient from the supplied
%     distCoeffs matrix is used. Otherwise, it is set to 0. default false.
% * __RationalModel__ Enable coefficients k4, k5, and k6. To provide the
%     backward compatibility, this extra flag should be explicitly
%     specified to make the calibration function use the rational model
%     and return 8 coefficients. If the flag is not set, the function
%     computes and returns only 5 distortion coefficients. default false.
%
% The function estimates transformation between two cameras making a stereo
% pair. If you have a stereo camera where the relative position and
% orientation of two cameras is fixed, and if you computed poses of an
% object relative to the first camera and to the second camera, (R1, T1)
% and (R2, T2), respectively (this can be done with cv.solvePnP), then
% those poses definitely relate to each other. This means that, given (R1,
% T1 ), it should be possible to compute (R2,T2). You only need to know the
% position and orientation of the second camera relative to the first
% camera. This is what the described function does. It computes (R,T) so
% that
%    R2 = R * R1 T2 = R * T1 + T
%
% Optionally, it computes the essential matrix E:
%
%    E = [0,-T2,T1;T2,0,-T0;-T1,T0,0] * R
%
% where Ti are components of the translation vector T: T = [T0,T1,T2]^T.
% And the function can also compute the fundamental matrix F:
%
%    F = cameraMatrix2 ^T * E * cameraMatrix1^-1
% 
% Besides the stereo-related information, the function can also perform a
% full calibration of each of two cameras. However, due to the high
% dimensionality of the parameter space and noise in the input data, the
% function can diverge from the correct solution. If the intrinsic
% parameters can be estimated with high accuracy for each of the cameras
% individually (for example, using calibrateCamera() ), you are
% recommended to do so and then pass 'FixIntrinsic' flag to the
% function along with the computed intrinsic parameters. Otherwise, if all
% the parameters are estimated at once, it makes sense to restrict some
% parameters, for example, pass 'SameFocalLength' and 'ZeroTangentDist'
% flags, which is usually a reasonable assumption.
%
% Similarly to cv.calibrateCamera, the function minimizes the total
% re-projection error for all the points in all the available views from
% both cameras. The function returns the final value of the re-projection
% error.
%
% See also cv.calibrateCamera cv.solvePnP cv.stereoRectify
%
