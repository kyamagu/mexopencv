%GRABCUT  Runs the GrabCut algorithm
%
%    [ trimap ] = cv.grabCut(img, bbox);
%    [ trimap ] = cv.grabCut(img, trimap);
%    [ trimap ] = cv.grabCut(img, trimap, 'OptionName', optionValue, ...);
%    [ trimap, bgdmodel, fgdmodel ] = cv.grabCut(...);
%
% ## Input
% * __img__ uint8 type H-by-W-by-3 RGB array
% * __bbox__ 1-by-4 double array [x y w h]
%          It will automatically create a trimap initialized with
%          label 0 for background and label 3 for foreground (see trimap)
% * __trimap__ uint8 H-by-W array of labels
%            {0:bg, 1:fg, 2:probably-bg, 3:probably-fg}
%
% ## Output
% * __trimap__ uint8 H-by-W array with
%            {0:bg, 1:fg, 2:probably-bg, 3:probably-fg}
% * __bgdmodel__ background model to be used for next iteration.
% * __fgdmodel__ foreground model to be used for next iteration.
%
% ## Options
% * __BgdModel__ Initial background model from the output.
% * __FgdModel__ Initial foreground model from the output.
% * __Init__ Initialization method. One of the following. Default is
%     automatically determined from the second argument.
%     __'Rect'__ Second argument is treated as a rectangle to start.
%     __'Mask'__ Second argument is treated as an initial trimap.
%     __'Eval'__ GrabCut algorithm should just resume.
% * __MaxIter__ Specifies maximum number of iteration.
%
% See also cv.watershed
%
