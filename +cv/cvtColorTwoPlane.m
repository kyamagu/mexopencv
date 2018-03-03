%CVTCOLORTWOPLANE  Dual-plane color conversion modes
%
%     dst = cv.cvtColorTwoPlane(ysrc, uvsrc, code)
%
% ## Input
% * __ysrc__ Luma component (Y').
% * __uvsrc__ Chrominance components (UV).
% * __code__ Color space conversion code string. The following codes are
%   supported:
%   * **YUV2RGB_NV12**
%   * **YUV2BGR_NV12**
%   * **YUV2RGB_NV21**
%   * **YUV2BGR_NV21**
%   * **YUV420sp2RGB**
%   * **YUV420sp2BGR**
%   * **YUV2RGBA_NV12**
%   * **YUV2BGRA_NV12**
%   * **YUV2RGBA_NV21**
%   * **YUV2BGRA_NV21**
%   * **YUV420sp2RGBA**
%   * **YUV420sp2BGRA**
%
% ## Output
% * __dst__ Output image of the same row/column size and depth as `ysrc`.
%
% Only YUV 4:2:0 is currently supported.
%
% See also: cv.cvtColor
%
