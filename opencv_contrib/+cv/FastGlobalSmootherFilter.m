classdef FastGlobalSmootherFilter < handle
    %FASTGLOBALSMOOTHERFILTER  Interface for implementations of Fast Global Smoother filter
    %
    % For more details about this filter see [Min2014] and [Farbman2008].
    %
    % ## References
    % [Min2014]:
    % > Dongbo Min, Sunghwan Choi, Jiangbo Lu, Bumsub Ham, Kwanghoon Sohn,
    % > and Minh N Do. "Fast global image smoothing based on weighted least
    % > squares". IEEE Transactions on Image Processing, 23(12):5638-5653,
    % > 2014.
    %
    % [Farbman2008]:
    % > Zeev Farbman, Raanan Fattal, Dani Lischinski, and Richard Szeliski.
    % > "Edge-preserving decompositions for multi-scale tone and detail
    % > manipulation". In ACM Transactions on Graphics (TOG), volume 27,
    % > page 67. ACM, 2008.
    %
    % See also: cv.FastGlobalSmootherFilter.FastGlobalSmootherFilter
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    methods
        function this = FastGlobalSmootherFilter(guide, varargin)
            %FASTGLOBALSMOOTHERFILTER  Factory method, create instance of FastGlobalSmootherFilter and execute the initialization routines
            %
            %     obj = cv.FastGlobalSmootherFilter(guide)
            %     obj = cv.FastGlobalSmootherFilter(guide, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __guide__ image serving as guide for filtering. It should have
            %   8-bit depth and either 1 or 3 channels.
            %
            % ## Options
            % * __Lambda__ parameter defining the amount of regularization.
            %   default 100.0
            % * __SigmaColor__ parameter, that is similar to color space sigma
            %   in cv.bilateralFilter. default 5.0
            % * __LambdaAttenuation__ internal parameter, defining how much
            %   lambda decreases after each iteration. Normally, it should be
            %   0.25. Setting it to 1.0 may lead to streaking artifacts.
            %   default 0.25
            % * __NumIter__ number of iterations used for filtering, 3 is
            %   usually enough. default 3
            %
            % For more details about Fast Global Smoother parameters, see the
            % original paper [Min2014]. However, please note that there are
            % several differences. Lambda attenuation described in the paper
            % is implemented a bit differently so do not expect the results to
            % be identical to those from the paper; `SigmaColor` values from
            % the paper should be multiplied by 255.0 to achieve the same
            % effect. Also, in case of image filtering where source and guide
            % image are the same, authors propose to dynamically update the
            % guide image after each iteration. To maximize the performance
            % this feature was not implemented here.
            %
            % See also: cv.FastGlobalSmootherFilter.filter
            %
            this.id = FastGlobalSmootherFilter_(0, 'new', guide, varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.FastGlobalSmootherFilter
            %
            if isempty(this.id), return; end
            FastGlobalSmootherFilter_(this.id, 'delete');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.FastGlobalSmootherFilter.empty,
            %  cv.FastGlobalSmootherFilter.load
            %
            FastGlobalSmootherFilter_(this.id, 'clear');
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
            % See also: cv.FastGlobalSmootherFilter.clear,
            %  cv.FastGlobalSmootherFilter.load
            %
            b = FastGlobalSmootherFilter_(this.id, 'empty');
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
            % See also: cv.FastGlobalSmootherFilter.load
            %
            FastGlobalSmootherFilter_(this.id, 'save', filename);
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
            % See also: cv.FastGlobalSmootherFilter.save
            %
            FastGlobalSmootherFilter_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.FastGlobalSmootherFilter.save,
            %  cv.FastGlobalSmootherFilter.load
            %
            name = FastGlobalSmootherFilter_(this.id, 'getDefaultName');
        end
    end

    %% FastGlobalSmootherFilter
    methods
        function dst = filter(this, src)
            %FILTER  Apply smoothing operation to the source image
            %
            %     dst = obj.filter(src)
            %
            % ## Input
            % * __src__ source image for filtering with unsigned 8-bit or
            %   signed 16-bit or floating-point 32-bit depth and up to 4
            %   channels.
            %
            % ## Output
            % * __dst__ destination image.
            %
            % See also: cv.FastGlobalSmootherFilter.fastGlobalSmootherFilter
            %
            dst = FastGlobalSmootherFilter_(this.id, 'filter', src);
        end
    end

    methods (Static)
        function dst = fastGlobalSmootherFilter(src, guide, varargin)
            %FASTGLOBALSMOOTHERFILTER  Simple one-line Fast Global Smoother filter call
            %
            %     dst = cv.FastGlobalSmootherFilter.fastGlobalSmootherFilter(src, guide)
            %     dst = cv.FastGlobalSmootherFilter.fastGlobalSmootherFilter(src, guide, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __src__ source image for filtering with unsigned 8-bit or
            %   signed 16-bit or floating-point 32-bit depth and up to 4
            %   channels.
            % * __guide__ image serving as guide for filtering. It should have
            %   8-bit depth and either 1 or 3 channels.
            %
            % ## Output
            % * __dst__ destination image.
            %
            % ## Options
            % * __Lambda__ parameter defining the amount of regularization.
            %   default 100.0
            % * __SigmaColor__ parameter, that is similar to color space sigma
            %   in cv.bilateralFilter. default 5.0
            % * __LambdaAttenuation__ internal parameter, defining how much
            %   lambda decreases after each iteration. Normally, it should be
            %   0.25. Setting it to 1.0 may lead to streaking artifacts.
            %   default 0.25
            % * __NumIter__ number of iterations used for filtering, 3 is
            %   usually enough. default 3
            %
            % If you have multiple images to filter with the same guide then
            % use FastGlobalSmootherFilter interface to avoid extra
            % computations.
            %
            % See also: cv.FastGlobalSmootherFilter.filter
            %
            dst = FastGlobalSmootherFilter_(0, 'fastGlobalSmootherFilter', ...
                src, guide, varargin{:});
        end
    end

end
