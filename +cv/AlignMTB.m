classdef AlignMTB < handle
    %ALIGNMTB  Aligns images of the same scene with different exposures
    %
    % This algorithm converts images to median threshold bitmaps (1 for pixels
    % brighter than median luminance and 0 otherwise) and than aligns the
    % resulting bitmaps using bit operations.
    %
    % It is invariant to exposure, so exposure values and camera response are
    % not necessary.
    %
    % In this implementation new image regions are filled with zeros.
    %
    % For more information see [GW03].
    %
    % ## References
    % [GW03]:
    % > Greg Ward. "Fast, robust image registration for compositing high
    % > dynamic range photographs from hand-held exposures".
    % > Journal of graphics tools, 8(2):17-30, 2003.
    %
    % See also: cv.AlignMTB.AlignMTB
    %

    properties (SetAccess = private)
        id % Object ID
    end

    properties (Dependent)
        % logarithm to the base 2 of maximal shift in each dimension.
        %
        % Values of 5 and 6 are usually good enough (31 and 63 pixels shift
        % respectively).
        MaxBits
        % range for exclusion bitmap that is constructed to suppress noise
        % around the median value.
        ExcludeRange
        % if true cuts images, otherwise fills the new regions with zeros.
        Cut
    end

    %% AlignMTB
    methods
        function this = AlignMTB(varargin)
            %ALIGNMTB  Creates AlignMTB object
            %
            %    obj = cv.AlignMTB()
            %    obj = cv.AlignMTB('OptionName',optionValue, ...)
            %
            % ## Options
            % * __MaxBits__ default 6
            % * __ExcludeRange__ default 4
            % * __Cut__ default true
            %
            % See also: cv.AlignMTB.process
            %
            this.id = AlignMTB_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also cv.AlignMTB
            %
            AlignMTB_(this.id, 'delete');
        end

        function shift = calculateShift(this, img0, img1)
            %CALCULATESHIFT  Calculates shift between two images
            %
            %    shift = obj.calculateShift(img0, img1)
            %
            % ## Input
            % * __img0__ first image (`uint8` grayscale).
            % * __img1__ second image of same size and type as `img0`.
            %
            % ## Output
            % * __shift__ calculated shift `[x,y]`.
            %
            % Calculates shift between two images, i. e. how to shift the
            % second image to correspond it with the first.
            %
            % See also: cv.AlignMTB.shiftMat
            %
            shift = AlignMTB_(this.id, 'calculateShift', img0, img1);
        end

        function dst = shiftMat(this, src, shift)
            %SHIFTMAT  Helper function, that shift Mat filling new regions with zeros
            %
            %    dst = obj.shiftMat(src, shift)
            %
            % ## Input
            % * __src__ input image.
            % * __shift__ shift value `[x,y]`.
            %
            % ## Output
            % * __dst__ result image, same size and type as `src`.
            %
            % See also: cv.AlignMTB.calculateShift
            %
            dst = AlignMTB_(this.id, 'shiftMat', src, shift);
        end

        function [tb, eb] = computeBitmaps(this, img)
            %COMPUTEBITMAPS  Computes median threshold and exclude bitmaps of given image
            %
            %    [tb,eb] = obj.computeBitmaps(img)
            %
            % ## Input
            % * __img__ input image (`uint8` grayscale).
            %
            % ## Output
            % * __tb__ median threshold bitmap, of same size as `img` and
            %       `uint8` type.
            % * __eb__ exclude bitmap, of same size as `img` and `uint8` type.
            %
            % See also: cv.AlignMTB.process
            %
            [tb, eb] = AlignMTB_(this.id, 'computeBitmaps', img);
        end
    end

    %% AlignExposures
    methods
        function dst = process(this, src)
            %PROCESS  Aligns images
            %
            %    dst = obj.process(src)
            %
            % ## Input
            % * __src__ cell array of input images (RGB), all of the same size
            %       and `uint8` type.
            %
            % ## Output
            % * __dst__ cell array of aligned images, of same length as `src`.
            %
            % See also: cv.AlignMTB.AlignMTB
            %
            dst = AlignMTB_(this.id, 'process', src);
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %    obj.clear()
            %
            % See also: cv.AlignMTB.empty, cv.AlignMTB.load
            %
            AlignMTB_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Returns true if the Algorithm is empty
            %
            %    b = obj.empty()
            %
            % ## Output
            % * __b__ Returns true if the object is empty (e.g in the
            %       very beginning or after unsuccessful read).
            %
            % See also: cv.AlignMTB.clear, cv.AlignMTB.load
            %
            b = AlignMTB_(this.id, 'empty');
        end

        function name = getDefaultName(this)
            %GETDEFAULTNAME  Returns the algorithm string identifier
            %
            %    name = obj.getDefaultName()
            %
            % ## Output
            % * __name__ This string is used as top level XML/YML node tag
            %       when the object is saved to a file or string.
            %
            % See also: cv.AlignMTB.save, cv.AlignMTB.load
            %
            name = AlignMTB_(this.id, 'getDefaultName');
        end

        function save(this, filename)
            %SAVE  Saves the algorithm parameters to a file
            %
            %    obj.save(filename)
            %
            % ## Input
            % * __filename__ Name of the file to save to.
            %
            % This method stores the algorithm parameters in the specified
            % XML or YAML file.
            %
            % See also: cv.AlignMTB.load
            %
            AlignMTB_(this.id, 'save', filename);
        end

        function load(this, fname_or_str, varargin)
            %LOAD  Loads algorithm from a file or a string
            %
            %    obj.load(fname)
            %    obj.load(str, 'FromString',true)
            %    obj.load(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __fname__ Name of the file to read.
            % * __str__ String containing the serialized model you want to
            %       load.
            %
            % ## Options
            % * __ObjName__ The optional name of the node to read (if empty,
            %       the first top-level node will be used). default empty
            % * __FromString__ Logical flag to indicate whether the input is
            %       a filename or a string containing the serialized model.
            %       default false
            %
            % This method reads algorithm parameters from the specified XML or
            % YAML file (either from disk or serialized string). The previous
            % algorithm state is discarded.
            %
            % See also: cv.AlignMTB.save
            %
            AlignMTB_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

    %% Getters/Setters
    methods
        function value = get.MaxBits(this)
            value = AlignMTB_(this.id, 'get', 'MaxBits');
        end
        function set.MaxBits(this, value)
            AlignMTB_(this.id, 'set', 'MaxBits', value);
        end

        function value = get.ExcludeRange(this)
            value = AlignMTB_(this.id, 'get', 'ExcludeRange');
        end
        function set.ExcludeRange(this, value)
            AlignMTB_(this.id, 'set', 'ExcludeRange', value);
        end

        function value = get.Cut(this)
            value = AlignMTB_(this.id, 'get', 'Cut');
        end
        function set.Cut(this, value)
            AlignMTB_(this.id, 'set', 'Cut', value);
        end
    end

end
