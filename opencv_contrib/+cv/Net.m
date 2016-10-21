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
    % See also: nnet.cnn.layer.Layer, SeriesNetwork
    %

    properties (SetAccess = private)
        id    % Object ID
    end

    %% Constructor/destructor
    methods
        function this = Net()
            %NET  Default constructor
            %
            %    net = cv.Net()
            %
            % See also: cv.Net.importCaffe, cv.Net.forward
            %
            this.id = Net_(0, 'new');
        end

        function delete(this)
            %DELETE  Destructor
            %
            % See also: cv.Net
            %
            if isempty(this.id), return; end
            Net_(this.id, 'delete');
        end
    end

    %% Importer (loading trained serialized models of different dnn-frameworks)
    methods
        function importCaffe(this, prototxt, varargin)
            %IMPORTCAFFE  Importer of Caffe framework network
            %
            %    net.importCaffe(prototxt)
            %    net.importCaffe(prototxt, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __prototxt__ path to the .prototxt file with text description
            %       of the network architecture.
            %
            % ## Options
            % * __CaffeModel__ path to the .caffemodel file with learned
            %       network. Empty by default.
            %
            % Method for loading trained serialized models of Caffe framework
            % [1]. It adds loaded layers into the net and sets connetions
            % between them.
            %
            % ## References
            % [1]: http://caffe.berkeleyvision.org
            %
            % See also: cv.importTorch
            %
            Net_(this.id, 'importCaffe', prototxt, varargin{:});
        end

        function importTorch(this, filename, varargin)
            %IMPORTTORCH  Importer of Torch7 framework network
            %
            %    net.importTorch(filename)
            %    net.importTorch(filename, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __filename__ path to the file, dumped from Torch by using
            %       `torch.save()` function.
            %
            % ## Options
            % * __IsBinary__ specifies whether the network was serialized in
            %       ascii mode or binary. default true.
            %
            % Method for loading trained serialized models of Torch7 framework
            % [1]. It adds loaded layers into the net and sets connetions
            % between them.
            %
            % Warning: Torch7 importer is experimental now, you need
            % explicitly set CMake flag to compile it.
            %
            % NOTE: ASCII mode of Torch serializer is more preferable, because
            % binary mode extensively use `long` type of C language, which has
            % different bit-length on different systems.
            %
            % The loading file must contain serialized `nn.Module` [2] object
            % with importing network. Try to eliminate a custom objects from
            % serialazing data to avoid importing errors.
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
            % ## References
            % [1]: http://torch.ch
            % [2]: https://github.com/torch/nn/blob/master/doc/module.md
            %
            % See also: cv.importCaffe
            %
            Net_(this.id, 'importTorch', filename, varargin{:});
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
            % * __blob__ new blob, constructed from an image or an array of
            %       images.
            %
            % NOTE: If updating blob is not empty then `blob` must have the
            % same shape, because network reshaping is not implemented yet.
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
            % This function has the same limitations as cv.Net.importTorch.
            %
            % Warning: disabled due to an OpenCV bug.
            %
            % See also: cv.Net.setBlob, cv.Net.importTorch
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
            % * __blob__
            %
            % A blob is a 4-dimensional matrix (so-called batch) with the
            % following shape: `[num, cn, rows, cols]`.
            %
            % See also: cv.Net.setBlob, cv.Net.connect
            %
            blob = Net_(this.id, 'getBlob', outputName);
        end

        function setParam(this, layer, numParam, blob)
            %SETPARAM  Sets the new value for the learned param of the layer
            %
            %    net.setParam(layer)
            %
            % ## Input
            % * __layer__ name or id of the layer.
            % * __numParam__ index of the layer parameter in the blobs array.
            % * __blob__ the new value.
            %
            % NOTE: If shape of the new blob differs from the previous shape,
            % then the following forward pass may fail.
            %
            % Warning: Not yet implemented.
            %
            % See also: cv.Net.getParam
            %
            Net_(this.id, 'setParam', layer, numParam, blob);
        end

        function blob = getParam(this, layer, varargin)
            %GETPARAM  Returns parameter blob of the layer
            %
            %    blob = net.getParam(layer)
            %    blob = net.getParam(layer, 'OptionName',optionValue, ...)
            %
            % ## Input
            % * __layer__ name or id of the layer.
            %
            % ## Output
            % * __blob__
            %
            % ## Options
            % * __NumParam__ index of the layer parameter in the blobs array.
            %       default 0.
            %
            % See also: cv.Net.setParam
            %
            blob = Net_(this.id, 'getParam', layer, varargin{:});
        end

        function forward(this, varargin)
            %FORWARD  Runs forward pass
            %
            %    net.forward()
            %    net.forward(toLayer)
            %    net.forward(startLayer, toLayer)
            %
            % ## Input
            % * __startLayer__, __toLayer__ layer name or layer id.
            %
            % The first form runs forward pass for the whole network.
            % The second form runs forward pass to compute output of layer
            % `toLayer`.
            % The third form runs forward pass to compute output of layer
            % `toLayer`, but computations start from `startLayer`.
            %
            % Warning: Third form is not yet implemented yet.
            %
            % See also: cv.Net.Net, cv.Net.importCaffe
            %
            Net_(this.id, 'forward', varargin{:});
        end

        function forwardOpt(this, toLayer)
            %FORWARDOPT  Optimized forward
            %
            %    net.forwardOpt(toLayer)
            %
            % ## Input
            % * __toLayer__ layer name or layer id.
            %
            % Makes forward only those layers which weren't changed after
            % previous cv.Net.forward().
            %
            % Warning: Not yet implemented.
            %
            % See also: cv.Net.forward
            %
            Net_(this.id, 'forwardOpt', toLayer);
        end
    end

    %% Net (network architecture)
    methods (Hidden)
        function id = addLayer(this, name, stype, params)
            %ADDLAYER  Adds new layer to the net
            %
            %    id = net.addLayer(name, stype, params)
            %
            % ## Input
            % * __name__ unique name of the adding layer.
            % * __stype__ typename of the adding layer (type must be
            %       registered).
            % * __params__ parameters which will be used to initialize the
            %       creating layer.
            %
            % ## Output
            % * __id__ unique identifier of created layer, or -1 if a failure
            %       will happen.
            %
            % See also: cv.Net.addLayerToPrev
            %
            id = Net_(this.id, 'addLayer', name, stype, params);
        end

        function id = addLayerToPrev(this, name, stype, params)
            %ADDLAYERTOPREV  Adds new layer and connects its first input to the first output of previously added layer
            %
            %    id = net.addLayerToPrev(name, stype, params)
            %
            % ## Input
            % * __name__ unique name of the adding layer.
            % * __stype__ typename of the adding layer (type must be
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
            id = Net_(this.id, 'addLayerToPrev', name, stype, params);
        end

        function id = getLayerId(this, layer)
            %GETLAYERID  Converts string name of the layer to the integer identifier
            %
            %    id = net.getLayerId(layer)
            %
            % ## Input
            % * __layer__ string name of the layer.
            %
            % ## Output
            % * __id__ id of the layer, or -1 if the layer wasn't found.
            %
            % See also: cv.Net.deleteLayer
            %
            id = Net_(this.id, 'getLayerId', layer);
        end

        function deleteLayer(this, layer)
            %GETLAYERID  Delete layer for the network (not implemented yet)
            %
            %    net.deleteLayer(layer)
            %
            % ## Input
            % * __layer__ layer name or layer id.
            %
            % See also: cv.Net.getLayerId
            %
            Net_(this.id, 'deleteLayer', layer);
        end

        function connect(this, varargin)
            %CONNECT  Connects output of the first layer to input of the second layer
            %
            %    net.connect(outPin, inpPin)
            %    net.connect(outLayerId, outNum, inpLayerId, inpNum)
            %
            % ## Input
            % * __outPin__ descriptor of the first layer output
            % * __inpPin__ descriptor of the second layer input
            %
            % ## Input
            % * __outLayerId__ identifier of the first layer
            % * __outNum__ number of the first layer output
            % * __inpLayerId__ identifier of the second layer
            % * __inpNum__ number of the second layer input
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
            %SETNETINPUTS  Sets ouputs names of the network input pseudo layer
            %
            %    net.setNetInputs(inputBlobNames)
            %
            % ## Input
            % * __inputBlobNames__
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
    end
end
