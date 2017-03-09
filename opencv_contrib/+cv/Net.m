classdef Net < handle
    %NET  Create and manipulate comprehensive artificial neural networks
    %
    % This module contains:
    %
    % - API for new layers creation, layers are building bricks of neural
    %   networks;
    % - set of built-in most-useful Layers;
    % - API to constuct and modify comprehensive neural networks from layers;
    % - functionality for loading serialized networks models from differnet
    %   frameworks.
    %
    % Functionality of this module is designed only for forward pass
    % computations (i. e. network testing). A network training is in principle
    % not supported.
    %
    % ## Net class
    % Neural network is presented as directed acyclic graph (DAG), where
    % vertices are Layer instances, and edges specify relationships between
    % layers inputs and outputs.
    %
    % Each network layer has unique integer id and unique string name inside
    % its network. LayerId can store either layer name or layer id.
    %
    % See also: cv.Net.Net, cv.Net.import, nnet.cnn.layer.Layer, SeriesNetwork
    %

    properties (SetAccess = private)
        id    % Object ID
    end

    %% Constructor/destructor
    methods
        function this = Net(varargin)
            %NET  Default constructor
            %
            %    net = cv.Net()
            %    net = cv.Net(...)
            %
            % The first variant creates an empty network.
            %
            % The second variant accepts the same parameters as the import
            % method, in which case it forwards the call after construction.
            %
            % See also: cv.Net.import, cv.Net.forward
            %
            this.id = Net_(0, 'new');
            if nargin > 0
                this.import(varargin{:});
            end
        end

        function delete(this)
            %DELETE  Destructor
            %
            %    net.delete()
            %
            % See also: cv.Net
            %
            if isempty(this.id), return; end
            Net_(this.id, 'delete');
        end
    end

    %% Importer
    methods
        function import(this, ntype, varargin)
            %IMPORT  Load trained serialized models of different dnn-frameworks
            %
            %    net.import('Caffe', prototxt)
            %    net.import('Caffe', prototxt, caffeModel)
            %
            %    net.import('Tensorflow', model)
            %
            %    net.import('Torch', filename)
            %    net.import('Torch', filename, isBinary)
            %
            % ## Input
            % * __prototxt__ path to the .prototxt file with text description
            %       of the network architecture.
            % * __caffeModel__ (optional) path to the .caffemodel file with
            %       learned network. Empty by default.
            % * __filename__ path to the file, dumped from Torch by using
            %       `torch.save()` function.
            % * __isBinary__ specifies whether the network was serialized in
            %       ascii mode or binary. default true.
            % * __model__ path to the .pb file with binary protobuf
            %       description of the network architecture.
            %
            % Creates importer and adds loaded layers into the net and sets
            % connections between them.
            %
            % The first variant reads a network model stored in
            % [Caffe](http://caffe.berkeleyvision.org) model files.
            %
            % The second variant is an importer of
            % [TensorFlow](http://www.tensorflow.org) framework network.
            %
            % The third variant is an importer of [Torch7](http://torch.ch)
            % framework network.
            %
            % ## Notes for Torch
            %
            % Warning: Torch7 importer is experimental now, you need
            % explicitly set CMake flag to compile it.
            %
            % NOTE: ASCII mode of Torch serializer is more preferable, because
            % binary mode extensively use `long` type of C language, which has
            % various bit-length on different systems.
            %
            % The loading file must contain serialized
            % [`nn.Module`](https://github.com/torch/nn/blob/master/doc/module.md)
            % object with importing network. Try to eliminate a custom objects
            % from serialazing data to avoid importing errors.
            %
            % List of supported layers (i.e. object instances derived from
            % Torch `nn.Module` class):
            % - `nn.Sequential`
            % - `nn.Parallel`
            % - `nn.Concat`
            % - `nn.Linear`
            % - `nn.SpatialConvolution`
            % - `nn.SpatialMaxPooling`, `nn.SpatialAveragePooling`
            % - `nn.ReLU`, `nn.TanH`, `nn.Sigmoid`
            % - `nn.Reshape`
            %
            % Also some equivalents of these classes from cunn, cudnn, and
            % fbcunn may be successfully imported.
            %
            % See also: cv.Net
            %
            Net_(this.id, 'import', ntype, varargin{:});
        end
    end

    %% Net (set/get blobs and params, run)
    methods
        function setBlob(this, outputName, blob)
            %SETBLOB  Sets the new value for the layer output blob
            %
            %    net.setBlob(outputName, blob)
            %
            % ## Input
            % * __outputName__ descriptor of the updating layer output blob.
            %       See cv.Net.connect to know format of the descriptor.
            % * __blob__ new blob, constructed from an image or an array of
            %       images.
            %
            % NOTE: If updating blob is not empty then `blob` must have the
            % same shape, because network reshaping is not implemented yet.
            %
            % Blob is a class provides methods for continuous n-dimensional
            % CPU and GPU array processing. The class is realized as a wrapper
            % over `cv::Mat` and `cv::UMat`. It will support methods for
            % switching and logical synchronization between CPU and GPU.
            %
            % The blob (4-dimensional blob, so-called batch) is constructe
            % from image or array of images. Image is a 2-dimensional
            % multi-channel or 3-dimensional single-channel image (or array of
            % such images).
            %
            % See also: cv.Net.getBlob, cv.Net.connect
            %
            Net_(this.id, 'setBlob', outputName, blob);
        end

        function setBlobTorch(this, outputName, filename, varargin)
            %SETBLOBTORCH  Sets the new value for the layer output using a Torch7 serialized blob
            %
            %    net.setBlobTorch(outputName, filename)
            %    net.setBlobTorch(outputName, filename, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __outputName__ descriptor of the updating layer output blob.
            % * __filename__ path to the blob file which was serialized as
            %       `torch.Tensor` object of Torch7 framework.
            %
            % ## Options
            % * __IsBinary__ default true.
            %
            % This function has the same limitations as cv.Net.import.
            %
            % See also: cv.Net.setBlob, cv.Net.import
            %
            Net_(this.id, 'setBlobTorch', outputName, filename, varargin{:});
        end

        function blob = getBlob(this, outputName)
            %GETBLOB  Returns the layer output blob
            %
            %    blob = net.getBlob(outputName)
            %
            % ## Input
            % * __outputName__ the descriptor of the returning layer output
            %       blob.
            %
            % ## Output
            % * __blob__ returned blob.
            %
            % A blob is a 4-dimensional matrix (so-called batch) with the
            % following shape: `[num, cn, rows, cols]`.
            %
            % See also: cv.Net.setBlob, cv.Net.connect
            %
            blob = Net_(this.id, 'getBlob', outputName);
        end

        function setParam(this, layerId, numParam, blob)
            %SETPARAM  Sets the new value for the learned param of the layer
            %
            %    net.setParam(layerId)
            %
            % ## Input
            % * __layerId__ name or id of the layer.
            % * __numParam__ index of the layer parameter in the blobs array.
            % * __blob__ the new value.
            %
            % NOTE: If shape of the new blob differs from the previous shape,
            % then the following forward pass may fail.
            %
            % See also: cv.Net.getParam
            %
            Net_(this.id, 'setParam', layerId, numParam, blob);
        end

        function blob = getParam(this, layerId, varargin)
            %GETPARAM  Returns parameter blob of the layer
            %
            %    blob = net.getParam(layerId)
            %    blob = net.getParam(layerId, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __layerId__ name or id of the layer.
            %
            % ## Output
            % * __blob__ returned parameter blob.
            %
            % ## Options
            % * __NumParam__ index of the layer parameter in the blobs array.
            %       default 0.
            %
            % See also: cv.Net.setParam
            %
            blob = Net_(this.id, 'getParam', layerId, varargin{:});
        end

        function forward(this, varargin)
            %FORWARD  Runs forward pass
            %
            %    net.forward()
            %    net.forward(toLayerId)
            %    net.forward(startLayerId, toLayerId)
            %
            % ## Input
            % * __startLayerId__, __toLayerId__ layer name or layer id.
            %
            % The first form runs forward pass for the whole network.
            % The second form runs forward pass to compute output of layer
            % `toLayerId`.
            % The third form runs forward pass to compute output of layer
            % `toLayerId`, but computations start from `startLayerId`.
            %
            % Warning: Third form is not yet implemented yet.
            %
            % See also: cv.Net.Net, cv.Net.import
            %
            Net_(this.id, 'forward', varargin{:});
        end

        function forwardOpt(this, toLayerId)
            %FORWARDOPT  Optimized forward
            %
            %    net.forwardOpt(toLayerId)
            %
            % ## Input
            % * __toLayerId__ layer name or layer id (one or several).
            %
            % Makes forward only those layers which weren't changed after
            % previous cv.Net.forward.
            %
            % Warning: Not yet implemented.
            %
            % See also: cv.Net.forward
            %
            Net_(this.id, 'forwardOpt', toLayerId);
        end
    end

    %% Net (network architecture)
    methods (Hidden)
        function b = empty(this)
            %EMPTY  Returns true if there are no layers in the network.
            %
            %    b = net.empty()
            %
            % ## Output
            % * __b__ Boolean.
            %
            % See also: cv.Net.import
            %
            b = Net_(this.id, 'empty');
        end

        function id = addLayer(this, name, layerType, params)
            %ADDLAYER  Adds new layer to the net
            %
            %    id = net.addLayer(name, layerType, params)
            %
            % ## Input
            % * __name__ unique name of the adding layer.
            % * __layerType__ typename of the adding layer (type must be
            %       registered).
            % * __params__ parameters which will be used to initialize the
            %       creating layer. Scalar structure with the following fields:
            %       * __dict__ name-value dictionary as struct, values are
            %             scalar values (or arrays) of one of the following
            %             type: double, integer, or string.
            %       * __blobs__ List of learned parameters stored as blobs.
            %       * __name__ Name of the layer instance (optional, can be
            %             used internal purposes).
            %       * __type__ Type name which was used for creating layer by
            %             layer factory (optional).
            %
            % ## Output
            % * __id__ unique identifier of created layer, or -1 if a failure
            %       will happen.
            %
            % A LayerParams provides all data needed to initialize layer. It
            % includes dictionary with scalar params (`params.dict` struct),
            % blob params `params.blobs` and optional meta information
            % `params.name` and `params.type` of layer instance.
            %
            % Built-in layers listed below partially reproduce functionality
            % of corresponding Caffe and Torch7 layers.
            % In partuclar, the following layers and Caffe importer were
            % tested to reproduce
            % [Caffe](http://caffe.berkeleyvision.org/tutorial/layers.html)
            % functionality:
            % - Convolution
            % - Deconvolution
            % - Pooling
            % - InnerProduct
            % - TanH, ReLU, Sigmoid, BNLL, Power, AbsVal
            % - Softmax
            % - Reshape, Flatten, Slice, Split
            % - LRN
            % - MVN
            % - Dropout (since it does nothing on forward pass)
            %
            % See also: cv.Net.addLayerToPrev
            %
            id = Net_(this.id, 'addLayer', name, layerType, params);
        end

        function id = addLayerToPrev(this, name, layerType, params)
            %ADDLAYERTOPREV  Adds new layer and connects its first input to the first output of previously added layer
            %
            %    id = net.addLayerToPrev(name, layerType, params)
            %
            % ## Input
            % * __name__ unique name of the adding layer.
            % * __layerType__ typename of the adding layer (type must be
            %       registered).
            % * __params__ parameters which will be used to initialize the
            %       creating layer.
            %
            % ## Output
            % * __id__ unique identifier of created layer, or -1 if a failure
            %       will happen.
            %
            % See also: cv.Net.addLayer
            %
            id = Net_(this.id, 'addLayerToPrev', name, layerType, params);
        end

        function id = getLayerId(this, name)
            %GETLAYERID  Converts string name of the layer to the integer identifier
            %
            %    id = net.getLayerId(name)
            %
            % ## Input
            % * __name__ string name of the layer.
            %
            % ## Output
            % * __id__ id of the layer, or -1 if the layer wasn't found.
            %
            % See also: cv.Net.deleteLayer
            %
            id = Net_(this.id, 'getLayerId', name);
        end

        function names = getLayerNames(this)
            %GETLAYERNAMES  Get layer names
            %
            %    names = net.getLayerNames()
            %
            % ## Output
            % * __names__ names of layers.
            %
            % See also: cv.Net.getLayerId
            %
            names = Net_(this.id, 'getLayerNames');
        end

        function layer = getLayer(this, layerId)
            %GETLAYER  Returns layer with specified name which the network use
            %
            %    layer = net.getLayer(layerId)
            %
            % ## Input
            % * __layerId__ layer name or layer id.
            %
            % ## Output
            % * __layer__ returned layer. Scalar structure with the following
            %       fields:
            %       * __blobs__ List of stored learned parameters as returned
            %             by cv.Net.getParam.
            %       * __name__ name of the layer instance, can be used for
            %             logging or other internal purposes.
            %       * __type__ Type name which was used for creating layer by
            %             layer factory.
            %
            % Layers are the building blocks of networks.
            %
            % See also: cv.Net.getLayerId
            %
            layer = Net_(this.id, 'getLayer', layerId);
        end

        function deleteLayer(this, layerId)
            %DELETELAYER  Delete layer for the network (not implemented yet)
            %
            %    net.deleteLayer(layerId)
            %
            % ## Input
            % * __layerId__ layer name or layer id.
            %
            % See also: cv.Net.getLayerId
            %
            Net_(this.id, 'deleteLayer', layerId);
        end

        function connect(this, varargin)
            %CONNECT  Connects output of the first layer to input of the second layer
            %
            %    net.connect(outPin, inpPin)
            %    net.connect(outLayerId, outNum, inpLayerId, inpNum)
            %
            % ## Input
            % * __outPin__ descriptor of the first layer output.
            % * __inpPin__ descriptor of the second layer input.
            %
            % ## Input
            % * __outLayerId__ identifier of the first layer.
            % * __outNum__ number of the first layer output.
            % * __inpLayerId__ identifier of the second layer.
            % * __inpNum__ number of the second layer input.
            %
            % Descriptors have the following template
            % `<layer_name>[.input_number]`:
            % - the first part of the template `layer_name` is sting name of
            %   the added layer. If this part is empty then the network input
            %   pseudo layer will be used;
            % - the second optional part of the template `input_number` is
            %   either number of the layer input, either label one. If this
            %   part is omitted then the first layer input will be used.
            %
            % See also: cv.Net.setNetInputs
            %
            Net_(this.id, 'connect', varargin{:});
        end

        function setNetInputs(this, inputBlobNames)
            %SETNETINPUTS  Sets outputs names of the network input pseudo layer
            %
            %    net.setNetInputs(inputBlobNames)
            %
            % ## Input
            % * __inputBlobNames__ blob names.
            %
            % Each net always has special own the network input pseudo layer
            % with `id=0`. This layer stores the user blobs only and don't
            % make any computations. In fact, this layer provides the only way
            % to pass user data into the network. As any other layer, this
            % layer can label its outputs and this function provides an easy
            % way to do this.
            %
            % See also: cv.Net.connect
            %
            Net_(this.id, 'setNetInputs', inputBlobNames);
        end

        function allocate(this)
            %ALLOCATE  Initializes and allocates all layers.
            %
            %    net.allocate()
            %
            % See also: cv.Net.forward
            %
            Net_(this.id, 'allocate');
        end
    end
end
