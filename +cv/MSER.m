%MSER  Maximally stable extremal region extractor
%
%    chains = cv.MSER(im)
%    chains = cv.MSER(im, 'OptionName', optionValue, ...)
%
% ## Input
% * __im__ Input 8-bit grayscale image.
%
% ## Output
% * __chains__ The output vector of connected points.
%       Cell array of cell array of points `{{[x,y],[x,y],..}, {[x,y],..}}`
%
% ## Options
% * __Delta__ delta, in the code, it compares
%       `(size_{i}-size_{i-delta})/size_{i-delta}`. default 5.
% * __MinArea__ prune the area which smaller than minArea. default 60.
% * __MaxArea__ prune the area which bigger than maxArea. default 14400.
% * __MaxVariation__ prune the area have simliar size to its children. default 0.25
% * __MinDiversity__ trace back to cut off mser with diversity < min_diversity.
%       default 0.2.
% * __MaxEvolution__ for color image, the evolution steps. default 200.
% * __AreaThreshold__ the area threshold to cause re-initialize. default 1.01.
% * __MinMargin__ ignore too small margin. default 0.003.
% * __EdgeBlurSize__ the aperture size for edge blur. default 5.
% * __Mask__ Optional input mask that marks the regions where we should detect
%        features
%
% The class encapsulates all the parameters of the MSER extraction algorithm
% (see http://en.wikipedia.org/wiki/Maximally_stable_extremal_regions).
%
% See also cv.FeatureDetector cv.DescriptorExtractor
%
