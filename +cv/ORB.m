%ORB  Detects keypoints and computes ORB descriptors for them
%
%    keypoints = cv.ORB(im)
%    keypoints = cv.ORB(im, 'OptionName', optionValue, ...)
%    [keypoints, descriptors] = cv.ORB(...)
%
%    descriptorSize = cv.ORB('DescriptorSize')   % descriptor size (32)
%
% ## Input
% * __im__ Input 8-bit grayscale image.
%
% ## Output
% * __keypoints__ The output vector of keypoints. A 1-by-N structure array.
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
% * __descriptors__ The output concatenated vectors of descriptors. Each descriptor
%       is a 32-element vector, as returned by `ORB::descriptorSize()`. So
%       the total size of descriptors will be `keypoints.size()*descriptorSize()`.
%       A matrix of size N-by-32 of class `uint8`, one row per keypoint.
%
% ## Options
% * __NFeatures__ The maximum number of features to retain. default 500
% * __ScaleFactor__ Pyramid decimation ratio, greater than 1. scaleFactor==2 means
%       the classical pyramid, where each next level has 4x less pixels than the
%       previous, but such a big scale factor will degrade feature matching scores
%       dramatically. On the other hand, too close to 1 scale factor will mean that
%       to cover certain scale range you will need more pyramid levels and so the
%       speed will suffer. default 1.2
% * __NLevels__ The number of pyramid levels. The smallest level will have linear
%       size equal to `input_image_linear_size/pow(scaleFactor, nlevels)`. default 3
% * __EdgeThreshold__ This is size of the border where the features are not
%       detected. It should roughly match the patchSize parameter. default 31
% * __FirstLevel__ It should be 0 in the current implementation. default 0
% * **WTA_K** The number of points that produce each element of the oriented
%       BRIEF descriptor. The default value 2 means the BRIEF where we take a
%       random point pair and compare their brightnesses, so we get 0/1 response.
%       Other possible values are 3 and 4. For example, 3 means that we take 3
%       random points (of course, those point coordinates are random, but they
%       are generated from the pre-defined seed, so each element of BRIEF descriptor
%       is computed deterministically from the pixel rectangle), find point of
%       maximum brightness and output index of the winner (0, 1 or 2). Such output
%       will occupy 2 bits, and therefore it will need a special variant of Hamming
%       distance, denoted as `NORM_HAMMING2` (2 bits per bin). When `WTA_K`=4, we take
%       4 random points to compute each bin (that will also occupy 2 bits with
%       possible values 0, 1, 2 or 3).
% * __ScoreType__ The default `HARRIS_SCORE` (0) means that Harris algorithm is used to rank
%       features (the score is written to `KeyPoint::score` and is used to retain best
%       `nfeatures` features); `FAST_SCORE` (1) is alternative value of the parameter that
%       produces slightly less stable keypoints, but it is a little faster to compute.
%       default 0
% * __PatchSize__ size of the patch used by the oriented BRIEF descriptor.
%       Of course, on smaller pyramid layers the perceived image area covered
%       by a feature will be larger. default 31
% * __Mask__ Optional input mask that marks the regions where we should detect
%        features
%
% Implements the ORB (oriented BRIEF) keypoint detector and descriptor extractor,
% described in:
%
% > Ethan Rublee, Vincent Rabaud, Kurt Konolige, Gary R. Bradski:
% > ORB: An efficient alternative to SIFT or SURF. ICCV 2011: 2564-2571.
%
% The algorithm uses FAST in pyramids to detect stable
% keypoints, selects the strongest features using FAST or Harris response, finds
% their orientation using first-order moments and computes the descriptors using
% BRIEF (where the coordinates of random point pairs (or k-tuples) are rotated
% according to the measured orientation).
%
% See also cv.FeatureDetector cv.DescriptorExtractor
%
