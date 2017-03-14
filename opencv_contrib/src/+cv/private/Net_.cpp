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
    else if (arr.isDouble() || arr.isSingle())
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
        if (arr.isDouble() || arr.isSingle()) {
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
            if (val.isChar())
                params.set(key, val.toString());
            else if (val.isDouble() || val.isSingle())
                params.set(key, val.toDouble());
            else
                params.set(key, val.toInt());
        }
    }
    if (arr.isField("blobs")) {
        vector<MxArray> blobs(arr.at("blobs").toVector<MxArray>());
        params.blobs.reserve(blobs.size());
        for (vector<MxArray>::const_iterator it = blobs.begin(); it != blobs.end(); ++it)
            params.blobs.push_back(Blob::fromImages(it->toMat(CV_32F)));
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
    vector<Mat> blobs;
    blobs.reserve((layer->blobs).size());
    for (vector<Blob>::const_iterator it = (layer->blobs).begin(); it != (layer->blobs).end(); ++it)
        blobs.push_back(it->matRefConst());
    s.set("blobs", blobs);
    s.set("name",  layer->name);
    s.set("type",  layer->type);
    return s;
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
    nargchk(nrhs>=2 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        nargchk(nrhs==2 && nlhs<=1);
        obj_[++last_id] = makePtr<Net>();
        plhs[0] = MxArray(last_id);
        mexLock();
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
    else if (method == "import") {
        nargchk(nrhs>=3 && nlhs==0);
        Ptr<Importer> importer;
        string type(rhs[2].toString());
        if (type == "Caffe") {
            nargchk(nrhs==4 || nrhs==5);
            string prototxt(rhs[3].toString()), caffeModel;
            if (nrhs == 5)
                caffeModel = rhs[4].toString();
            importer = createCaffeImporter(prototxt, caffeModel);
        }
        else if (type == "Tensorflow") {
            nargchk(nrhs==4);
            string model(rhs[3].toString());
            importer = createTensorflowImporter(model);
        }
        else if (type == "Torch") {
            nargchk(nrhs==4 || nrhs==5);
            string filename(rhs[3].toString());
            bool isBinary = true;
            if (nrhs == 5)
                isBinary = rhs[4].toBool();
            importer = createTorchImporter(filename, isBinary);
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized importer type %s", type.c_str());
        if (importer.empty())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to create Importer");
        importer->populateNet(*obj.get());
        importer.release();
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
        int id = obj->addLayer(name, type, params);
        plhs[0] = MxArray(id);
    }
    else if (method == "addLayerToPrev") {
        nargchk(nrhs==5 && nlhs<=1);
        string name(rhs[2].toString()),
            type(rhs[3].toString());
        LayerParams params(MxArrayToLayerParams(rhs[4]));
        int id = obj->addLayerToPrev(name, type, params);
        plhs[0] = MxArray(id);
    }
    else if (method == "getLayerId") {
        nargchk(nrhs==3 && nlhs<=1);
        string layer(rhs[2].toString());
        int id = obj->getLayerId(layer);
        plhs[0] = MxArray(id);
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
    else if (method == "setNetInputs") {
        nargchk(nrhs==3 && nlhs==0);
        vector<string> inputBlobNames(rhs[2].toVector<string>());
        obj->setNetInputs(
            vector<String>(inputBlobNames.begin(), inputBlobNames.end()));
    }
    else if (method == "allocate") {
        nargchk(nrhs==2 && nlhs==0);
        obj->allocate();
    }
    else if (method == "forward") {
        nargchk((nrhs==2 || nrhs==3/* || nrhs==4*/) && nlhs==0);
        if (nrhs > 2) {
            Net::LayerId layer1(MxArrayToLayerId(rhs[2]));
            /*
            //TODO: linking error; unresolved external symbol
            if (nrhs > 3) {
                Net::LayerId layer2(MxArrayToLayerId(rhs[3]));
                obj->forward(layer1, layer2);  // startLayer, toLayer
            }
            else
            */
                obj->forward(layer1);  // toLayer
        }
        else
            obj->forward();
    }
    /*
    //TODO: linking error; unresolved external symbol
    else if (method == "forwardOpt") {
        nargchk(nrhs==3 && nlhs==0);
        if (rhs[2].numel() == 1)
            obj->forwardOpt(MxArrayToLayerId(rhs[2]));
        else
            obj->forwardOpt(MxArrayToVectorLayerId(rhs[2]));
    }
    */
    else if (method == "setBlobTorch") {
        nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs==0);
        string outputName(rhs[2].toString()),
            filename(rhs[3].toString());
        bool isBinary = true;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "IsBinary")
                isBinary = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Blob blob = readTorchBlob(filename, isBinary);
        obj->setBlob(outputName, blob);
    }
    else if (method == "setBlob") {
        nargchk(nrhs==4 && nlhs==0);
        string outputName(rhs[2].toString());
        if (rhs[3].isNumeric()) {
            Mat img(rhs[3].toMat(CV_32F));
            obj->setBlob(outputName, Blob::fromImages(img));
        }
        else if (rhs[3].isCell()) {
            //vector<Mat> imgs(rhs[3].toVector<Mat>());
            vector<Mat> imgs;
            {
                vector<MxArray> arr(rhs[3].toVector<MxArray>());
                imgs.reserve(arr.size());
                for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
                    imgs.push_back(it->toMat(CV_32F));
            }
            obj->setBlob(outputName, Blob::fromImages(imgs));
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Invalid arguments");
    }
    else if (method == "getBlob") {
        nargchk(nrhs==3 && nlhs<=1);
        string outputName(rhs[2].toString());
        Blob blob = obj->getBlob(outputName);
        plhs[0] = MxArray(blob.matRefConst());
    }
    else if (method == "setParam") {
        nargchk(nrhs==5 && nlhs==0);
        Net::LayerId layer(MxArrayToLayerId(rhs[2]));
        int numParam = rhs[3].toInt();
        if (rhs[4].isNumeric()) {
            Mat img(rhs[4].toMat(CV_32F));
            obj->setParam(layer, numParam, Blob::fromImages(img));
        }
        else if (rhs[4].isCell()) {
            //vector<Mat> imgs(rhs[4].toVector<Mat>());
            vector<Mat> imgs;
            {
                vector<MxArray> arr(rhs[4].toVector<MxArray>());
                imgs.reserve(arr.size());
                for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
                    imgs.push_back(it->toMat(CV_32F));
            }
            obj->setParam(layer, numParam, Blob::fromImages(imgs));
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Invalid arguments");
    }
    else if (method == "getParam") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        int numParam = 0;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "NumParam") {
                numParam = rhs[i+1].toInt();
                CV_Assert(numParam >= 0);
            }
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Net::LayerId layer(MxArrayToLayerId(rhs[2]));
        Blob blob = obj->getParam(layer, numParam);
        plhs[0] = MxArray(blob.matRefConst());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s",method.c_str());
}
