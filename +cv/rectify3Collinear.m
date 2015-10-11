%RECTIFY3COLLINEAR  Computes the rectification transformations for 3-head camera, where all the heads are on the same line
%
%    S = cv.rectify3Collinear(cameraMatrix1, distCoeffs1, cameraMatrix2,
%            distCoeffs2, cameraMatrix3, distCoeffs3, imageSize, R12, T12, R13, T13)
%    [...] = cv.rectify3Collinear(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __cameraMatrix1__ First camera matrix 3x3.
% * __cameraMatrix2__ Second camera matrix 3x3.
% * __cameraMatrix3__ Third camera matrix 3x3.
% * __distCoeffs1__ First camera distortion parameters of 4, 5, 8, or 12
%       elements.
% * __distCoeffs2__ Second camera distortion parameters of 4, 5, 8, or 12
%       elements.
% * __distCoeffs3__ Third camera distortion parameters of 4, 5, 8, or 12
%       elements.
% * __imageSize__ Size of the image used for stereo calibration `[w,h]`.
% * __R12__ Rotation matrix between the coordinate systems of the first and the
%       second cameras, 3x3/3x1 (see cv.Rodrigues)
% * __T12__ Translation vector between coordinate systems of the first and the
%       second cameras, 3x1.
% * __R13__ Rotation matrix between the coordinate systems of the first and the
%       third cameras, 3x3/3x1 (see cv.Rodrigues)
% * __T13__ Translation vector between coordinate systems of the first and the
%       third cameras, 3x1.
%
% ## Output
% * __S__ scalar struct having the following fields:
%       * __R1__ 3x3 rectification transform (rotation matrix) for the first
%             camera.
%       * __R2__ 3x3 rectification transform (rotation matrix) for the second
%             camera.
%       * __R3__ 3x3 rectification transform (rotation matrix) for the third
%             camera.
%       * __P1__ 3x4 projection matrix in the new (rectified) coordinate
%             systems for the first camera.
%       * __P2__ 3x4 projection matrix in the new (rectified) coordinate
%             systems for the second camera.
%       * __P3__ 3x4 projection matrix in the new (rectified) coordinate
%             systems for the third camera.
%       * __Q__ 4x4 disparity-to-depth mapping matrix (see
%             cv.reprojectImageTo3D).
%       * __roi1__, __roi2__ rectangles inside the rectified images where all
%             the pixels are valid `[x,y,w,h]`. If `Alpha=0`, the ROIs cover
%             the whole images. Otherwise, they are likely to be smaller.
%       * __ratio__ disparity ratio, floating-point numeric scalar.
%
% ## Options
% * __ImgPoints1__, __ImgPoints3__ Optional cell arrays of 2D points
%       `{[x,y], ...}`, used to adjust the third matrix `P3`.
%       Not set by default.
% * __Alpha__ Free scaling parameter. If it is -1 or absent, the function
%       performs the default scaling. Otherwise, the parameter should be
%       between 0 and 1. `Alpha=0` means that the rectified images are zoomed
%       and shifted so that only valid pixels are visible (no black areas
%       after rectification). `Alpha=1` means that the rectified image is
%       decimated and shifted so that all the pixels from the original iamges
%       from the cameras are retained in the rectified images (no source image
%       pixels are lost). Obviously, any intermediate value yields an
%       intermediate result between those two extreme cases. default -1
% * __NewImageSize__ New image resolution after rectification. The same size
%       should be passed to cv.initUndistortRectifyMap. When [0,0] is passed
%       (default), it is set to the original `imageSize`. Setting it to larger
%       value can help you preserve details in the original image, especially
%       when there is a big radial distortion.
% * __ZeroDisparity__ If the flag is set, the function makes the principal
%       points of each camera have the same pixel coordinates in the rectified
%       views. And if the flag is not set, the function may still shift the
%       images in the horizontal or vertical direction (depending on the
%       orientation of epipolar lines) to maximize the useful image area.
%       default true.
%
% See also: cv.stereoRectify
%
