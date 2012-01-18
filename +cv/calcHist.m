%CALCHIST  Calculates a histogram of a set of arrays
%
%    H = calcHist(X, edges)
%
% Input:
%   X: Source pixel arrays. A numeric array, or cell array of numeric
%      arrays are accepted. They all should have the same class and the
%      same size.
% Output:
%   H: Output histogram, which is a dense or a sparse array.
% Options:
%   'Mask': Optional mask. If the matrix is not empty, it must be an array
%       of the same size as arrays. The non-zero mask elements mark the
%       array elements counted in the histogram.
%   'Uniform': Logical flag indicating whether the histogram is uniform
%       or not. default false.
%   'Sparse': Logical flag indicating whether the output should be sparse.
%   'HistSize': Array of histogram sizes in each dimension. Use together
%       with the 'Uniform' flag.
%
% The functions calcHist calculate the histogram of one or more arrays.
% The elements of a tuple used to increment a histogram bin are taken from
% the corresponding input arrays at the same location. The sample below
% shows how to compute a 2D Hue-Saturation histogram for a color image.
%
%    im = cv.cvtColor(im,'RGB2HSV');
%    edges = {linspace(0,180,30+1),linspace(0,256,32+1)};
%    h = cv.calcHist(im(:,:,1:2), edges);
%
% See also cv.calcBackProject cv.compareHist cv.EMD
%