%ANISOTROPICDIFFUSION  Performs anisotropic diffusion on an image
%
%     dst = cv.anisotropicDiffusion(src)
%     dst = cv.anisotropicDiffusion(src, 'OptionName',optionValue, ...)
%
% ## Input
% * __src__ 8-bit 3-channel source image.
%
% ## Output
% * __dst__ Destination image of the same size and the same number of channels
%   as `src`.
%
% ## Options
% * __Alpha__ The amount of time to step forward by on each iteration
%   (normally, it's between 0 and 1). default 1.0
% * __K__ sensitivity to the edges. default 0.02
% * __Iterations__ The number of iterations. default 10
%
% The function applies Perona-Malik anisotropic diffusion to an image. This is
% the solution to the partial differential equation:
%
%     dI/dt = div(c(x,y,t) * nabla_I) = nabla_c * nabla_I + c(x,y,t) * delta_I
%
% where `delta` denotes the Laplacian, `nabla` denotes the gradient, `div` is
% the divergence operator and `c(x,y,t)` is the diffusion coefficient (usually
% chosen as a function of the image gradient so as to preserve edges in the
% image).
%
% Suggested functions for `c(x,y,t)` are:
%
% * Exponential Flux: `c(||nabla_I||) = exp(-(||nabla_I||/K)^2)`
% * Inverse Quadratic Flux: `c(||nabla_I||) = 1 / (1 + (||nabla_I||/K)^2)`
%
% OpenCV implements the first option.
% The constant `K` controls the sensitivity to edges.
%
% ## References
% > [PeronaMalik90]:
% > P. Perona and J. Malik, "Scale-space and edge detection using anisotropic
% > diffusion", in IEEE Transactions on Pattern Analysis and Machine
% > Intelligence, vol. 12, no. 7, pp. 629-639, Jul 1990.
%
% See also: cv.bilateralFilter
%
