function p = root()
    %ROOT  Obtain mexopencv root path
    %
    persistent p_cache
    if isempty(p_cache)
        p_cache = fileparts(fileparts(mfilename('fullpath')));
    end
    p = p_cache;
end
