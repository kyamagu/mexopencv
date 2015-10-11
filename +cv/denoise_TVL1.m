%DENOISE_TVL1  Primal-Dual algorithm to perform image denoising
%
%    result = cv.denoise_TVL1(observations)
%    result = cv.denoise_TVL1(observations, 'OptionName',optionValue, ...)
%
% ## Input
% * __observations__ This cell array should contain one or more noised
%       versions of the image that is to be restored. All images should have
%       the same size and `uint8` type (grayscale).
%
% ## Output
% * __result__ the denoised 8-bit image.
%
% ## Options
% * __Lambda__ Corresponds to `lambda` in the formulas below. As it is
%       enlarged, the smooth (blurred) images are treated more favorably than
%       detailed (but maybe more noised) ones. Roughly speaking, as it becomes
%       smaller, the result will be more blur but more sever outliers will be
%       removed. default 1.0
% * __NIters__ Number of iterations that the algorithm will run. Of course, as
%       more iterations as better, but it is hard to quantitatively refine
%       this statement, so just use the default and increase it if the results
%       are poor. default 30
%
% Primal-dual algorithm is an algorithm for solving special types of
% variational problems (that is, finding a function to minimize some
% functional). As the image denoising, in particular, may be seen as the
% variational problem, primal-dual algorithm then can be used to perform
% denoising and this is exactly what is implemented.
%
% It should be noted, that this implementation was taken from the July 2013
% blog entry [MA13], which also contained (slightly more general) ready-to-use
% source code on Python. Subsequently, that code was rewritten on C++ with the
% usage of OpenCV by *Vadim Pisarevsky* at the end of July 2013 and finally it
% was slightly adapted by later authors.
%
% Although the thorough discussion and justification of the algorithm involved
% may be found in [ChambolleEtAl], it might make sense to skim over it here,
% following [MA13]. To begin with, we consider the 1-byte gray-level images as
% the functions from the rectangular domain of pixels (it may be seen as set
% `{(x,y) in NxN | 1<=x<=n, 1<=y<=m}` for some `m,n in N` into `{0,1,...,255}`.
% We shall denote the noised images as `f_i` and with this view, given some
% image `x` of the same size, we may measure how bad it is by the formula:
%
%    || nabla_x || + lambda * sum_i || x - f_i ||
%
% `|| . ||` here denotes L2-norm and as you see, the first addend states that
% we want our image to be smooth (ideally, having zero gradient, thus being
% constant) and the second states that we want our result to be close to the
% observations we've got. If we treat `x` as a function, this is exactly the
% functional what we seek to minimize and here the Primal-Dual algorithm comes
% into play.
%
% ## References
% [MA13]:
% > Alexander Mordvintsev. "ROG and TV-L1 denoising with primal-dual algorithm".
%
% [ChambolleEtAl]:
% > Antonin Chambolle, Vicent Caselles, Daniel Cremers, Matteo Novaga, and
% > Thomas Pock. "An introduction to total variation for image analysis".
% > Theoretical foundations and numerical methods for sparse recovery,
% > 9:263-340, 2010.
%
