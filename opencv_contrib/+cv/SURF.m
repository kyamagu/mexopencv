%SURF  Detects keypoints and computes SURF descriptors for them
%
%    keypoints = cv.SURF(im)
%    keypoints = cv.SURF(im, 'OptionName', optionValue, ...)
%    [keypoints, descriptors] = cv.SURF(...)
%
%    descriptorSize = cv.SURF('DescriptorSize')   % descriptor size (64,128)
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
%       is 64- or 128-element vector, as returned by `SURF::descriptorSize()`. So
%       the total size of descriptors will be `keypoints.size()*descriptorSize()`.
%       A matrix of size N-by-(64/128) of class `single`, one row per keypoint.
%
% ## Options
% * __Extended__ 0 means that the basic descriptors (64 elements each) shall be
%       computed, 1 means that the extended descriptors (128 elements each)
%       shall be computed. Default 1
% * __UpRight__ 0 means that detector computes orientation of each feature.
%       1 means that the orientation is not computed (which is much, much faster).
%       For example, if you match images from a stereo pair, or do image stitching,
%       the matched features likely have very similar angles, and you can speed up
%       feature extraction by setting upright=1. Default 0
% * __HessianThreshold__ Threshold for the keypoint detector. Only features,
%       whose hessian is larger than hessianThreshold are retained by the
%       detector. Therefore, the larger the value, the less keypoints you will
%       get. A good default value could be from 300 to 500, depending from the
%       image contrast. Default 100
% * __NOctaves__ The number of a gaussian pyramid octaves that the detector uses.
%       It is set to 4 by default. If you want to get very large features, use
%       the larger value. If you want just small features, decrease it.
% * __NOctaveLayers__ The number of images within each octave of a gaussian
%       pyramid. It is set to 2 by default.
% * __Mask__ Optional input mask that marks the regions where we should detect
%        features
%
% Extracts Speeded Up Robust Features (SURF) from an image:
%
% > Bay, H. and Tuytelaars, T. and Van Gool, L. "SURF: Speeded Up Robust Features",
% > 9th European Conference on Computer Vision, 2006
%
% See also cv.FeatureDetector cv.DescriptorExtractor
%
