%FILESTORAGE  Reading from or writing to a XML/YAML file storage
%
%    S = cv.FileStorage(fileName)
%    cv.FileStorage(fileName, S)
%    cv.FileStorage(fileName, X1, X2, ...)
%
% ## Input
% * __fileName__ Name of the XML/YAML file. The file name should have either .xml
%        or .yml extension.
% * __S__ Scalar struct to be written to a file
% * __X1__, __X2__, __...__ objects to be written to a file
%
% ## Output
% * __S__ Scalar struct read from a file
%
% The function reads or writes a Matlab object from/to a XML/YAML file. The file
% is compatible to OpenCV formats. When input argument is not a scalar
% struct, the function creates a scalar struct with default field name and
% stores the objects in that struct.
%
% A quick usage example is shown below:
%
% Writing to a file
%
%    S = struct('field1', randn(2,3), 'field2', 'this is the second field');
%    cv.FileStorage('my.yml',S);
%
% Reading from a file
%
%    S = cv.FileStorage('my.yml');
%
% Replace '.yml' to '.xml' to use XML format.
%
% See also load save
%
