%DRAWKEYPOINTS  Draws keypoints
%
%   im = cv.drawKeypoints(im, keypoints)
%
% Input:
%     im: Image to be drawn keypoints.
%     keypoints: Keypoints from the source image.
% Output:
%     im: Output image. Its content depends on the option values defining
%         what is drawn in the output image. See possible options below.
% Options:
%     'Color': Color of keypoints. If all -1, random colors are picked up.
%         default [-1,-1,-1]
%     'NotDrawSinglePoints': Single keypoints will not be drawn. default
%         false.
%     'DrawRichKeypoints': For each keypoint, the circle around keypoint
%         with keypoint size and orientation will be drawn. default false.
%
% See also cv.drawMatches
%