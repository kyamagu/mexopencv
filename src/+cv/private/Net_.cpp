/**
 * @file Net_.cpp
 * @brief mex interface for cv::dnn::Net
 * @ingroup dnn
 * @author Amro
 * @date 2016
 */
#include "mexopencv.hpp"
#include "opencv2/dnn.hpp"
using namespace std;
using namespace cv;
using namespace cv::dnn;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<Net> > obj_;

/// Computation backends for option processing
const ConstMap<string,int> BackendsMap = ConstMap<string,int>
    ("Default",         cv::dnn::DNN_BACKEND_DEFAULT)
    ("Halide",          cv::dnn::DNN_BACKEND_HALIDE)
    ("InferenceEngine", cv::dnn::DNN_BACKEND_INFERENCE_ENGINE);

/// Computation target devices for option processing
const ConstMap<string,int> TargetsMap = ConstMap<string,int>
    ("CPU",    cv::dnn::DNN_TARGET_CPU)
    ("OpenCL", cv::dnn::DNN_TARGET_OPENCL);

/// Computation target devices for option processing
const ConstMap<int,string> TargetsInvMap = ConstMap<int,string>
    (cv::dnn::DNN_TARGET_CPU,    "CPU")
    (cv::dnn::DNN_TARGET_OPENCL, "OpenCL");

/**
 * Create 4-dimensional blob from MATLAB array
 * @param arr input MxArray object (numeric array).
 * @return blob 4-dimensional cv::MatND.
 * @see MxArray::toMatND
 */
MatND MxArrayToBlob(const MxArray& arr)
{
    MatND blob(arr.toMatND(CV_32F));
    if (blob.dims < 4) {
        //HACK: add trailing singleton dimensions (up to 4D)
        // (needed because in MATLAB, size(zeros(2,10,1,1)) is [2 10],
        // but some dnn methods expect blobs to have ndims==4)
        int sz[4] = {1, 1, 1, 1};
        std::copy(blob.size.p, blob.size.p + blob.dims, sz);
        blob = blob.reshape(0, 4, sz);
    }
    return blob;
}

/** Convert MxArray to cv::dnn::Net::LayerId
 * @param arr MxArray object. In one of the following forms:
 * - a scalar integer.
 * - a scalar double.
 * - a string.
 * @return instance of LayerId struct (a typedef for cv::dnn::DictValue,
 *   which is a container for either a string, a double, or an integer.
 */
Net::LayerId MxArrayToLayerId(const MxArray& arr)
{
    if (arr.isChar())
        return Net::LayerId(arr.toString());
    else if (arr.isFloat())
        return Net::LayerId(arr.toDouble());
    else
        return Net::LayerId(arr.toInt());
}

/** Convert MxArray to std::vector<cv::dnn::Net::LayerId>
 * @param arr MxArray object. Ine one of the following forms:
 * - a cell array of scalars (integers of doubles)
 * - a cell array of strings
 * - a numeric array of integers or doubles
 * @return vector of LayerId
 */
vector<Net::LayerId> MxArrayToVectorLayerId(const MxArray &arr)
{
    const mwSize n = arr.numel();
    vector<Net::LayerId> v;
    v.reserve(n);
    if (arr.isNumeric()) {
        if (arr.isFloat()) {
            vector<double> nums(arr.toVector<double>());
            v.assign(nums.begin(), nums.end());
        }
        else {
            vector<int> nums(arr.toVector<int>());
            v.assign(nums.begin(), nums.end());
        }
    }
    else if (arr.isCell())
        for (mwIndex i = 0; i < n; ++i)
            v.push_back(MxArrayToLayerId(arr.at<MxArray>(i)));
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "MxArray unable to convert to vector<cv::dnn::Net::LayerId>");
    return v;
}

/** Convert MxArray to cv::dnn::LayerParams
 * @param arr MxArray object. A scalar struct with the following fields:
 * - dict: Scalar struct of key/value dictionary parameters.
 * - blobs: Cell array of learned parameters stored as blobs.
 * - name: Name of the layer instance (optional, used for internal purposes).
 * - type: Type name which was used for creating layer by factory (optional).
 * @return instance of created LayerParams struct.
 */
LayerParams MxArrayToLayerParams(const MxArray& arr)
{
    CV_Assert(arr.isStruct() && arr.numel()==1);
    LayerParams params;
    if (arr.isField("dict")) {
        MxArray dict(arr.at("dict"));
        CV_Assert(dict.isStruct() && dict.numel()==1);
        for (int i = 0; i < dict.nfields(); ++i) {
            string key(dict.fieldname(i));
            const MxArray val(dict.at(key));
            if (val.isChar()) {
                if (val.numel() == 1)
                    params.set(key, val.toString());
                else {
                    vector<string> v(val.toVector<string>());
                    params.set(key, DictValue::arrayString(v.begin(), v.size()));
                }
            }
            else if (val.isFloat()) {
                if (val.numel() == 1)
                    params.set(key, val.toDouble());
                else {
                    vector<double> v(val.toVector<double>());
                    params.set(key, DictValue::arrayReal(v.begin(), v.size()));
                }
            }
            else {
                if (val.numel() == 1)
                    params.set(key, val.toInt());
                else {
                    vector<int> v(val.toVector<int>());
                    params.set(key, DictValue::arrayInt(v.begin(), v.size()));
                }
            }
        }
    }
    if (arr.isField("blobs")) {
        vector<MxArray> blobs(arr.at("blobs").toVector<MxArray>());
        params.blobs.reserve(blobs.size());
        for (vector<MxArray>::const_iterator it = blobs.begin(); it != blobs.end(); ++it)
            params.blobs.push_back(MxArrayToBlob(*it));
    }
    if (arr.isField("name")) params.name = arr.at("name").toString();
    if (arr.isField("type")) params.type = arr.at("type").toString();
    return params;
}

/** Convert cv::Ptr<cv::dnn::Layer> to scalar struct
 * @param layer smart pointer to an instance of Layer
 * @return scalar struct MxArray object
 */
MxArray toStruct(const Ptr<Layer> &layer)
{
    const char *fields[] = {"blobs", "name", "type"};
    MxArray s = MxArray::Struct(fields, 3);
    s.set("blobs", layer->blobs);
    s.set("name",  layer->name);
    s.set("type",  layer->type);
    s.set("preferableTarget", TargetsInvMap[layer->preferableTarget]);
    return s;
}

/** Convert std::vector<cv::Ptr<cv::dnn::Layer>> to struct array
 * @param layers vector of smart pointers to layers
 * @return struct-array MxArray object
 */
MxArray toStruct(const vector<Ptr<Layer> > &layers)
{
    const char *fields[] = {"blobs", "name", "type"};
    MxArray s = MxArray::Struct(fields, 3, 1, layers.size());
    for (mwIndex i = 0; i < layers.size(); ++i) {
        s.set("blobs", layers[i]->blobs, i);
        s.set("name",  layers[i]->name,  i);
        s.set("type",  layers[i]->type,  i);
        s.set("preferableTarget", TargetsInvMap[layers[i]->preferableTarget], i);
    }
    return s;
}

/** MxArray constructor from 64-bit integer.
 * @param i int value.
 * @return MxArray object, a scalar int64 array.
 */
MxArray toMxArray(int64_t i)
{
    MxArray arr(mxCreateNumericMatrix(1, 1, mxINT64_CLASS, mxREAL));
    if (arr.isNull())
        mexErrMsgIdAndTxt("mexopencv:error", "Allocation error");
    arr.set(0, i);
    return arr;
}

/** Create an instance of Net using options in arguments
 * @param type type of network to import, one of:
 *    - "Caffe"
 *    - "Tensorflow"
 *    - "Torch"
 *    - "Darknet"
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created Net
 */
Ptr<Net> readNetFrom(const string &type,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    Net net;
    if (type == "Caffe") {
        nargchk(len==1 || len==2);
        string prototxt(first->toString()); ++first;
        string caffeModel(len==2 ? first->toString() : string());
        net = readNetFromCaffe(prototxt, caffeModel);
    }
    else if (type == "Tensorflow") {
        nargchk(len==1 || len==2);
        string model(first->toString()); ++first;
        string config(len==2 ? first->toString() : string());
        net = readNetFromTensorflow(model, config);
    }
    else if (type == "Torch") {
        nargchk(len==1 || len==2);
        string filename(first->toString()); ++first;
        bool isBinary = (len==2 ? first->toBool() : true);
        net = readNetFromTorch(filename, isBinary);
    }
    else if (type == "Darknet") {
        nargchk(len==1 || len==2);
        string cfgFile(first->toString()); ++first;
        string darknetModel(len==2 ? first->toString() : string());
        net = readNetFromDarknet(cfgFile, darknetModel);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized network type %s", type.c_str());
    return makePtr<Net>(net);
}
}

/**
 * Main entry called from Matlab
 * @param nlhs number of left-hand-side arguments
 * @param plhs pointers to mxArrays in the left-hand-side
 * @param nrhs number of right-hand-side arguments
 * @param prhs pointers to mxArrays in the right-hand-side
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // Check the number of arguments
    nargchk(nrhs>=2 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        nargchk(nrhs>=2 && nlhs<=1);
        obj_[++last_id] = (nrhs > 2) ?
            readNetFrom(rhs[2].toString(), rhs.begin() + 3, rhs.end()) :
            makePtr<Net>();
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }
    // static method calls
    else if (method == "readTorchBlob") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        bool isBinary = true;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "IsBinary")
                isBinary = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        string filename(rhs[2].toString());
        MatND blob = readTorchBlob(filename, isBinary);
        plhs[0] = MxArray(blob);
        return;
    }
    else if (method == "blobFromImages") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        double scalefactor = 1.0;
        Size size;
        Scalar mean;
        bool swapRB = true;
        bool crop = true;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "ScaleFactor")
                scalefactor = rhs[i+1].toDouble();
            else if (key == "Size")
                size = rhs[i+1].toSize();
            else if (key == "Mean")
                mean = rhs[i+1].toScalar();
            else if (key == "SwapRB")
                swapRB = rhs[i+1].toBool();
            else if (key == "Crop")
                crop = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        MatND blob;
        if (rhs[2].isCell()) {
            //vector<Mat> images(rhs[2].toVector<Mat>());
            vector<Mat> images;
            {
                vector<MxArray> arr(rhs[2].toVector<MxArray>());
                images.reserve(arr.size());
                for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
                    images.push_back(it->toMat(CV_32F));
            }
            blob = blobFromImages(images, scalefactor, size, mean, swapRB, crop);
        }
        else {
            Mat image(rhs[2].toMat(CV_32F));
            blob = blobFromImage(image, scalefactor, size, mean, swapRB, crop);
        }
        plhs[0] = MxArray(blob);
        return;
    }
    else if (method == "imagesFromBlob") {
        nargchk(nrhs==3 && nlhs<=1);
        MatND blob(MxArrayToBlob(rhs[2]));
        vector<Mat> images;
        imagesFromBlob(blob, images);
        plhs[0] = MxArray(images);
        return;
    }
    else if (method == "shrinkCaffeModel") {
        nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs==0);
        vector<string> layersTypes;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "LayersTypes")
                layersTypes = rhs[i+1].toVector<string>();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        string src(rhs[2].toString()),
            dst(rhs[3].toString());
        shrinkCaffeModel(src, dst,
            vector<String>(layersTypes.begin(), layersTypes.end()));
        return;
    }
    else if (method == "NMSBoxes") {
        nargchk(nrhs>=6 && (nrhs%2)==0 && nlhs<=1);
        float eta = 1.0f;
        int top_k = 0;
        for (int i=6; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Eta")
                eta = rhs[i+1].toFloat();
            else if (key == "TopK")
                top_k = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        vector<Rect> bboxes(rhs[2].toVector<Rect>());
        vector<float> scores(rhs[3].toVector<float>());
        float score_threshold = rhs[4].toFloat();
        float nms_threshold = rhs[5].toFloat();
        vector<int> indices;
        NMSBoxes(bboxes, scores, score_threshold, nms_threshold, indices,
            eta, top_k);
        plhs[0] = MxArray(indices);
        return;
    }

    // Big operation switch
    Ptr<Net> obj = obj_[id];
    if (obj.empty())
        mexErrMsgIdAndTxt("mexopencv:error", "Object not found id=%d", id);
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
        mexUnlock();
    }
    else if (method == "empty") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->empty());
    }
    else if (method == "addLayer") {
        nargchk(nrhs==5 && nlhs<=1);
        string name(rhs[2].toString()),
            type(rhs[3].toString());
        LayerParams params(MxArrayToLayerParams(rhs[4]));
        int lid = obj->addLayer(name, type, params);
        plhs[0] = MxArray(lid);
    }
    else if (method == "addLayerToPrev") {
        nargchk(nrhs==5 && nlhs<=1);
        string name(rhs[2].toString()),
            type(rhs[3].toString());
        LayerParams params(MxArrayToLayerParams(rhs[4]));
        int lid = obj->addLayerToPrev(name, type, params);
        plhs[0] = MxArray(lid);
    }
    else if (method == "getLayerId") {
        nargchk(nrhs==3 && nlhs<=1);
        string layer(rhs[2].toString());
        int lid = obj->getLayerId(layer);
        plhs[0] = MxArray(lid);
    }
    else if (method == "getLayerNames") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getLayerNames());
    }
    else if (method == "getLayer") {
        nargchk(nrhs==3 && nlhs<=1);
        Ptr<Layer> layer = obj->getLayer(MxArrayToLayerId(rhs[2]));
        plhs[0] = toStruct(layer);
    }
    else if (method == "getLayerInputs") {
        nargchk(nrhs==3 && nlhs<=1);
        vector<Ptr<Layer> > layers = obj->getLayerInputs(MxArrayToLayerId(rhs[2]));
        plhs[0] = toStruct(layers);
    }
    else if (method == "deleteLayer") {
        nargchk(nrhs==3 && nlhs==0);
        obj->deleteLayer(MxArrayToLayerId(rhs[2]));
    }
    else if (method == "connect") {
        nargchk((nrhs==4 || nrhs==6) && nlhs==0);
        if (nrhs == 4) {
            string outPin(rhs[2].toString()),
                inpPin(rhs[3].toString());
            obj->connect(outPin, inpPin);
        }
        else {
            int outLayerId(rhs[2].toInt()),
                outNum(rhs[3].toInt()),
                inpLayerId(rhs[4].toInt()),
                inpNum(rhs[5].toInt());
            obj->connect(outLayerId, outNum, inpLayerId, inpNum);
        }
    }
    else if (method == "setInputsNames") {
        nargchk(nrhs==3 && nlhs==0);
        vector<string> inputBlobNames(rhs[2].toVector<string>());
        obj->setInputsNames(
            vector<String>(inputBlobNames.begin(), inputBlobNames.end()));
    }
    else if (method == "forward") {
        nargchk((nrhs==2 || nrhs==3) && nlhs<=1);
        if (nrhs == 2 || rhs[2].isChar()) {
            string outputName;
            if (nrhs == 3)
                outputName = rhs[2].toString();
            MatND outputBlob = obj->forward(outputName);
            plhs[0] = MxArray(outputBlob);
        }
        else {
            vector<string> outBlobNames(rhs[2].toVector<string>());
            vector<MatND> outputBlobs;
            obj->forward(outputBlobs,
                vector<String>(outBlobNames.begin(), outBlobNames.end()));
            plhs[0] = MxArray(outputBlobs);
        }
    }
    else if (method == "forwardAndRetrieve") {
        nargchk((nrhs==2 || nrhs==3) && nlhs<=1);
        if (nrhs == 2 || rhs[2].isChar()) {
            string outputName;
            if (nrhs == 3)
                outputName = rhs[2].toString();
            vector<MatND> outputBlobs;
            obj->forward(outputBlobs, outputName);
            plhs[0] = MxArray(outputBlobs);
        }
        else {
            vector<string> outBlobNames(rhs[2].toVector<string>());
            vector<vector<MatND> > outputBlobs;
            obj->forward(outputBlobs,
                vector<String>(outBlobNames.begin(), outBlobNames.end()));
            plhs[0] = MxArray(outputBlobs);
        }
    }
    else if (method == "setHalideScheduler") {
        nargchk(nrhs==3 && nlhs==0);
        obj->setHalideScheduler(rhs[2].toString());
    }
    else if (method == "setPreferableBackend") {
        nargchk(nrhs==3 && nlhs==0);
        obj->setPreferableBackend(BackendsMap[rhs[2].toString()]);
    }
    else if (method == "setPreferableTarget") {
        nargchk(nrhs==3 && nlhs==0);
        obj->setPreferableTarget(TargetsMap[rhs[2].toString()]);
    }
    else if (method == "setInput") {
        nargchk((nrhs==3 || nrhs==4) && nlhs==0);
        MatND blob(MxArrayToBlob(rhs[2]));
        if (nrhs > 3)
            obj->setInput(blob, rhs[3].toString());
        else
            obj->setInput(blob);
    }
    else if (method == "setParam") {
        nargchk(nrhs==5 && nlhs==0);
        Net::LayerId layer(MxArrayToLayerId(rhs[2]));
        int numParam = rhs[3].toInt();
        MatND blob(MxArrayToBlob(rhs[4]));
        obj->setParam(layer, numParam, blob);
    }
    else if (method == "getParam") {
        nargchk((nrhs==3 || nrhs==4) && nlhs<=1);
        Net::LayerId layer(MxArrayToLayerId(rhs[2]));
        int numParam = (nrhs > 3) ? rhs[3].toInt() : 0;
        CV_Assert(numParam >= 0);
        MatND blob = obj->getParam(layer, numParam);
        plhs[0] = MxArray(blob);
    }
    else if (method == "getUnconnectedOutLayers") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getUnconnectedOutLayers());
    }
    else if (method == "getLayerTypes") {
        nargchk(nrhs==2 && nlhs<=1);
        vector<String> layersTypes;
        obj->getLayerTypes(layersTypes);
        plhs[0] = MxArray(layersTypes);
    }
    else if (method == "getLayersCount") {
        nargchk(nrhs==3 && nlhs<=1);
        string layerType(rhs[2].toString());
        int count = obj->getLayersCount(layerType);
        plhs[0] = MxArray(count);
    }
    else if (method == "enableFusion") {
        nargchk(nrhs==3 && nlhs==0);
        obj->enableFusion(rhs[2].toBool());
    }
    else if (method == "getPerfProfile") {
        nargchk(nrhs==2 && nlhs<=2);
        vector<double> timings;
        int64 total = obj->getPerfProfile(timings);
        plhs[0] = MxArray(timings);
        if (nlhs > 1)
            plhs[1] = toMxArray(total);
    }
    //TODO:
    //else if (method == "getLayerShapes") {}
    //else if (method == "getLayersShapes") {}
    //else if (method == "getFLOPS") {}
    //else if (method == "getMemoryConsumption") {}
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s",method.c_str());
}
