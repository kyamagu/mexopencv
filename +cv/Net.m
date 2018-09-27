classdef Net < handle
    %NET  Create and manipulate comprehensive artificial neural networks
    %
    % This module contains:
    %
    % - API for new layers creation, layers are building bricks of neural
    %   networks;
    % - set of built-in most-useful Layers;
    % - API to constuct and modify comprehensive neural networks from layers;
    % - functionality for loading serialized networks models from different
    %   frameworks.
    %
    % Functionality of this module is designed only for forward pass
    % computations (i. e. network testing). A network training is in principle
    % not supported.
    %
    % [Wiki](https://github.com/opencv/opencv/wiki/Deep-Learning-in-OpenCV)
    %
    % ## Net class
    % Neural network is presented as directed acyclic graph (DAG), where
    % vertices are Layer instances, and edges specify relationships between
    % layers inputs and outputs.
    %
    % Each network layer has unique integer id and unique string name inside
    % its network. LayerId can store either layer name or layer id.
    %
    % See also: cv.Net.Net, nnet.cnn.layer.Layer, trainNetwork,
    %  SeriesNetwork, importCaffeNetwork, importCaffeLayers, alexnet, vgg16,
    %  vgg19
    %

    properties (SetAccess = private)
        % Object ID
        id
    end

    %% Constructor/destructor
    methods
        function this = Net(varargin)
            %NET  Constructor and importer of trained serialized models from different dnn-frameworks
            %
            %     net = cv.Net()
            %
            %     net = cv.Net('Caffe', prototxt)
            %     net = cv.Net('Caffe', prototxt, caffeModel)
            %
            %     net = cv.Net('Tensorflow', modelmodel)
            %     net = cv.Net('Tensorflow', model, config)
            %
            %     net = cv.Net('Torch', filename)
            %     net = cv.Net('Torch', filename, isBinary)
            %
            %     net = cv.Net('Darknet', cfgFile)
            %     net = cv.Net('Darknet', cfgFile, darknetModel)
            %
            % ## Input
            % * __prototxt__ path to the `.prototxt` file with text
            %   description of the network architecture.
            % * __caffeModel__ (optional) path to the `.caffemodel` file with
            %   learned network. Empty by default.
            % * __model__ path to the `.pb` file with binary protobuf
            %   description of the network architecture. Binary serialized
            %   TensorFlow graph includes weights.
            % * __config__ Optional path to the `.pbtxt` file that contains
            %   text graph definition in protobuf format. Resulting net is
            %   built by text graph using weights from a binary one. This is
            %   more flexible than binary format and may be used to build the
            %   network using binary format only as a weights storage. This
            %   approach is similar to Caffe's `.prorotxt` and `.caffemodel`.
            % * __filename__ path to the file, dumped from Torch by using
            %   `torch.save()` function.
            % * __isBinary__ specifies whether the network was serialized in
            %   ascii mode or binary. default true.
            % * __cfgFile__ path to the `.cfg` file with text description of
            %   the network architecture.
            % * __darknetModel__ (optional) path to the `.weights` file with
            %   learned network.
            %
            % The first variant creates an empty network.
            %
            % The second variant reads a network model stored in
            % [Caffe](http://caffe.berkeleyvision.org) framework's format.
            %
            % The third variant reads a network model stored in
            % [TensorFlow](https://www.tensorflow.org/) framework's format.
            %
            % The fourth variant reads a network model stored in
            % [Torch7](http://torch.ch) framework's format.
            %
            % The fifth variant reads a network model stored in
            % [Darknet](https://pjreddie.com/darknet/) model files.
            %
            % The importers first create a net, add loaded layers into it, and
            % set connections between them.
            %
            % ### Notes for Torch
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
            % - `nn.SoftMax`, `nn.LogSoftMax`
            %
            % Also some equivalents of these classes from cunn, cudnn, and
            % fbcunn may be successfully imported.
            %
            % See also: cv.Net, cv.Net.forward
            %
            this.id = Net_(0, 'new', varargin{:});
        end

        function delete(this)
            %DELETE  Destructor
            %
            %     net.delete()
            %
            % See also: cv.Net
            %
            if isempty(this.id), return; end
            Net_(this.id, 'delete');
        end
    end

    %% Net (set/get blobs and params, forward pass)
    methods
        function setInput(this, blob, name)
            %SETINPUT  Sets the new value for the layer output blob
            %
            %     net.setInput(blob)
            %     net.setInput(blob, name)
            %
            % ## Input
            % * __blob__ new blob, constructed from an image or an array of
            %   images.
            % * __name__ descriptor of the updating layer output blob. See
            %   cv.Net.connect to know format of the descriptor.
            %
            % NOTE: If updating blob is not empty then `blob` must have the
            % same shape, because network reshaping is not implemented yet.
            %
            % The blob (4-dimensional blob, so-called batch) is constructed
            % from image or array of images. Image is a 2-dimensional
            % multi-channel or 3-dimensional single-channel image (or array of
            % such images).
            %
            % See also: cv.Net.forward, cv.Net.blobFromImages
            %
            if nargin > 2
                Net_(this.id, 'setInput', blob, name);
            else
                Net_(this.id, 'setInput', blob);
            end
        end

        function setParam(this, layerId, numParam, blob)
            %SETPARAM  Sets the new value for the learned param of the layer
            %
            %     net.setParam(layerId, numParam, blob)
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

        function blob = getParam(this, layerId, numParam)
            %GETPARAM  Returns parameter blob of the layer
            %
            %     blob = net.getParam(layerId)
            %     blob = net.getParam(layerId, numParam)
            %
            % ## Input
            % * __layerId__ name or id of the layer.
            % * __numParam__ index of the layer parameter in the blobs array.
            %   default 0.
            %
            % ## Output
            % * __blob__ returned parameter blob.
            %
            % Parameters are the weights and biases.
            %
            % See also: cv.Net.setParam
            %
            if nargin > 2
                blob = Net_(this.id, 'getParam', layerId, numParam);
            else
                blob = Net_(this.id, 'getParam', layerId);
            end
        end

        function blob = forward(this, varargin)
            %FORWARD  Runs forward pass
            %
            %     blob = net.forward()
            %     blob = net.forward(outputName)
            %
            %     blobs = net.forward(outBlobNames)
            %
            % ## Input
            % * __outputName__ name for layer which output is needed to get.
            % * __outBlobNames__ names for layers which outputs are needed to
            %   get.
            %
            % ## Output
            % * __blob__ blob for first output of specified layer.
            % * __blobs__ blobs for first outputs of specified layers
            %   (cell array).
            %
            % The first form runs forward pass to compute output of layer
            % with name `outputName`. By default (`outputName` not specified)
            % runs forward pass for the whole network.
            % (i.e `names = net.getLayerNames(); outputName = names(end);`).
            % It returns blob for first output of specified layer.
            %
            % The second form runs forward pass to compute outputs of layers
            % listed in `outBlobNames`. It returns blobs for first outputs of
            % specified layers.
            %
            % See also: cv.Net.forwardAndRetrieve, cv.Net.Net
            %
            blob = Net_(this.id, 'forward', varargin{:});
        end

        function blobs = forwardAndRetrieve(this, varargin)
            %FORWARDANDRETRIEVE  Runs forward pass
            %
            %     blobs = net.forwardAndRetrieve()
            %     blobs = net.forwardAndRetrieve(outputName)
            %
            %     blobsArr = net.forwardAndRetrieve(outBlobNames)
            %
            % ## Input
            % * __outputName__ name for layer which output is needed to get.
            % * __outBlobNames__ names for layers which outputs are needed to
            %   get.
            %
            % ## Output
            % * __blobs__ contains all output blobs for specified layer
            %   (cell array)
            % * __blobsArr__ contains all output blobs for each layer
            %   specified in `outBlobNames` (cell array of cell arrays).
            %
            % The first form runs forward pass to compute output of layer
            % with name `outputName`. By default (`outputName` not specified)
            % runs forward pass for the whole network
            % (i.e `names = net.getLayerNames(); outputName = names(end);`).
            % It returns all output blobs for specified layer.
            %
            % The second form runs forward pass to compute outputs of layers
            % listed in `outBlobNames`. It returns all output blobs for each
            % layer specified in `outBlobNames`.
            %
            % See also: cv.Net.forward, cv.Net.Net
            %
            blobs = Net_(this.id, 'forwardAndRetrieve', varargin{:});
        end

        function [timings, total] = getPerfProfile(this)
            %GETPERFPROFILE  Returns overall time for inference and timings (in ticks) for layers
            %
            %     [timings, total] = net.getPerfProfile()
            %
            % ## Output
            % * __timings__ vector for tick timings for all layers.
            % * __total__ overall ticks for model inference.
            %
            % Indexes in returned vector correspond to layers ids. Some layers
            % can be fused with others, in this case zero ticks count will be
            % return for that skipped layers.
            %
            % See also: cv.Net.forward, cv.TickMeter
            %
            [timings, total] = Net_(this.id, 'getPerfProfile');
        end
    end

    %% Net (network architecture)
    methods
        function b = empty(this)
            %EMPTY  Returns true if there are no layers in the network.
            %
            %     b = net.empty()
            %
            % ## Output
            % * __b__ Boolean.
            %
            % See also: cv.Net.Net
            %
            b = Net_(this.id, 'empty');
        end

        function id = addLayer(this, name, layerType, params)
            %ADDLAYER  Adds new layer to the net
            %
            %     id = net.addLayer(name, layerType, params)
            %
            % ## Input
            % * __name__ unique name of the adding layer.
            % * __layerType__ typename of the adding layer (type must be
            %   registered).
            % * __params__ parameters which will be used to initialize the
            %   creating layer. Scalar structure with the following fields:
            %   * __dict__ name-value dictionary as struct, values are scalar
            %     values (or arrays) of one of the following type: double,
            %     integer, or string.
            %   * __blobs__ List of learned parameters stored as blobs.
            %   * __name__ Name of the layer instance (optional, can be used
            %     internal purposes).
            %   * __type__ Type name which was used for creating layer by
            %     layer factory (optional).
            %
            % ## Output
            % * __id__ unique identifier of created layer, or -1 if a failure
            %   will happen.
            %
            % A LayerParams provides all data needed to initialize layer. It
            % includes dictionary with scalar params (`params.dict` struct),
            % blob params `params.blobs` and optional meta information
            % `params.name` and `params.type` of layer instance.
            %
            % Built-in layers listed below partially reproduce functionality
            % of corresponding Caffe and Torch7 layers. In partuclar, the
            % following layers and Caffe importer were tested to reproduce
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
            % See also: cv.Net.addLayerToPrev, cv.Net.deleteLayer, cv.Net.connect
            %
            id = Net_(this.id, 'addLayer', name, layerType, params);
            id = int32(id);
        end

        function id = addLayerToPrev(this, name, layerType, params)
            %ADDLAYERTOPREV  Adds new layer and connects its first input to the first output of previously added layer
            %
            %     id = net.addLayerToPrev(name, layerType, params)
            %
            % ## Input
            % * __name__ unique name of the adding layer.
            % * __layerType__ typename of the adding layer (type must be
            %   registered).
            % * __params__ parameters which will be used to initialize the
            %   creating layer.
            %
            % ## Output
            % * __id__ unique identifier of created layer, or -1 if a failure
            %   will happen.
            %
            % See also: cv.Net.addLayer, cv.Net.deleteLayer, cv.Net.connect
            %
            id = Net_(this.id, 'addLayerToPrev', name, layerType, params);
            id = int32(id);
        end

        function id = getLayerId(this, name)
            %GETLAYERID  Converts string name of the layer to the integer identifier
            %
            %     id = net.getLayerId(name)
            %
            % ## Input
            % * __name__ string name of the layer.
            %
            % ## Output
            % * __id__ id of the layer, or -1 if the layer wasn't found.
            %
            % See also: cv.Net.getLayer, cv.Net.getLayerNames
            %
            id = Net_(this.id, 'getLayerId', name);
            id = int32(id);
        end

        function names = getLayerNames(this)
            %GETLAYERNAMES  Get layer names
            %
            %     names = net.getLayerNames()
            %
            % ## Output
            % * __names__ names of layers.
            %
            % See also: cv.Net.getLayerId, cv.Net.getLayer
            %
            names = Net_(this.id, 'getLayerNames');
        end

        function layer = getLayer(this, layerId)
            %GETLAYER  Returns layer with specified id or name which the network use
            %
            %     layer = net.getLayer(layerId)
            %
            % ## Input
            % * __layerId__ layer name or layer id.
            %
            % ## Output
            % * __layer__ returned layer. Scalar structure with the following
            %   fields:
            %   * __blobs__ List of stored learned parameters as returned by
            %     cv.Net.getParam.
            %   * __name__ name of the layer instance, can be used for logging
            %     or other internal purposes.
            %   * __type__ Type name which was used for creating layer by
            %     layer factory.
            %   * __preferableTarget__ preferred target for layer forwarding
            %     (see cv.Net.setPreferableTarget).
            %
            % Layers are the building blocks of networks.
            %
            % See also: cv.Net.getLayerId
            %
            layer = Net_(this.id, 'getLayer', layerId);
        end

        function layers = getLayerInputs(this, layerId)
            %GETLAYERINPUTS  Returns input layers of specific layer
            %
            %     layers = net.getLayerInputs(layerId)
            %
            % ## Input
            % * __layerId__ layer name or layer id.
            %
            % ## Output
            % * __layers__ returned layers, struct array.
            %
            % See also: cv.Net.getLayerId, cv.Net.getLayer
            %
            layers = Net_(this.id, 'getLayerInputs', layerId);
        end

        function deleteLayer(this, layerId)
            %DELETELAYER  Delete layer for the network
            %
            %     net.deleteLayer(layerId)
            %
            % ## Input
            % * __layerId__ layer name or layer id.
            %
            % Warning: Not yet implemented.
            %
            % See also: cv.Net.addLayer
            %
            Net_(this.id, 'deleteLayer', layerId);
        end

        function connect(this, varargin)
            %CONNECT  Connects output of the first layer to input of the second layer
            %
            %     net.connect(outPin, inpPin)
            %     net.connect(outLayerId, outNum, inpLayerId, inpNum)
            %
            % ## Input
            % * __outPin__ descriptor of the first layer output. See below.
            % * __inpPin__ descriptor of the second layer input. See below.
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
            % See also: cv.Net.setInputsNames, cv.Net.addLayer
            %
            Net_(this.id, 'connect', varargin{:});
        end

        function setInputsNames(this, inputBlobNames)
            %SETINPUTSNAMES  Sets outputs names of the network input pseudo layer
            %
            %     net.setInputsNames(inputBlobNames)
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
            % See also: cv.Net.connect, cv.Net.setInput
            %
            Net_(this.id, 'setInputsNames', inputBlobNames);
        end

        function indices = getUnconnectedOutLayers(this)
            %GETUNCONNECTEDOUTLAYERS  Returns indexes of layers with unconnected outputs
            %
            %     indices = net.getUnconnectedOutLayers()
            %
            % ## Output
            % * __indices__ vector of indices.
            %
            % See also: cv.Net.getLayer
            %
            indices = Net_(this.id, 'getUnconnectedOutLayers');
        end

        function layersTypes = getLayerTypes(this)
            %GETLAYERTYPES  Returns list of types for layer used in model
            %
            %     layersTypes = net.getLayerTypes()
            %
            % ## Output
            % * __layersTypes__ layer types.
            %
            % See also: cv.Net.getLayersCount
            %
            layersTypes = Net_(this.id, 'getLayerTypes');
        end

        function count = getLayersCount(this, layerType)
            %GETLAYERSCOUNT  Returns count of layers of specified type
            %
            %     count = net.getLayersCount(layerType)
            %
            % ## Input
            % * __layerType__ type.
            %
            % ## Output
            % * __count__ count of layers.
            %
            % See also: cv.Net.getLayerTypes
            %
            count = Net_(this.id, 'getLayersCount', layerType);
        end

        function enableFusion(this, fusion)
            %ENABLEFUSION  Enables or disables layer fusion in the network
            %
            %     net.enableFusion(fusion)
            %
            % ## Input
            % * __fusion__ true to enable the fusion, false to disable. The
            %   fusion is enabled by default.
            %
            % See also: cv.Net.connect
            %
            Net_(this.id, 'enableFusion', fusion);
        end

        function setHalideScheduler(this, scheduler)
            %SETHALIDESCHEDULER  Compile Halide layers
            %
            %     net.setHalideScheduler(scheduler)
            %
            % ## Input
            % * __scheduler__ scheduler Path to YAML file with scheduling
            %   directives.
            %
            % Schedule layers that support Halide backend. Then compile them
            % for specific target. For layers that not represented in
            % scheduling file or if no manual scheduling used at all,
            % automatic scheduling will be applied.
            %
            % See also: cv.Net.setPreferableBackend
            %
            Net_(this.id, 'setHalideScheduler', scheduler);
        end

        function setPreferableBackend(this, backend)
            %SETPREFERABLEBACKEND  Ask network to use specific computation backend where it supported
            %
            %     net.setPreferableBackend(backend)
            %
            % ## Input
            % * __backend__ computation backend supported by layers, one of:
            %   * __Default__
            %   * __Halide__ Halide language backend.
            %   * __InferenceEngine__ Intel's Deep Learning Inference Engine.
            %
            % See also: cv.Net.setPreferableTarget, cv.Net.setHalideScheduler
            %
            Net_(this.id, 'setPreferableBackend', backend);
        end

        function setPreferableTarget(this, target)
            %SETPREFERABLETARGET  Ask network to make computations on specific target device
            %
            %     net.setPreferableTarget(target)
            %
            % ## Input
            % * __target__ target device for computations, one of:
            %   * __CPU__
            %   * __OpenCL__
            %
            % See also: cv.Net.setPreferableBackend
            %
            Net_(this.id, 'setPreferableTarget', target);
        end
    end

    %% Auxiliary functions
    methods (Static)
        function blob = readTorchBlob(filename, varargin)
            %READTORCHBLOB  Loads blob which was serialized as torch.Tensor object of Torch7 framework
            %
            %     blob = cv.Net.readTorchBlob(filename)
            %     blob = cv.Net.readTorchBlob(filename, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __filename__ path to the blob file.
            %
            % ## Output
            % * __blob__ output blob.
            %
            % ## Options
            % * __IsBinary__ specifies whether blob file was serialized in
            %   ascii mode or binary. default true.
            %
            % This function has the same limitations as cv.Net.Net with
            % regards to the Torch importer.
            %
            % See also: cv.Net.setInput, cv.Net.blobFromImages
            %
            blob = Net_(0, 'readTorchBlob', filename, varargin{:});
        end

        function blob = blobFromImages(img, varargin)
            %BLOBFROMIMAGES  Creates 4-dimensional blob from image or series of images
            %
            %     blob = cv.Net.blobFromImages(img)
            %     blob = cv.Net.blobFromImages(imgs)
            %     blob = cv.Net.blobFromImages(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __img__ input image (with 1-, 3- or 4-channels).
            % * __imgs__ input images (all with 1-, 3- or 4-channels).
            %
            % ## Output
            % * __blob__ 4-dimansional array with NCHW dimensions order.
            %
            % ## Options
            % * __Size__ spatial size for output image `[w,h]`. default [0,0]
            %   (in which case input image size is used)
            % * __Mean__ scalar with mean values which are subtracted from
            %   channels. Values are intended to be in
            %   (mean-R, mean-G, mean-B) order if image has BGR ordering and
            %   `SwapRB` is true. default [0,0,0]
            % * __ScaleFactor__ multiplier for images values. default 1.0
            % * __SwapRB__ flag which indicates that swap first and last
            %   channels in 3-channel image is necessary. For instance, Caffe
            %   models are usually trained on BGR images, while TensorFlow
            %   models expect RGB images as input. default true
            % * __Crop__ flag which indicates whether image will be cropped
            %   after resize or not. default true
            %
            % Creates blob and optionally resizes and crops the images from
            % center, subtracts mean values, scales values, and swaps blue and
            % red channels.
            %
            % If `Crop` is true, input image is resized so one side after
            % resize is equal to corresponding dimension in `Size` and another
            % one is equal or larger. Then, crop from the center is performed.
            % If `Crop` is false, direct resize without cropping and
            % preserving aspect ratio is performed.
            %
            % A blob is a 4-dimensional matrix (so-called batch) with the
            % following shape: `[num, cn, rows, cols]`.
            %
            % See also: cv.Net.setInput
            %
            blob = Net_(0, 'blobFromImages', img, varargin{:});
        end

        function imgs = imagesFromBlob(blob)
            %IMAGESFROMBLOB  Parse a 4D blob and output the images it contains
            %
            %     imgs = cv.Net.imagesFromBlob(blob)
            %
            % ## Input
            % * __blob__ 4-dimensional array `(images, channels, height, width)`
            %   in floating-point precision (`single`) from which you would
            %   like to extract the images.
            %
            % ## Output
            % * __imgs__ cell-array of matrices containing the images
            %   extracted from the blob in floating-point precision (`single`).
            %   They are non-normalized neither mean-added. The number of
            %   returned images equals the first dimension of the blob
            %   (batch size). Every image has a number of channels equals to
            %   the second dimension of the blob (depth).
            %
            % See also: cv.Net.blobFromImages
            %
            imgs = Net_(0, 'imagesFromBlob', blob);
        end

        function shrinkCaffeModel(src, dst, varargin)
            %SHRINKCAFFEMODEL  Convert all weights of Caffe network to half precision floating point
            %
            %     cv.Net.shrinkCaffeModel(src, dst)
            %     cv.Net.shrinkCaffeModel(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __src__ Path to origin model from Caffe framework contains
            %   single precision floating point weights (usually has
            %   `.caffemodel` extension).
            % * __dst__ Path to destination model with updated weights.
            %
            % ## Options
            % * __LayersTypes__ Set of layers types which parameters will be
            %   converted. By default (not set), converts only Convolutional
            %   and Fully-Connected layers' weights,
            %   i.e `{'Convolution', 'InnerProduct'}`.
            %
            % Note: Shrinked model has no origin `float32` weights so it can't
            % be used in origin Caffe framework anymore. However the structure
            % of data is taken from NVidia's
            % <https://github.com/NVIDIA/caffe Caffe fork>. So the resulting
            % model may be used there.
            %
            Net_(0, 'shrinkCaffeModel', src, dst, varargin{:});
        end

        function indices = NMSBoxes(bboxes, scores, score_threshold, nms_threshold, varargin)
            %NMSBOXES  Performs non-maximum suppression given boxes and corresponding scores
            %
            %     indices = cv.Net.NMSBoxes(bboxes, scores, score_threshold, nms_threshold)
            %     indices = cv.Net.NMSBoxes(..., 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __bboxes__ a set of bounding boxes to apply NMS.
            % * __scores__ a set of corresponding confidences.
            % * **score_threshold** a threshold used to filter boxes by score.
            % * **nms_threshold** a threshold used in non maximum suppression.
            %
            % ## Output
            % * __indices__ the kept indices of bboxes after NMS.
            %
            % ## Options
            % * __Eta__ a coefficient in adaptive threshold formula:
            %   `nms_threshold_{i+1} = eta * nms_threshold_{i}`. default 1.0
            % * __TopK__ if `> 0`, keep at most `TopK` picked indices.
            %   default 0
            %
            % See also: cv.groupRectangles
            %
            indices = Net_(0, 'NMSBoxes', bboxes, scores, score_threshold, nms_threshold, varargin{:});
        end
    end
end
