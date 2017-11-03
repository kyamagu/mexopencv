%FILESTORAGE  Reading from or writing to a XML/YAML/JSON file storage
%
%     S = cv.FileStorage(source)
%     [S,~] = cv.FileStorage(source)
%
%     cv.FileStorage(source, S)
%     cv.FileStorage(source, X1, X2, ...)
%     str = cv.FileStorage(source, S)
%     str = cv.FileStorage(source, X1, X2, ...)
%
% ## Input
% * __source__ Name of the file to open or the text string to read the data
%   from. Extension of the file (`.xml`, `.yml`/`.yaml`, or `.json`)
%   determines its format (XML, YAML or JSON respectively). Also you can
%   append `.gz` to work with gzip-compressed files, for example
%   `myHugeMatrix.xml.gz`. When serializing to a string, `source` is used just
%   to specify the output file format (e.g. `mydata.xml`, `.yml`). A file name
%   can also contain parameters like `file.yml?base64` (case sensitive) in
%   which case it outputs sequences in Base64 encoding rather than in plain
%   text.
% * __S__ Scalar struct to be written to file. Each field represents an object
%   where the field name is the variable name, and the field value is the
%   object value.
% * __X1__, __X2__, __...__ objects to be written to file. This is equivalent
%   to the previous format with `S = struct('name',{{X1,X2,...}})` with a
%   placeholder field name based on the filename.
%
% ## Output
% * __S__ Scalar struct read from file. Each field represents a variable.
% * __str__ optional output when writing. If requested, the data is persisted
%   to a string in memory instead of writing to disk.
%
% The function reads or writes a MATLAB object from/to a
% [XML](http://www.w3.org/XML), [YAML](http://www.yaml.org), or
% [JSON](http://www.json.org/) file. The file is compatible with OpenCV
% formats.
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
%     vars = {'hi', pi, magic(5)};
%     cv.FileStorage('mydata.xml', vars{:});
%
%     S = struct();
%     S.(name) = vars;
%     cv.FileStorage('mydata.xml', S);
%
% where `name` is a default object name generated from the filename.
%
% A few limitations to be aware of:
%
% * numerical scalars of all kinds are imported as double type
%   (e.g `int32(1)` is loaded as `double(1)`).
% * Cell arrays are exported as linearized 1-dimensional arrays
%   (e.g: `{1 2; 3 4}` is saved as `{1 2 3 4}`).
% * Struct arrays are exported as linearized cell-array of scalar structs
%   (e.g: `repmat(struct('x',1), [2 2])` is saved as `{struct('x',1), ...}`).
% * Empty arrays (including numerical, struct, or cell) will not retain their
%   size in non-zero dimensions when exported
%   (e.g: `zeros(0,4)`, `cell(4,0)`, `struct([])`).
% * Certain formats (YAML) might trim strings when importing
%   (e.g: `' hi '` is loaded `'hi'`).
%
% ## Example
% A quick usage example is shown below.
%
% Writing to a file:
%
%     % export two variables to a YAML file
%     % first is a 2x3 matrix named field1, second is a string named field2
%     S = struct('field1',randn(2,3), 'field2','this is the second field');
%     cv.FileStorage('my.yml', S);
%
% Reading from a file:
%
%     % import variables from YAML file
%     S = cv.FileStorage('my.yml');
%     S.field1  % matrix
%     S.field2  % string
%
% Replace '.yml' with '.xml' to use XML format.
%
% ## Example
% Below is an example of four variables stored in XML, YAML and JSON files:
%
%     >> S = struct('var1',magic(3), 'var2','foo bar', 'var3',1, 'var4',{{2 3}});
%     >> cv.FileStorage('test.xml', S);
%     >> cv.FileStorage('test.yml', S);
%     >> cv.FileStorage('test.json', S);
%     >> S = cv.FileStorage('test.xml')
%     S =
%         var1: [3x3 double]
%         var2: 'foo bar'
%         var3: 1
%         var4: {[2]  [3]}
%
% * __XML__
%
% ```xml
% <?xml version="1.0"?>
% <opencv_storage>
%   <var1 type_id="opencv-matrix">
%     <rows>3</rows>
%     <cols>3</cols>
%     <dt>d</dt>
%     <data>8. 1. 6. 3. 5. 7. 4. 9. 2.</data>
%   </var1>
%   <var2>"foo bar"</var2>
%   <var3>1.</var3>
%   <var4>2. 3.</var4>
% </opencv_storage>
% ```
%
% * __YAML__
%
% ```yaml
% %YAML:1.0
% ---
% var1: !!opencv-matrix
%    rows: 3
%    cols: 3
%    dt: d
%    data: [ 8., 1., 6., 3., 5., 7., 4., 9., 2. ]
% var2: foo bar
% var3: 1.
% var4:
%    - 2.
%    - 3.
% ```
%
% * __JSON__
%
% ```json
% {
%     "var1": {
%         "type_id": "opencv-matrix",
%         "rows": 3,
%         "cols": 3,
%         "dt": "d",
%         "data": [ 8., 1., 6., 3., 5., 7., 4., 9., 2. ]
%     },
%     "var2": "foo bar",
%     "var3": 1.,
%     "var4": [
%         2.,
%         3.
%     ]
% }
% ```
%
% See also: load, save, xmlread, xmlwrite, jsonencode, jsondecode,
%  netcdf, h5info, hdfinfo, hdftool, cdflib
%
