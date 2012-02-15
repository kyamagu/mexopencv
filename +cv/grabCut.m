%GRABCUT  Runs the GrabCut algorithm
%
%    [ trimap ] = cv.grabCut(img, bbox);
%    [ trimap ] = cv.grabCut(img, trimap);
%    [ trimap ] = cv.grabCut(img, trimap, 'Init', initMethod, ...);
%    [ trimap ] = cv.grabCut(img, trimap, 'MaxIter', maxIter, ...);
%
% ## Input
% * __img__ uint8 type H-by-W-by-3 RGB array
% * __bbox__ 1-by-4 double array [x y w h]
%          It will automatically create a trimap initialized with
%          label 0 for background and label 3 for foreground (see trimap)
% * __trimap__ uint8 H-by-W array of labels
%            {0:bg, 1:fg, 2:probably-bg, 3:probably-fg}
% * __options__ 'Init' can take either 'Rect' or 'Mask'. Default to the
%             form of second argument.
%             'MaxIter' specifies maximum number of iteration.
%
% ## Output
% * __trimap__ uint8 H-by-W array with
%            {0:bg, 1:fg, 2:probably-bg, 3:probably-fg}
%
% See also cv.watershed
%
