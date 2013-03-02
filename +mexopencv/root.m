function p = root()
    %ROOT  Obtain mexopencv root path
    p = fileparts(fileparts(mfilename('fullpath')));
end
