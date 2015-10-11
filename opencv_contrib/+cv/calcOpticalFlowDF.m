%CALCOPTICALFLOWDF  DeepFlow optical flow algorithm implementation
%
%    flow = cv.calcOpticalFlowDF(I0, I1)
%
% ## Input
% * __I0__ First 8-bit single-channel grayscale input image.
% * __I1__ Second input image of the same size and type as `I0`.
%
% ## Output
% * __flow__ computed flow image that has the same size as `I0` and type
%       `single` (2-channels). Flow for `(x,y)` is stored in the third
%       dimension.
%
% The class implements the DeepFlow optical flow algorithm described in
% [Weinzaepfel2013]. See also http://lear.inrialpes.fr/src/deepmatching/ .
% Parameters - class fields - are:
%
% * __Alpha__ Smoothness assumption weight. default 1.0
% * __Delta__ Color constancy assumption weight. default 0.5
% * __Gamma__ Gradient constancy weight. default 5.0
% * __Sigma__ Gaussian smoothing parameter. default 0.6
% * __MinSize__ Minimal dimension of an image in the pyramid (next, smaller
%       images in the pyramid are generated until one of the dimensions
%       reaches this size). default 25
% * __DownscaleFactor__ Scaling factor in the image pyramid (must be <1).
%       default 0.95
% * __FixedPointIterations__ How many iterations on each level of the pyramid.
%       default 5
% * __SorIterations__ Iterations of Succesive Over-Relaxation (solver).
%       default 25
% * __Omega__ Relaxation factor in SOR. default 1.6
%
% ## References
% [Weinzaepfel2013]:
% > Philippe Weinzaepfel, Jerome Revaud, Zaid Harchaoui, and Cordelia Schmid.
% > "Deepflow: Large displacement optical flow with deep matching".
% > In Computer Vision (ICCV), 2013 IEEE International Conference on,
% > pages 1385-1392. IEEE, 2013.
%
% See also: cv.calcOpticalFlowSF, cv.calcOpticalFlowFarneback
%
