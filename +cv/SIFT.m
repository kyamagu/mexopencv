%SIFT  Detects keypoints and computes SIFT descriptors for them
%
%    keypoints = cv.SIFT(im)
%    keypoints = cv.SIFT(im, 'OptionName', optionValue, ...)
%    [keypoints, descriptors] = cv.SIFT(...)
%
%    descriptorSize = cv.SIFT('DescriptorSize')   % descriptor size (128)
%
% ## Input
% * __im__ Input 8-bit grayscale image.
%
% ## Output
% * __keypoints__ The output vector of keypoints, a 1-by-N structure array.
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
%       is a 128-element vector, as returned by `SIFT::descriptorSize()`. So
%       the total size of descriptors will be `keypoints.size()*descriptorSize()`.
%       A matrix of size N-by-128 of class `single`, one row per keypoint.
%
% ## Options
% * __NFeatures__ The number of best features to retain. The features are ranked by
%       their scores (measured in SIFT algorithm as the local contrast). Default 0
% * __NOctaveLayers__ The number of layers in each octave. 3 is the value used in
%       D. Lowe paper. The number of octaves is computed automatically from the
%       image resolution. Default 3
% * __ConstrastThreshold__ The contrast threshold used to filter out weak features
%       in semi-uniform (low-contrast) regions. The larger the threshold, the less
%       features are produced by the detector. Default 0.04
% * __EdgeThreshold__ The threshold used to filter out edge-like features.
%       Note that the its meaning is different from the `contrastThreshold`, i.e. the
%       larger the `edgeThreshold`, the less features are filtered out (more features
%       are retained). Default 10
% * __Sigma__ The sigma of the Gaussian applied to the input image at the octave #0.
%       If your image is captured with a weak camera with soft lenses, you might
%       want to reduce the number. Default 1.6
% * __Mask__ Optional input mask that marks the regions where we should detect
%        features
%
% Extracts keypoints and computes descriptors using the Scale Invariant
% Feature Transform (SIFT) algorithm by D. Lowe:
%
% > Lowe, D. G., "Distinctive Image Features from Scale-Invariant Keypoints",
% > International Journal of Computer Vision, 60, 2, pp. 91-110, 2004.
%
% See also cv.FeatureDetector cv.DescriptorExtractor
%
