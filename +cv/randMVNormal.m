%RANDMVNORMAL  Generates sample from multivariate normal distribution
%
%    samples = cv.randMVNormal(mu, sigma, nsamples)
%
% ## Input
% * __mu__ mean, an average row vector `1xd`.
% * __sigma__ symmetric covariation matrix `dxd`.
% * __nsamples__ returned samples count.
%
% ## Output
% * __samples__ returned samples array `nsamples-by-d`.
%
% Generates `samples` from multivariate normal distribution, with mean `mu`
% and covariance `sigma`.
%
% See also: cv.randGaussMixture, mvnrnd
%
