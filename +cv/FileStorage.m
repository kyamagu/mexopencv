%FILESTORAGE  Reading from or writing to a XML/YAML file storage
%
%    S = cv.FileStorage(fileName)
%    [S,~] = cv.FileStorage(str)
%
%    cv.FileStorage(fileName, S)
%    cv.FileStorage(fileName, X1, X2, ...)
%    str = cv.FileStorage(fileName, S)
%    str = cv.FileStorage(fileName, X1, X2, ...)
%
% ## Input
% * __fileName__ Name of the XML/YAML file. The file name should have either
%        `.xml` or `.yml` extension.
% * __S__ Scalar struct to be written to file.
% * __X1__, __X2__, __...__ objects to be written to file.
%
% ## Output
% * __S__ Scalar struct read from file.
% * __str__ optional output when writing. If requested, the data is persisted
%       to a string in memory instead of writing to disk.
%
% The function reads or writes a MATLAB object from/to a XML/YAML file. The
% file is compatible with OpenCV formats.
%
% The functions supports gzip-compressed files by appending `.gz` to the
% filename extension, i.e `.xml.gz` or `.yml.gz`.
%
% The function also supports reading and writing from/to serialized strings.
% In reading mode, a second dummpy output is used to differentiate between
% whether the input is a filename or a serialized string.
%
% In writing mode, and when the input argument is not a scalar struct (`S`),
% the function creates a scalar struct with default field name and stores the
% objects (`X1`, `X2`, ...) in that struct. In other words the following
% forms are equivalent:
%
%    vars = {'hi', pi, magic(5)};
%    cv.FileStorage(filename, vars{:});
%
%    S = struct();
%    S.(name) = vars;
%    cv.FileStorage(filename, S);
%
% where `name` is a default object name generated from `filename`.
%
% ## Example
% A quick usage example is shown below.
%
% Writing to a file:
%
%    S = struct('field1', randn(2,3), 'field2', 'this is the second field');
%    cv.FileStorage('my.yml',S);
%
% Reading from a file:
%
%    S = cv.FileStorage('my.yml');
%
% Replace '.yml' with '.xml' to use XML format.
%
% See also: load, save, xmlread, xmlwrite, jsonencode, jsondecode,
%  netcdf, h5info, hdfinfo, hdftool, cdflib
%
