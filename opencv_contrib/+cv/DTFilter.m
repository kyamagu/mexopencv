classdef DTFilter < handle
    %DTFILTER  Interface for realizations of Domain Transform filter
    %
    % For more details about this filter see [Gastal11].
    %
    % ## References
    % [Gastal11]:
    % > Eduardo SL Gastal and Manuel M Oliveira. "Domain transform for
    % > edge-aware image and video processing". In ACM Transactions on
    % > Graphics (TOG), volume 30, page 69. ACM, 2011.
    %
    % See also: cv.DTFilter.DTFilter
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    methods
        function this = DTFilter(guide, varargin)
            %DTFILTER  Factory method, create instance of DTFilter and produce initialization routines
            %
            %     obj = cv.DTFilter(guide)
            %     obj = cv.DTFilter(guide, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __guide__ guided image (used to build transformed distance,
            %   which describes edge structure of guided image).
            %
            % ## Options
            % * __SigmaSpatial__ `sigma_H` parameter in the original article,
            %   it's similar to the sigma in the coordinate space into
            %   cv.bilateralFilter. default 10.0
            % * __SigmaColor__ `sigma_r` parameter in the original article,
            %   it's similar to the sigma in the color space into
            %   cv.bilateralFilter. default 25.0
            % * __Mode__ one form three modes which corresponds to three modes
            %   for filtering 2D signals in the article. default 'NC':
            %   * __NC__ Normalized Convolution (NC).
            %   * __IC__ Interpolated Convolution (IC).
            %   * __RF__ Recursive Filtering (RF).
            % * __NumIters__ optional number of iterations used for filtering,
            %   3 is quite enough. default 3
            %
            % For more details about Domain Transform filter parameters, see
            % the original article [Gastal11] and Domain Transform filter
            % [homepage](http://www.inf.ufrgs.br/~eslgastal/DomainTransform/).
            %
            % See also: cv.DTFilter.filter
            %
            this.id = DTFilter_(0, 'new', guide, varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.DTFilter
            %
            if isempty(this.id), return; end
            DTFilter_(this.id, 'delete');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.DTFilter.empty, cv.DTFilter.load
            %
            DTFilter_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Checks if detector object is empty
            %
            %     b = obj.empty()
            %
            % ## Output
            % * __b__ Returns true if the detector object is empty (e.g in the
            %   very beginning or after unsuccessful read).
            %
            % See also: cv.DTFilter.clear, cv.DTFilter.load
            %
            b = DTFilter_(this.id, 'empty');
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
            % See also: cv.DTFilter.load
            %
            DTFilter_(this.id, 'save', filename);
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
            % See also: cv.DTFilter.save
            %
            DTFilter_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.DTFilter.save, cv.DTFilter.load
            %
            name = DTFilter_(this.id, 'getDefaultName');
        end
    end

    %% DTFilter
    methods
        function dst = filter(this, src, varargin)
            %FILTER  Produce domain transform filtering operation on source image
            %
            %     dst = obj.filter(src)
            %     dst = obj.filter(src, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __src__ filtering image with unsigned 8-bit or floating-point
            %   32-bit depth and up to 4 channels.
            %
            % ## Output
            % * __dst__ destination image.
            %
            % ## Options
            % * __DDepth__ optional depth of the output image. `DDepth` can be
            %   set to -1, which will be equivalent to `class(src)`. default -1
            %
            % See also: cv.DTFilter.DTFilter, cv.DTFilter.dtFilter
            %
            dst = DTFilter_(this.id, 'filter', src, varargin{:});
        end
    end

    methods (Static)
        function dst = dtFilter(src, guide, varargin)
            %DTFILTER  Simple one-line Domain Transform filter call
            %
            %     dst = cv.DTFilter.dtFilter(src, guide)
            %     dst = cv.DTFilter.dtFilter(src, guide, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __src__ filtering image with unsigned 8-bit or floating-point
            %   32-bit depth and up to 4 channels.
            % * __guide__ guided image (also called as joint image) with
            %   unsigned 8-bit or floating-point 32-bit depth and up to 4
            %   channels.
            %
            % ## Output
            % * __dst__ destination image.
            %
            % ## Options
            % * __SigmaSpatial__ `sigma_H` parameter in the original article,
            %   it's similar to the sigma in the coordinate space into
            %   cv.bilateralFilter. default 10.0
            % * __SigmaColor__ `sigma_r` parameter in the original article,
            %   it's similar to the sigma in the color space into
            %   cv.bilateralFilter. default 25.0
            % * __Mode__ one form three modes which corresponds to three modes
            %   for filtering 2D signals in the article. default 'NC':
            %   * __NC__ Normalized Convolution (NC).
            %   * __IC__ Interpolated Convolution (IC).
            %   * __RF__ Recursive Filtering (RF).
            % * __NumIters__ optional number of iterations used for filtering,
            %   3 is quite enough. default 3
            %
            % If you have multiple images to filter with the same guided image
            % then use DTFilter interface to avoid extra computations on
            % initialization stage.
            %
            % See also: cv.DTFilter.filter, cv.bilateralFilter,
            %  cv.GuidedFilter.guidedFilter, cv.AdaptiveManifoldFilter.amFilter
            %
            dst = DTFilter_(0, 'dtFilter', src, guide, varargin{:});
        end
    end

end
