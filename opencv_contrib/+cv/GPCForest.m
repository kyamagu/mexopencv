classdef GPCForest < handle
    %GPCFOREST  Implementation of the Global Patch Collider algorithm
    %
    % From the following paper:
    % [PDF](http://research.microsoft.com/en-us/um/people/pkohli/papers/wfrik_cvpr2016.pdf).
    %
    % ## Usage
    % - Train forest for the Global Patch Collider (or load a pretrained one).
    % - Find correspondences between two images using Global Patch Collider.
    %   These can be used to perform optical flow matching and stereo
    %   matching.
    %
    % You can obtain a file "forest.yml.gz" either by manually training it,
    % or by downloading one of the files pretrained on some publicly available
    % dataset from here:
    % [GPC](https://drive.google.com/open?id=0B7Hb8cfuzrIIZDFscXVYd0NBNFU)
    %
    % ## References
    % [Wang_2016_CVPR]:
    % > Shenlong Wang, Sean Ryan Fanello, Christoph Rhemann, Shahram Izadi,
    % > and Pushmeet Kohli. "The Global Patch Collider". In The IEEE
    % Conference on Computer Vision and Pattern Recognition (CVPR), June 2016.
    %
    % See also: cv.GPCForest.GPCForest
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    %% Constructor/destructor
    methods
        function this = GPCForest()
            %GPCFOREST  Creates an instance of GPCForest
            %
            %     obj = cv.GPCForest()
            %
            % See also: cv.GPCForest.findCorrespondences
            %
            this.id = GPCForest_(0, 'new');
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     obj.delete()
            %
            % See also: cv.GPCForest
            %
            if isempty(this.id), return; end
            GPCForest_(this.id, 'delete');
        end
    end

    %% GPCForest
    methods
        function train(this, imagesFrom, imagesTo, groundTruths, varargin)
            %TRAIN  Train the forest using individual samples for each tree
            %
            %     obj.train(imagesFrom, imagesTo, groundTruths)
            %     obj.train(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __imagesFrom__ First sequence of images, a cell array of
            %   either filenames or 3-channel color images.
            % * __imagesTo__ Second sequence of images, same size and format
            %   as `imagesFrom`.
            % * __groundTruth__ Ground thruth flows, either flow fields or
            %   filenames (see cv.readOpticalFlow).
            %
            % ## Options
            % * __MaxTreeDepth__ Maximum tree depth to stop partitioning.
            %   default 20
            % * __MinNumberOfSamples__ Minimum number of samples in the node
            %   to stop partitioning. default 3
            % * __DescriptorType__ Type of descriptors to use. One of:
            %   * __DCT__ (default) Better quality but slow.
            %   * __WHT__ Worse quality but much faster.
            % * __PrintProgress__ Print progress to stdout. default false
            %
            % Inputs form the training samples (pairs of images and ground
            % truth flows). Sizes of all the provided vectors must be equal.
            % Options are the training parameters.
            %
            % See also: cv.GPCForest.findCorrespondences
            %
            GPCForest_(this.id, 'train', imagesFrom, imagesTo, groundTruths, varargin{:});
        end

        function corrs = findCorrespondences(this, imgFrom, imgTo, varargin)
            %FINDCORRESPONDENCES  Find correspondences between two images
            %
            %     corrs = obj.findCorrespondences(imgFrom, imgTo)
            %     corrs = obj.findCorrespondences(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __imgFrom__ First 3-channel image in a sequence.
            % * __imgTo__ Second 3-channel image in a sequence.
            %
            % ## Output
            % * __corrs__ Output struct array with pairs of corresponding
            %   points.
            %
            % ## Options
            % * __UseOpenCL__ Whether to use OpenCL to speed up the matching.
            %   default false
            %
            % Options are the additional matching parameters for fine-tuning.
            %
            % See also: cv.GPCForest.train
            %
            corrs = GPCForest_(this.id, 'findCorrespondences', imgFrom, imgTo, varargin{:});
        end
    end

    %% Algorithm
    methods
        function clear(this)
            %CLEAR  Clears the algorithm state
            %
            %     obj.clear()
            %
            % See also: cv.GPCForest.empty
            %
            GPCForest_(this.id, 'clear');
        end

        function b = empty(this)
            %EMPTY  Returns true if the algorithm is empty
            %
            %     b = obj.empty()
            %
            % ## Output
            % * __b__ Returns true if the algorithm is empty (e.g. in the very
            %   beginning or after unsuccessful read).
            %
            % See also: cv.GPCForest.clear
            %
            b = GPCForest_(this.id, 'empty');
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
            % See also: cv.GPCForest.save, cv.GPCForest.load
            %
            name = GPCForest_(this.id, 'getDefaultName');
        end

        function save(this, filename)
            %SAVE  Saves the algorithm to a file
            %
            %     obj.save(filename)
            %
            % ## Input
            % * __filename__ Name of the file to save to.
            %
            % This method stores the algorithm parameters in a file storage.
            %
            % See also: cv.GPCForest.load
            %
            GPCForest_(this.id, 'save', filename);
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
            % This method reads algorithm parameters from a file storage.
            % The previous model state is discarded.
            %
            % See also: cv.GPCForest.save
            %
            GPCForest_(this.id, 'load', fname_or_str, varargin{:});
        end
    end

end
