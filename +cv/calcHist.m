%CALCHIST  Calculates a histogram of a set of arrays
%
%    H = cv.calcHist(images, ranges)
%    H = cv.calcHist(..., 'OptionName',optionValue, ...)
%
% ## Input
% * __images__ Source arrays. A numeric array, or cell array of numeric arrays
%       are accepted. They all should have the same class (`uint8`, `uint16`,
%       or `single`) and the same row/column size. Each of them can have an
%       arbitrary number of channels. Note that passing `{img1, img2, ...}` as
%       input is similar to using `cat(3, img1, img2, ...)`, i.e the function
%       computes the histogram from channels of input arrays.
% * __ranges__ Cell-array of length `N` (histogram dimensionality) of the
%       histogram bin boundaries in each dimension.
%       * When the histogram is uniform (`Uniform=true`), then for each
%         dimension `i` it is enough to specify the lower (inclusive) boundary
%         `L(1) = ranges{i}(1)` of the first histogram bin and the upper
%         (exclusive) boundary `U(n) = ranges{i}(end)` for the last histogram
%         bin `HistSize(i)`. That is, in case of a uniform histogram each of
%         `ranges{i}` is an array of 2 elements forming an interval `[L,U)`
%         which is automatically divided according to `HistSize(i)`.
%       * When the histogram is not uniform (`Uniform=false`), then each of
%         `ranges{i}` contains `HistSize(i)+1` elements, specifying the bin
%         edges of dimension `i`: `L(1), L(2), ..., L(n), U(n)` forming the
%         half-open intervals:
%        `[L(1), U(1)), [L(2), U(2)), ..., [L(n-1), U(n-1)), [L(n), U(n))`
%         where `U(1)==L(2), U(2)==L(3), ..., U(n-1)==L(n)`, and `n` is the
%         histogram size of the current dimension (`n = HistSize(i)`). The
%         array elements, that are not between `L(1)` and `U(n)`, are not
%         counted in the histogram.
%
% ## Output
% * __H__ Output histogram, which is a dense or sparse N-dimensional array of
%       type `single` (`N` is the histogram dimensionality that must be
%       positive and not greater than 32 in the current OpenCV version). The
%       size of the output N-D array is
%       `HistSize(1)-by-HistSize(2)-by-...-by-HistSize(N)`.
%
% ## Options
% * __Channels__ List of channels used to compute the histogram (as 0-based
%       indices). The number of channels must match the histogram
%       dimensionality `N`. The first array channels are numerated from `0` to
%       `size(images{1},3)-1`, the second array channels are counted from
%       `size(images{1},3)` to `size(images{1},3) + size(images{2},3)-1`, and
%       so on. By default, all channels from all images are used to compute
%       the histogram, i.e default is `0:sum(cellfun(@(im)size(im,3), images))-1`
%       when input `images` is a cell array, and `0:(size(images,3)-1)` when
%       input `images` is a numeric array.
% * __Mask__ Optional mask. If the matrix is not empty, it must be an 8-bit or
%       logical array of the same row/column size as `images{i}`. The non-zero
%       mask elements mark the array elements (pixels) counted in the
%       histogram. Not set by default.
% * __HistSize__ Array of histogram sizes in each dimension. Use together
%       with the `Uniform` flag. Default is `cellfun(@numel,ranges)-1`.
%       * When the histogram is uniform, the range specified in `ranges{i}` is
%         divided into `HistSize(i)` uniform bins. The interval is divided into
%         bins using equally-spaced boundaries defined as:
%         `ranges{i} = linspace(ranges{i}(1), ranges{i}(end), HistSize(i)+1)`.
%       * When the histogram is not uniform, `ranges{i}` is used as is for the
%         bin boundaries without considering `HistSize`.
% * __Uniform__ Logical flag indicating whether the histogram is uniform
%       or not (see above). default false.
% * __Hist__ Input histogram, used in accumulation mode. Either a dense or
%       sparse array, see `H`. If it is set, the output histogram is
%       initialized with it instead of being cleared in the beginning when it
%       is allocated. This feature enables you to compute a single histogram
%       from several sets of arrays, or to update the histogram in time.
%       Not set by default.
% * __Sparse__ Logical flag indicating whether the output should be sparse.
%       default false (i.e output histogram is a dense array). Keep in mind
%       that MATLAB only supports 2D sparse matrices, so use you must use
%       dense arrays if the histogram has more than two dimensions.
%
% The function cv.calcHist calculates the histogram of one or more arrays. The
% elements of a tuple used to increment a histogram bin are taken from the
% corresponding input arrays at the same location.
%
% ## Example
% The sample below shows how to compute a 2D Hue-Saturation histogram for a
% color image:
%
%    hsv = cv.cvtColor(img, 'RGB2HSV');
%    edges = {linspace(0,180,30+1), linspace(0,256,32+1)};
%    H = cv.calcHist(hsv(:,:,1:2), edges);
%
% Here is another example showing the different options:
%
%    % read some image, and convert to HSV colorspace
%    imgRGB = imread(fullfile(mexopencv.root(),'test','img001.jpg'));
%    imgHSV = cv.cvtColor(imgRGB, 'RGB2HSV');
%
%    % quantize the hue to 30 levels, and the saturation to 32 levels
%    histSize = [30, 32];
%    hranges = linspace(0, 180, histSize(1)+1);  % hue varies from 0 to 179
%    sranges = linspace(0, 256, histSize(2)+1);  % sat varies from 0 to 255
%    ranges = {hranges, sranges};
%
%    % one way
%    H = cv.calcHist(imgHSV(:,:,[1 2]), ranges);
%
%    % another way
%    H = cv.calcHist(imgHSV, ranges, 'Channels',[1 2]-1, 'HistSize',histSize);
%
%    % or similarly
%    H = cv.calcHist({imgHSV(:,:,1), imgHSV(:,:,2)}, {[0,180], [0,256]}, ...
%        'HistSize',histSize, 'Uniform',true);
%
%    % show H-S histogram
%    imagesc(H, 'YData',[0 180], 'XData',[0 256])
%    axis image; colormap gray; colorbar
%    ylabel('Hue'); xlabel('Saturation'); title('Histogram')
%
% See also: cv.calcBackProject, cv.compareHist, cv.EMD, histc, histcounts
%
