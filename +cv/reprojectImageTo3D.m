%REPROJECTIMAGETO3D  Reprojects a disparity image to 3D space
%
%    im3d = cv.reprojectImageTo3D(disparity, Q)
%    [...] = cv.reprojectImageTo3D(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __disparity__ Input single-channel 8-bit unsigned, 16-bit signed, 32-bit
%        signed or 32-bit floating-point disparity image.
% * __Q__ 4 x 4 perspective transformation matrix that can be obtained with
%        cv.stereoRectify.
%
% ## Output
% * __im3d__ Output 3-channel floating-point image of the same size as
%        disparity. Each element of im3d(x,y,ch) contains 3D coordinates
%        of the point (x,y) computed from the disparity map.
%
% ## Options
% * __HandleMissingValues__ Indicates, whether the function should handle
%        missing values (i.e. points where the disparity was not computed).
%        If handleMissingValues=true, then pixels with the minimal
%        disparity that corresponds to the outliers (see cv.StereoBM) are
%        transformed to 3D points with a very large Z value (currently set
%        to 10000). default false.
%
% The function transforms a single-channel disparity map to a 3-channel
% image representing a 3D surface. That is, for each pixel (x,y) and the
% corresponding disparity d=disparity(x,y), it computes:
%
%    [X,Y,Z,W]^T = Q * [x,y,disparity(x,y),1]^T
%    im3d(x,y,:) = [X/W,Y/W,Z/W]
%
% The matrix Q can be an arbitrary  matrix (for example, the one computed
% by cv.stereoRectify). To reproject a sparse set of points {(x,y,d),...}
% to 3D space, use cv.perspectiveTransform.
%
% See also cv.StereoBM cv.stereoRectify cv.perspectiveTransform
%
