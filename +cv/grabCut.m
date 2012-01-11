%GRABCUT  Runs the GrabCut algorithm
%
%    [ trimap ] = grabCut(img, bbox);
%    [ trimap ] = grabCut(img, trimap);
%    [ trimap ] = grabCut(img, trimap, 'Init', initMethod, ...);
%    [ trimap ] = grabCut(img, trimap, 'MaxIter', maxIter, ...);
%
%  Input:
%    img: uint8 type H-by-W-by-3 RGB array
%    bbox: 1-by-4 double array [x y w h]
%          It will automatically create a trimap initialized with
%          label 0 for background and label 3 for foreground (see trimap)
%    trimap: uint8 H-by-W array of labels
%            {0:bg, 1:fg, 2:probably-bg, 3:probably-fg}
%    options: 'Init' can take either 'Rect' or 'Mask'. Default to the
%             form of second argument.
%             'MaxIter' specifies maximum number of iteration.
%  Output:
%    trimap: uint8 H-by-W array with
%            {0:bg, 1:fg, 2:probably-bg, 3:probably-fg}
%