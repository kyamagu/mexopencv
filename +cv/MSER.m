%MSER  Maximally stable extremal region extractor
%
%    chains = cv.MSER(im)
%    chains = cv.MSER(im, 'OptionName', optionValue, ...)
%
% Input:
%   im: Input 8-bit grayscale image.
% Output:
%   chains: The output vector of connected points.
% Options:
%   'Delta': delta, in the code, it compares
%       (size_{i}-size_{i-delta})/size_{i-delta}. default 5.
%   'MinArea': prune the area which smaller than minArea. default 60.
%   'MaxArea': prune the area which bigger than maxArea. default 14400.
%   'MaxVariation': prune the area have simliar size to its children. default 0.25
%   'MinDiversity': trace back to cut off mser with diversity < min_diversity.
%       default 0.2.
%   'MaxEvolution': for color image, the evolution steps. default 200.
%   'AreaThreshold': the area threshold to cause re-initialize. default 1.01.
%   'MinMargin': ignore too small margin. default 0.003.
%   'EdgeBlurSize': the aperture size for edge blur. default 5.
%   'Mask': Optional input mask that marks the regions where we should detect
%        features
%