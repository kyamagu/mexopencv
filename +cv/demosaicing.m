%DEMOSAICING  Demosaicing algorithm
%
%    dst = cv.demosaicing(src, code)
%    dst = cv.demosaicing(..., 'OptionName', optionValue, ...)
%
% ## Input
% * __src__ source image, 1-channel, `uint8` or `uint16` depth.
% * __code__ color conversion code. The following strings are supported:
%       * For Bayer->Gray demosaicing:
%           * __BayerBG2GRAY__
%           * __BayerGB2GRAY__
%           * __BayerRG2GRAY__
%           * __BayerGR2GRAY__
%       * For Bayer->RGB demosaicing:
%           * __BayerBG2BGR__, __BayerBG2RGB__
%           * __BayerGB2BGR__, __BayerGB2RGB__
%           * __BayerRG2BGR__, __BayerRG2RGB__
%           * __BayerGR2BGR__, __BayerGR2RGB__
%       * For Bayer->RGB demosaicing using Variable Number of Gradients:
%           * **BayerBG2BGR_VNG**, **BayerBG2RGB_VNG**
%           * **BayerGB2BGR_VNG**, **BayerGB2RGB_VNG**
%           * **BayerRG2BGR_VNG**, **BayerRG2RGB_VNG**
%           * **BayerGR2BGR_VNG**, **BayerGR2RGB_VNG**
%       * For Bayer->RGB Edge-Aware demosaicing:
%           * **BayerBG2BGR_EA**, **BayerBG2RGB_EA**
%           * **BayerGB2BGR_EA**, **BayerGB2RGB_EA**
%           * **BayerRG2BGR_EA**, **BayerRG2RGB_EA**
%           * **BayerGR2BGR_EA**, **BayerGR2RGB_EA**
%
% ## Output
% * __dst__ output image of same row-/col- size and depth as `src`, and of
%       specified number of channels (see `Channels` option).
%
% ## Options
% * __Channels__ Number of channels. If <= 0, automatically determined based
%       on `code`. default 0
%
% See also: cv.cvtColor, demosaic
%
