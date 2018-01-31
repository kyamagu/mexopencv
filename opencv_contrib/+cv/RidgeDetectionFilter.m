classdef RidgeDetectionFilter < handle
    %RIDGEDETECTIONFILTER  Ridge Detection Filter
    %
    % Implements Ridge detection similar to the one in
    % [Mathematica](http://reference.wolfram.com/language/ref/RidgeFilter.html)
    % using the eigen values from the Hessian Matrix of the input image using
    % Sobel Derivatives. Additional refinement can be done using
    % Skeletonization and Binarization.
    %
    % See also: cv.RidgeDetectionFilter.RidgeDetectionFilter, cv.Sobel,
    %  cv.threshold, cv.getStructuringElement, cv.morphologyEx
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    %% RidgeDetectionFilter
    methods
        function this = RidgeDetectionFilter(varargin)
            %RIDGEDETECTIONFILTER  Creates instance of the Ridge detection filter
            %
            %     obj = cv.RidgeDetectionFilter()
            %     obj = cv.RidgeDetectionFilter('OptionName',optionValue, ...)
            %
            % ## Options
            % * __DDepth__ Specifies output image depth, one of `single` or
            %   `double`. Default is `single`
            % * __Dx__ Order of derivative x, default is 1
            % * __Dy__ Order of derivative y, default is 1
            % * __KSize__ Sobel kernel size (1, 3, 5, or 7), default is 3
            % * __OutDType__ Converted format for output, default is `uint8`
            % * __Scale__ Optional scale value for derivative values,
            %   default is 1
            % * __Delta__ Optional bias added to output, default is 0
            % * __BorderType__ Pixel extrapolation method.
            %   See cv.copyMakeBorder. Default is 'Default'
            %
            % Above options have the same meaning as cv.Sobel options.
            %
            % See also: cv.RidgeDetectionFilter.getRidgeFilteredImage
            %
            this.id = RidgeDetectionFilter_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.RidgeDetectionFilter
            %
            if isempty(this.id), return; end
            RidgeDetectionFilter_(this.id, 'delete');
        end

        function out = getRidgeFilteredImage(this, img)
            %GETRIDGEFILTEREDIMAGE  Apply Ridge detection filter on input image
            %
            %     out = obj.getRidgeFilteredImage(img)
            %
            % ## Input
            % * __img__ Input array as supported by cv.Sobel. `img` can be
            %   1-channel or 3-channels (color images are converted to
            %   grayscale).
            %
            % ## Output
            % * __out__ Output array of depth as specified in `DDepth` in
            %   constructor. Output image with ridges.
            %
            % See also: cv.RidgeDetectionFilter.amFilter
            %
            out = RidgeDetectionFilter_(this.id, 'getRidgeFilteredImage', img);
        end
    end

    %% Algorithm
    methods (Hidden)
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.RidgeDetectionFilter.empty,
            %  cv.RidgeDetectionFilter.load
            %
            RidgeDetectionFilter_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Checks if algorithm object is empty
            %
            %     b = obj.empty()
            %
            % ## Output
            % * __b__ Returns true if the algorithm object is empty
            %   (e.g. in the very beginning or after unsuccessful read).
            %
            % See also: cv.RidgeDetectionFilter.clear,
            %  cv.RidgeDetectionFilter.load
            %
            b = RidgeDetectionFilter_(this.id, 'empty');
        end

        function save(this, filename)
            %SAVE  Saves the algorithm parameters to a file
            %
            %     obj.save(filename)
            %
            % ## Input
            % * __filename__ Name of the file to save to.
            %
            % This method stores the algorithm parameters in the specified
            % XML or YAML file.
            %
            % See also: cv.RidgeDetectionFilter.load
            %
            RidgeDetectionFilter_(this.id, 'save', filename);
        end

        function load(this, fname_or_str, varargin)
            %LOAD  Loads algorithm from a file or a string
            %
            %     obj.load(fname)
            %     obj.load(str, 'FromString',true)
            %     obj.load(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __fname__ Name of the file to read.
            % * __str__ String containing the serialized model you want to
            %   load.
            %
            % ## Options
            % * __ObjName__ The optional name of the node to read (if empty,
            %   the first top-level node will be used). default empty
            % * __FromString__ Logical flag to indicate whether the input is a
            %   filename or a string containing the serialized model.
            %   default false
            %
            % This method reads algorithm parameters from the specified XML or
            % YAML file (either from disk or serialized string). The previous
            % algorithm state is discarded.
            %
            % See also: cv.RidgeDetectionFilter.save
            %
            RidgeDetectionFilter_(this.id, 'load', fname_or_str, varargin{:});
        end

        function name = getDefaultName(this)
            %GETDEFAULTNAME  Returns the algorithm string identifier
            %
            %     name = obj.getDefaultName()
            %
            % ## Output
            % * __name__ This string is used as top level XML/YML node tag
            %   when the object is saved to a file or string.
            %
            % See also: cv.RidgeDetectionFilter.save,
            %  cv.RidgeDetectionFilter.load
            %
            name = RidgeDetectionFilter_(this.id, 'getDefaultName');
        end
    end

end
