%DRAWMATCHES  Draws the found matches of keypoints from two images
%
%   im = cv.drawMatches(im1, keypoints1, im2, keypoints2, matches1to2)
%
% Input:
%     im1: First source image.
%     keypoints1: Keypoints from the first source image.
%     im2: Second source image.
%     keypoints2: Keypoints from the second source image.
%     matches1to2: Matches from the first image to the second one, which
%         means that keypoints1(i) has a corresponding point in
%         keypoints2(matches(i))
% Output:
%     im: Output image. Its content depends on the flags value defining
%         what is drawn in the output image. See possible flags bit values
%         below.
% Options:
%     'MatchColor': CColor of matches (lines and connected keypoints). If
%         all -1, random colors are picked up. default [-1,-1,-1].
%     'SinglePointColor': Color of single keypoints (circles), which means
%         that keypoints do not have the matches. If all -1, random colors
%         are picked up. default [-1,-1,-1].
%     'MatchesMask': Mask determining which matches are drawn. If the mask
%         is empty, all matches are drawn. default empty.
%     'NotDrawSinglePoints': Single keypoints will not be drawn. default
%         false.
%     'DrawRichKeypoints': For each keypoint, the circle around keypoint
%         with keypoint size and orientation will be drawn. default false.
%
% See also cv.drawKeypoints
%