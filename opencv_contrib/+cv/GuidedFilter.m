classdef GuidedFilter < handle
    %GUIDEDFILTER  Interface for realizations of Guided Filter
    %
    % For more details about this filter see [Kaiming10].
    %
    % ## References
    % [Kaiming10]:
    % > Kaiming He, Jian Sun, and Xiaoou Tang. "Guided image filtering".
    % > In Computer Vision ECCV 2010, pages 1-14. Springer, 2010.
    %
    % See also: cv.GuidedFilter.GuidedFilter, imguidedfilter
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    methods
        function this = GuidedFilter(guide, varargin)
            %GUIDEDFILTER  Factory method, create instance of GuidedFilter and produce initialization routines
            %
            %     obj = cv.GuidedFilter(guide)
            %     obj = cv.GuidedFilter(guide, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __guide__ guided image with up to 3 channels, if it have more
            %   then 3 channels then only first 3 channels will be used.
            %
            % ## Options
            % * __Radius__ radius of Guided Filter. default 7
            % * __EPS__ regularization term of Guided Filter. `eps^2` is
            %   similar to the sigma in the color space into
            %   cv.bilateralFilter. default 500.0
            %
            % For more details about Guided Filter parameters, see the
            % original article [Kaiming10].
            %
            % See also: cv.GuidedFilter.filter
            %
            this.id = GuidedFilter_(0, 'new', guide, varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.GuidedFilter
            %
            if isempty(this.id), return; end
            GuidedFilter_(this.id, 'delete');
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.GuidedFilter.empty, cv.GuidedFilter.load
            %
            GuidedFilter_(this.id, 'clear');
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
            % See also: cv.GuidedFilter.clear, cv.GuidedFilter.load
            %
            b = GuidedFilter_(this.id, 'empty');
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
            % See also: cv.GuidedFilter.load
            %
            GuidedFilter_(this.id, 'save', filename);
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
            % See also: cv.GuidedFilter.save
            %
            GuidedFilter_(this.id, 'load', fname_or_str, varargin{:});
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
            % See also: cv.GuidedFilter.save, cv.GuidedFilter.load
            %
            name = GuidedFilter_(this.id, 'getDefaultName');
        end
    end

    %% GuidedFilter
    methods
        function dst = filter(this, src, varargin)
            %FILTER  Apply Guided Filter to the filtering image
            %
            %     dst = obj.filter(src)
            %     dst = obj.filter(src, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __src__ filtering image with any numbers of channels.
            %
            % ## Output
            % * __dst__ output image.
            %
            % ## Options
            % * __DDepth__ optional depth of the output image. `DDepth` can be
            %   set to -1, which will be equivalent to `class(src)`. Default -1
            %
            % See also: cv.GuidedFilter.GuidedFilter,
            %  cv.GuidedFilter.guidedFilter
            %
            dst = GuidedFilter_(this.id, 'filter', src, varargin{:});
        end
    end

    methods (Static)
        function dst = guidedFilter(src, guide, varargin)
            %GUIDEDFILTER  Simple one-line Guided Filter call
            %
            %     dst = cv.GuidedFilter.guidedFilter(src, guide)
            %     dst = cv.GuidedFilter.guidedFilter(src, guide, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __src__ filtering image with any numbers of channels.
            % * __guide__ guided image with up to 3 channels, if it have more
            %   then 3 channels then only first 3 channels will be used.
            %
            % ## Output
            % * __dst__ output image.
            %
            % ## Options
            % * __Radius__ radius of Guided Filter. default 7
            % * __EPS__ regularization term of Guided Filter. `eps^2` is
            %   similar to the sigma in the color space into
            %   cv.bilateralFilter. default 500.0
            % * __DDepth__ optional depth of the output image. `DDepth` can be
            %   set to -1, which will be equivalent to `class(src)`. Default -1
            %
            % If you have multiple images to filter with the same guided image
            % then use GuidedFilter interface to avoid extra computations on
            % initialization stage.
            %
            % See also: cv.GuidedFilter.filter, cv.bilateralFilter,
            %  cv.DTFilter.dtFilter, cv.AdaptiveManifoldFilter.amFilter
            %
            dst = GuidedFilter_(0, 'guidedFilter', src, guide, varargin{:});
        end
    end

end
