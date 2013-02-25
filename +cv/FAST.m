%FAST  Detects corners using the FAST algorithm
%
%    keypoints = cv.FAST(im)
%    keypoints = cv.FAST(im, 'OptionName', optionValue, ...)
%
% ## Input
% * __im__ Image where keypoints (corners) are to be detected.
%
% ## Output
% * __keypoints__ Keypoints detected on the image. A 1-by-N structure array.
%       It has the following fields:
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
%
% ## Options
% * __Threshold__ Threshold on difference between intensity of the central
%        pixel and pixels on a circle around this pixel. See the algorithm
%        description [E. Rosten, 2006]. default 10.
% * __NonMaxSupression__ If it is true, non-maximum supression is applied
%        to detected corners (keypoints). default true.
%
% Detects corners using the FAST algorithm by:
%
% > E. Rosten (Machine Learning for High-speed Corner Detection, 2006).
%
% See also cv.FeatureDetector cv.DescriptorExtractor
%
