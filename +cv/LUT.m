%LUT  Performs a look-up table transform of an array
%
%     dst = cv.LUT(src, lut)
%
% ## Input
% * __src__ input array of 8-bit elements (`uint8` or `int8`).
% * __lut__ look-up table of 256 elements; in case of multi-channel input
%   array `src`, the table should either have a single channel (in this case
%   the same table is used for all channels) or the same number of channels as
%   in the input array.
%
% ## Output
% * __dst__ output array of the same size and number of channels as `src`, and
%   the same depth as `lut`.
%
% The function cv.LUT fills the output array with values from the look-up
% table. Indices of the entries are taken from the input array. That is, the
% function processes each element of src as follows:
%
%     dst(I) = lut(src(I) + d)
%
% where:
%
%     d = { 0   if src has uint8 depth
%         { 128 if src has  int8 depth
%
% See also: cv.convertScaleAbs, cv.convertTo, cv.applyColorMap, intlut
%
