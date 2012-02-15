%DRAWMATCHES  Draws the found matches of keypoints from two images
%
%    im = cv.drawMatches(im1, keypoints1, im2, keypoints2, matches1to2)
%
% ## Input
% * __im1__ First source image.
% * __keypoints1__ Keypoints from the first source image.
% * __im2__ Second source image.
% * __keypoints2__ Keypoints from the second source image.
% * __matches1to2__ Matches from the first image to the second one, which
%         means that keypoints1(i) has a corresponding point in
%         keypoints2(matches(i))
%
% ## Output
% * __im__ Output image. Its content depends on the flags value defining
%         what is drawn in the output image. See possible flags bit values
%         below.
%
% ## Options
% * __MatchColor__ CColor of matches (lines and connected keypoints). If
%         all -1, random colors are picked up. default [-1,-1,-1].
% * __SinglePointColor__ Color of single keypoints (circles), which means
%         that keypoints do not have the matches. If all -1, random colors
%         are picked up. default [-1,-1,-1].
% * __MatchesMask__ Mask determining which matches are drawn. If the mask
%         is empty, all matches are drawn. default empty.
% * __NotDrawSinglePoints__ Single keypoints will not be drawn. default
%         false.
% * __DrawRichKeypoints__ For each keypoint, the circle around keypoint
%         with keypoint size and orientation will be drawn. default false.
%
% See also cv.drawKeypoints
%
