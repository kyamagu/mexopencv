%% Serialization Functionality
% Demonstrate the usage of OpenCV serialization functionality.
%
% This program demonstrates the use of |cv.FileStorage| for serialization in
% OpenCV. FileStorage allows you to serialize to various formats specified by
% the file end type. You should try using different file extensions
% (e.g. |.yaml|, |.yml|, |.xml|, |.xml.gz|, |.yaml.gz|, etc.)
%
% Sources:
%
% * <https://github.com/opencv/opencv/blob/3.1.0/samples/cpp/filestorage.cpp>
%

%% Data
% collect variables inside a struct (including cell array of strings,
% matrices/vectors, structs, scalar numerics, and strings)
S = struct();
S.images = {'image1.jpg', 'myfi.png', '../data/baboon.jpg'};
S.R = eye(3);
S.T = zeros(3,1);
S.mdata.A = int32(97);
S.mdata.X = pi;
S.mdata.id = 'mydata1234';
display(S)

%% Write
% save data as YAML file
fname = fullfile(tempdir(), 'out.yml');
cv.FileStorage(fname, S);

%%
% show contents of YAML file
type(fname)

%%
% we can also save as GZIP-compressed file
fnameGZ = fullfile(tempdir(), 'out.xml.gz');
cv.FileStorage(fnameGZ, S);

%%
% extract and show contents of XML file
f = gunzip(fnameGZ);
type(f{1})

%% Read
% load data from YAML file
SS = cv.FileStorage(fname);
display(SS)
%assert(isequal(S,SS))

%% Read from string
% a serialized string
str = {
    '%YAML:1.0'
    '# some comment'
    'mdata:'
    '  A: 97'
    '  X: 3.1415926535897931e+00'
    '  id: mydata1234'
    '  seq: [1, 2, 3]'
    '  map: {name: John Smith, age: 11}'
};
str = sprintf('%s\n', str{:});
display(str)

%%
% load data from string
[M,~] = cv.FileStorage(str);
display(M.mdata)

%% Write to string
% encode data as a YAML string
str2 = cv.FileStorage('.yml', M);
display(str2)
