%L0SMOOTH  Global image smoothing via L0 gradient minimization
%
%     dst = cv.l0Smooth(src)
%     dst = cv.l0Smooth(src, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ source image for filtering with unsigned 8-bit or signed 16-bit or
%   floating-point depth.
%
% ## Output
% * __dst__ destination image.
%
% ## Options
% * __Lambda__ parameter defining the smooth term weight. default 0.02
% * __Kappa__ parameter defining the increasing factor of the weight of the
%   gradient data term. default 2.0
%
% For more details about L0 Smoother, see the original paper [xu2011image].
%
% ## References
% [xu2011image]:
% > Li Xu, Cewu Lu, Yi Xu, and Jiaya Jia. "Image smoothing via L0 gradient
% > minimization". In ACM Transactions on Graphics (TOG), volume 30,
% > page 174. ACM, 2011.
%
% See also: cv.jointBilateralFilter
%
