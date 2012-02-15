%DRAWKEYPOINTS  Draws keypoints
%
%    im = cv.drawKeypoints(im, keypoints)
%
% ## Input
% * __im__ Image to be drawn keypoints.
% * __keypoints__ Keypoints from the source image.
%
% ## Output
% * __im__ Output image. Its content depends on the option values defining
%         what is drawn in the output image. See possible options below.
%
% ## Options
% * __Color__ Color of keypoints. If all -1, random colors are picked up.
%         default [-1,-1,-1]
% * __NotDrawSinglePoints__ Single keypoints will not be drawn. default
%         false.
% * __DrawRichKeypoints__ For each keypoint, the circle around keypoint
%         with keypoint size and orientation will be drawn. default false.
%
% See also cv.drawMatches
%
