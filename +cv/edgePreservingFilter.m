%EDGEPRESERVINGFILTER  Edge-preserving smoothing filter
%
%    dst = cv.edgePreservingFilter(src)
%    dst = cv.edgePreservingFilter(src, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ Input 8-bit 3-channel image.
%
% ## Output
% * __dst__ Output 8-bit 3-channel image.
%
% ## Options
% * __Filter__ Edge preserving filters, one of:
%       * __Recursive__ (default)
%       * __NormConv__
% * __SigmaS__ Range between 0 to 200. default 60
% * __SigmaR__ Range between 0 to 1. default 0.4
% * __FlipChannels__ whether to flip the order of color channels in input
%       `src` and output `dst`, between MATLAB's RGB order and OpenCV's BGR
%       (input: RGB->BGR, output: BGR->RGB). default true
%
% Filtering is the fundamental operation in image and video processing.
% Edge-preserving smoothing filters are used in many different applications
% [EM11].
%
% ## References
% [EM11]:
% > Eduardo SL Gastal and Manuel M Oliveira.
% > "Domain transform for edge-aware image and video processing".
% > In ACM Transactions on Graphics (TOG), volume 30, page 69. ACM, 2011.
%
