%GLOB  Find all pathnames matching a specified pattern
%
%    result = cv.glob(pattern)
%    result = cv.glob(pattern, 'OptionName',optionValue, ...)
%
% ## Input
% * __pattern__ Pathname either absolute or relative, and can
%       contain wildcard characters (e.g 'Test*.m')
%
% ## Output
% * __result__ output sorted matched pathnames. Cell array of strings.
%
% ## Options
% * __Recursive__ If true, search files in subdirectories as well.
%       default false
%
% See also: dir
%
