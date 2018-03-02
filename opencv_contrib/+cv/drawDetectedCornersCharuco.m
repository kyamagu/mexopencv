%DRAWDETECTEDCORNERSCHARUCO  Draws a set of ChArUco corners
%
%     img = cv.drawDetectedCornersCharuco(img, charucoCorners)
%     img = cv.drawDetectedCornersCharuco(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __img__ input image. It must have 1 or 3 channels. In the output, the
%   number of channels is not altered.
% * __charucoCorners__ cell array of detected charuco corners `{[x,y], ..}`.
%
% ## Output
% * __img__ output image.
%
% ## Options
% * __IDs__ Optional vector of identifiers for each corner in `charucoCorners`.
% * __CornerColor__ color of the square surrounding each corner.
%   default [255,0,0].
%
% This function draws a set of detected ChArUco corners. If identifiers
% vector is provided, it also draws the id of each corner.
%
% See also: cv.interpolateCornersCharuco, cv.drawDetectedMarkers,
%  cv.rectangle, cv.putText
%
