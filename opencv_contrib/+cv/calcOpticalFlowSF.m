%CALCOPTICALFLOWSF  Calculate an optical flow using "SimpleFlow" algorithm
%
%    flow = cv.calcOpticalFlowSF(from, to)
%    flow = cv.calcOpticalFlowSF(from, to, 'OptionName',optionValue, ...)
%
% ## Input
% * __from__ First 8-bit 3-channel image.
% * __to__ Second 8-bit 3-channel image of the same size as `from`.
%
% ## Output
% * __flow__ computed flow image that has the same size as `from` and type
%       `single` (2-channels). Flow for `(x,y)` is stored in the third
%       dimension.
%
% ## Options
% * __Layers__ Number of layers. default 3
% * __AveragingBlockSize__ Size of block through which we sum up when
%       calculate cost function for pixel. default 2
% * __MaxFlow__ maximal flow that we search at each level. default 4
% * __SigmaDist__ vector smooth spatial sigma parameter. default 4.1
% * __SigmaColor__ vector smooth color sigma parameter. default 25.5
% * __PostprocessWindow__ window size for postprocess cross bilateral filter.
%       default 18
% * __SigmaDistFix__ spatial sigma for postprocess cross bilateralf filter.
%       default 55.0
% * __SigmaColorFix__ color sigma for postprocess cross bilateral filter.
%       default 25.5
% * __OccThr__ threshold for detecting occlusions. default 0.35
% * __UpscaleAveragingRadius__ window size for bilateral upscale operation.
%       default 18
% * __UpscaleSigmaDist__ spatial sigma for bilateral upscale operation.
%       default 55.0
% * __UpscaleSigmaColor__ color sigma for bilateral upscale operation.
%       default 25.5
% * __SpeedUpThr__ threshold to detect point with irregular flow - where flow
%       should be recalculated after upscale. default 10
%
% See [Tao2012]. And site of project:
% http://graphics.berkeley.edu/papers/Tao-SAN-2012-05/.
%
% ## References
% [Tao2012]:
% > Michael Tao, Jiamin Bai, Pushmeet Kohli, and Sylvain Paris. "Simpleflow: A
% > non-iterative, sublinear optical flow algorithm". In Computer Graphics
% > Forum, volume 31, pages 345-353. Wiley Online Library, 2012.
%
% See also: cv.calcOpticalFlowDF, cv.calcOpticalFlowFarneback
%
