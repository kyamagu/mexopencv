%DRAWKEYPOINTS  Draws keypoints
%
%    out = cv.drawKeypoints(im, keypoints)
%    out = cv.drawKeypoints(im, keypoints, 'OptionName', optionValue, ...)
%
% ## Input
% * __im__ Source image.
% * __keypoints__ Keypoints from the source image.
%       A 1-by-N structure array with the following fields:
%       * __pt__ coordinates of the keypoint `[x,y]`
%       * __size__ diameter of the meaningful keypoint neighborhood
%       * __angle__ computed orientation of the keypoint (-1 if not
%             applicable). Its possible values are in a range [0,360) degrees.
%             It is measured relative to image coordinate system (y-axis is
%             directed downward), i.e in clockwise.
%       * __response__ the response by which the most strong keypoints have
%             been selected. Can be used for further sorting or subsampling.
%       * __octave__ octave (pyramid layer) from which the keypoint has been
%             extracted.
%       * **class_id** object id that can be used to clustered keypoints by an
%             object they belong to.
%
% ## Output
% * __out__ Output image. Its content depends on the option values defining
%       what is drawn in the output image. See possible options below.
%       By default, the source image, and single keypoints will be drawn.
%       For each keypoint, only the center point will be drawn (without
%       a circle around the keypoint with the keypoint size and orientation).
%
% ## Options
% * __Color__ Color of keypoints. If all -1, random colors are picked up.
%       default [-1,-1,-1,-1]
% * __DrawRichKeypoints__ For each keypoint, the circle around keypoint with
%       keypoint size and orientation will be drawn. default false.
% * __OutImage__ If set, keypoints will be drawn on existing content of output
%       image, otherwise source image is used instead. Default not set
%       (i.e keypoints are drawn on top of `im`).
%
% See also: cv.drawMatches, cv.FeatureDetector
%
