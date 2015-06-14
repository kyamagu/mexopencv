%NORM  Calculates an absolute array norm, an absolute difference norm, or a relative difference norm.
%
%    nrm = cv.norm(src1)
%    nrm = cv.norm(src1, src2)
%    nrm = cv.norm(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __src1__ first input array.
% * __src2__ second input array of the same size and the same type as `src1`.
%
% ## Output
% * __nrm__ the calculated norm.
%
% ## Options
% * __NormType__ type of the norm, default 'L2'. One of:
%       * __Inf__
%       * __L1__
%       * __L2__
%       * __L2Sqr__
%       * __Hamming__
%       * __Hamming2__
% * __Relative__ if true, computes relative difference, otherwise
%       absolute difference. default false
% * __Mask__ optional operation mask; it must have the same size as `src1`
%       and logical type. Not set by default.
%
% The functions norm calculate an absolute norm of `src1` (when there is
% no `src2`):
%
%           { ||src1||_Linf = max(abs(src1(:)))     , if NormType='Inf'
%    norm = { ||src1||_L1   = sum(abs(src1(:)))     , if NormType='L1'
%           { ||src1||_L2   = sqrt(sum(src1(:).^2)) , if NormType='L2'
%
% or an absolute or relative difference norm if `src2` is there:
%
%           { ||src1 - src2||_Linf = max(abs(src1(:) - src2(:)))       , if NormType='Inf'
%    norm = { ||src1 - src2||_L1   = sum(abs(src1(:) - src2(:)))       , if NormType='L1'
%           { ||src1 - src2||_L2   = sqrt(sum((src1(:) - src2(:)).^2)) , if NormType='L2'
%
% or:
%
%           { ||src1 - src2||_Linf / ||src2||_Linf , if NormType='Inf' && Relative=True
%    norm = { ||src1 - src2||_L1 / ||src2||_L1     , if NormType='L1'  && Relative=True
%           { ||src1 - src2||_L2 / ||src2||_L2     , if NormType='L2'  && Relative=True
%
% When the mask parameter is specified and it is not empty, the norm is
% calculated only over the region specified by the mask.
%
% A multi-channel input arrays are treated as a single-channel, that is, the
% results for all channels are combined.
%
% See also: cv.normalize, norm
%
