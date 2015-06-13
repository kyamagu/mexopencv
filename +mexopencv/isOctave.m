function retval = isOctave()
    %ISOCTAVE  return true if the environment is Octave
    %
    %    retval = mexopencv.isOctave()
    %
    % ## Output
    % * __retval__ true if running in Octave, false otherwise (MATLAB).
    %
    % See also: ver, version
    %

    persistent cacheval;
    if isempty(cacheval)
        cacheval = (exist('OCTAVE_VERSION', 'builtin') > 0);
    end
    retval = cacheval;
end
