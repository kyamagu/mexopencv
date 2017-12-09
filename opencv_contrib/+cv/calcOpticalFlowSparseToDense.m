%CALCOPTICALFLOWSPARSETODENSE  Fast dense optical flow based on PyrLK sparse matches interpolation
%
%     flow = cv.calcOpticalFlowSparseToDense(from, to)
%     flow = cv.calcOpticalFlowSparseToDense(from, to, 'OptionName',optionValue, ...)
%
% ## Input
% * __from__ first 8-bit 3-channel or 1-channel image.
% * __to__ second 8-bit 3-channel or 1-channel image of the same size as
%   `from`.
%
% ## Output
% * __flow__ computed flow image that has the same size as `from` and type
%   `single` (2-channels). Flow for `(x,y)` is stored in the third dimension.
%
% ## Options
% * __GridStep__ stride used in sparse match computation. Lower values usually
%   result in higher quality but slow down the algorithm. default 8
% * __K__ number of nearest-neighbor matches considered, when fitting a
%   locally affine model. Lower values can make the algorithm noticeably
%   faster at the cost of some quality degradation. default 128
% * __Sigma__ parameter defining how fast the weights decrease in the
%   locally-weighted affine fitting. Higher values can help preserve fine
%   details, lower values can help to get rid of the noise in the output flow.
%   default 0.05
% * __UsePostProcessing__ defines whether the
%   cv.FastGlobalSmootherFilter.fastGlobalSmootherFilter is used for
%   post-processing after interpolation. default true
% * __FGSLambda__ see the respective parameter of
%   cv.FastGlobalSmootherFilter.fastGlobalSmootherFilter, default 500.0
% * __FGSSigma__ see the respective parameter of
%   cv.FastGlobalSmootherFilter.fastGlobalSmootherFilter, default 1.5
%
% See also: cv.calcOpticalFlowPyrLK, cv.SparsePyrLKOpticalFlow
%
