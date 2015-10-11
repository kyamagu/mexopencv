%DECOMPOSEESSENTIALMAT  Decompose an essential matrix to possible rotations and translation
%
%    S = cv.decomposeEssentialMat(E)
%
% ## Input
% * __E__ The input essential matrix, 3x3.
%
% ## Output
% * __S__ Decomposed `E`. A scalar struct with the following fields:
%       * __R1__ One possible rotation matrix, 3x3.
%       * __R2__ Another possible rotation matrix, 3x3.
%       * __t__ One possible translation, 3x1.
%
% This function decompose an essential matrix `E` using SVD decomposition
% [HartleyZ00]. Generally 4 possible poses exists for a given `E`. They are
% `[R1,t]`, `[R1,-t]`, `[R2,t]`, `[R2,-t]`. By decomposing `E`, you can only
% get the direction of the translation, so the function returns unit `t`.
%
% ## References
% [HartleyZ00]:
% > Richard Hartley and Andrew Zisserman. "Multiple view geometry in computer
% > vision". Cambridge university press, 2003.
%
% See also: cv.findEssentialMat, cv.SVD
%
