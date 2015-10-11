%GRABCUT  Runs the GrabCut algorithm
%
%    mask = cv.grabCut(img, rect);
%    mask = cv.grabCut(img, mask);
%    [mask, bgdmodel, fgdmodel] = cv.grabCut(...);
%    [...] = cv.grabCut(..., 'OptionName', optionValue, ...);
%
% ## Input
% * __img__ Input 8-bit 3-channel image.
% * __rect__ ROI containing a segmented object. A 1-by-4 vector `[x y w h]`.
%       It will automatically create the `mask`. The pixels outside of the ROI
%       are marked as "obvious background" with label 0, and label 3 for
%       foreground (see `mask`). Using this variant will set `Mode` to
%       'InitWithRect'.
% * __mask__ Input 8-bit single-channel mask of same size as `img` and type
%       `uint8`. Its elements may have one of the following values:
%       * __0__ an obvious background pixel
%       * __1__ an obvious foreground (object) pixel
%       * __2__ a possible background pixel
%       * __3__ a possible foreground pixel
%
% ## Output
% * __mask__ output 8-bit single-channel updated mask. The mask is initialized
%       by the function when `Mode` is set to 'InitWithRect' (see `rect`).
% * __bgdmodel__ Output array for the background model, to be used for next
%       iteration. Do not modify it while you are processing the same image.
% * __fgdmodel__ Output array for the foreground model, to be used for next
%       iteration. Do not modify it while you are processing the same image.
%
% ## Options
% * __BgdModel__ Initial array for the background model. A 1x65 double vector.
% * __FgdModel__ Initial array for the foreground model. A 1x65 double vector.
% * __IterCount__ Number of iterations the algorithm should make before
%       returning the result. Note that the result can be refined with further
%       calls with `Mode` as 'InitWithMask' or 'Eval'. Default 10
% * __Mode__ Operation mode, default 'Eval'. Could be one of the following:
%       * __InitWithRect__ The function initializes the state and the mask
%             using the provided rectangle. After that it runs `IterCount`
%             iterations of the algorithm. This should only be used with the
%             variant of the function that takes `rect` as input.
%       * __InitWithMask__ The function initializes the state using the
%             provided `mask`. Then, all the pixels outside of the ROI are
%             automatically initialized as background with label 0. This
%             should only be used with the variant of the function that takes
%             `mask` as input.
%       * __Eval__ The value means that the algorithm should just resume.
%
% The function implements the GrabCut image segmentation algorithm.
% http://en.wikipedia.org/wiki/GrabCut
%
% See also: cv.watershed
%
