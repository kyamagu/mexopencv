%TRANSFORM  Performs the matrix transformation of every array element
%
%    dst = cv.transform(src, mtx)
%
% ## Input
% * __src__ Source array that must have as many channels (1 to 4) as columns
%        of `mtx` or columns-1 of `mtx`
% * __mtx__ floating-point transformation matrix.
%
% ## Output
% * __dst__ Destination array of the same row/column size and depth as `src`.
%        It has as many channels as rows of `mtx`
%
% The function cv.transform performs the matrix transformation of every
% element of the array `src` and stores the results in `dst`:
%
% * when columns of `mtx` equal channels of `src`:
%
%        dst(I) = mtx * src(I)
%
% * when columns of `mtx` equal channels+1 of `src`:
%
%        dst(I) = mtx * [src(I); 1]
%
% Every element of the N-channel array `src` is interpreted as N-element
% vector that is transformed using the MxN or Mx(N+1) matrix `mtx` to
% M-element vector - the corresponding element of the destination array
% `dst`.
%
% The function may be used for geometrical transformation of N-dimensional
% points, arbitrary linear color space transformation (such as various
% kinds of RGB to YUV transforms), shuffling the image channels, and so
% forth.
%
% ## Example
% This function is equivalent to the following MATLAB code:
%
%    function dst = my_transform(src, mtx)
%        % check sizes
%        [I,J,N] = size(src);
%        [MM,NN] = size(mtx);
%        assert(N==1 || N==2 || N==3 || N==4, '1 to 4 channels');
%        assert(N==NN || (N+1)==NN, 'Wrong dimensions');
%        if N ~= NN, src(:,:,end+1) = 1; end
%
%        % transform
%        dst = zeros([I,J,MM], class(src));
%        for i=1:I
%            for j=1:J
%                dst(i,j,:) = mtx * squeeze(src(i,j,:));
%            end
%        end
%    end
%
% See also: cv.perspectiveTransform, cv.getAffineTransform,
%  cv.estimateRigidTransform, cv.warpAffine, cv.warpPerspective
%
