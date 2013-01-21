%DRAWMATCHES  Draws the found matches of keypoints from two images
%
%    im = cv.drawMatches(im1, keypoints1, im2, keypoints2, matches1to2)
%    im = cv.drawMatches(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __im1__ First source image.
% * __keypoints1__ Keypoints from the first source image.
%       A 1-by-N structure array. It has the following fields:
%       * __pt__ coordinates of the keypoint [x,y]
%       * __size__ diameter of the meaningful keypoint neighborhood
%       * __angle__ computed orientation of the keypoint (-1 if not applicable).
%             Its possible values are in a range [0,360) degrees. It is measured
%             relative to image coordinate system (y-axis is directed downward),
%             ie in clockwise.
%       * __response__ the response by which the most strong keypoints have been
%             selected. Can be used for further sorting or subsampling.
%       * __octave__ octave (pyramid layer) from which the keypoint has been
%             extracted.
%       * **class_id** object id that can be used to clustered keypoints by an
%             object they belong to.
% * __im2__ Second source image.
% * __keypoints2__ Keypoints from the second source image. Same as `keypoints1`
% * __matches1to2__ Matches from the first image to the second one, which
%         means that `keypoints1(i)` has a corresponding point in
%         `keypoints2(matches(i))`
%
% ## Output
% * __im__ Output image. Its content depends on the option values defining
%         what is drawn in the output image. See possible options below.
%         By default, the two source images, matches, and single
%         keypoints will be drawn. For each keypoint, only the center point
%         will be drawn (without a circle around the keypoint with the
%         keypoint size and orientation).
%
% ## Options
% * __MatchColor__ Color of matches (lines and connected keypoints). If
%         all -1, random colors are picked up. default [-1,-1,-1,-1].
% * __SinglePointColor__ Color of single keypoints (circles), which means
%         that keypoints do not have the matches. If all -1, random colors
%         are picked up. default [-1,-1,-1,-1].
% * __MatchesMask__ Mask determining which matches are drawn. If the mask
%         is empty, all matches are drawn. default empty.
% * __NotDrawSinglePoints__ Single keypoints will not be drawn. default
%         false.
% * __DrawRichKeypoints__ For each keypoint, the circle around keypoint
%         with keypoint size and orientation will be drawn. default false.
%
% See also cv.drawKeypoints
%
