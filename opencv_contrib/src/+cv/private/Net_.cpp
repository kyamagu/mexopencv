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
    else if (arr.isDouble())
        return Net::LayerId(arr.toDouble());
    else
        return Net::LayerId(arr.toInt());
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
            MxArray val(dict.at(key));
            if (val.isChar())
                params.set(key, val.toString());
            else if (val.isDouble())
                params.set(key, val.toDouble());
            else
                params.set(key, val.toInt());
        }
    }
    if (arr.isField("blobs")) {
        vector<MxArray> blobs(arr.at("blobs").toVector<MxArray>());
        params.blobs.reserve(blobs.size());
        for (vector<MxArray>::const_iterator it = blobs.begin(); it != blobs.end(); ++it)
            params.blobs.push_back(Blob(it->toMat(CV_32F)));
    }
    if (arr.isField("name")) params.name = arr.at("name").toString();
    if (arr.isField("type")) params.type = arr.at("type").toString();
    return params;
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
        return;
    }

    // Big operation switch
    Ptr<Net> obj = obj_[id];
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
    }
    else if (method == "importCaffe") {
        nargchk((nrhs==3 || nrhs==4) && nlhs==0);
        string prototxt(rhs[2].toString()),
               caffeModel;
        if (nrhs == 4)
            caffeModel = rhs[3].toString();
        Ptr<Importer> importer = createCaffeImporter(prototxt, caffeModel);
        if (importer.empty())
            mexErrMsgIdAndTxt("mexopencv:error", "Caffe Importer failed");
        importer->populateNet(*obj.get());
    }
    else if (method == "importTorch") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs==0);
        string filename(rhs[2].toString());
        bool isBinary = true;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "IsBinary")
                isBinary = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Ptr<Importer> importer = createTorchImporter(filename, isBinary);
        if (importer.empty())
            mexErrMsgIdAndTxt("mexopencv:error", "Torch Importer failed");
        importer->populateNet(*obj.get());
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
#if 0
    //TODO: linking error, "forward(startLayer,toLayer)" overload not implemented
    else if (method == "forward") {
        nargchk((nrhs==2 || nrhs==3 || nrhs==4) && nlhs==0);
        if (nrhs > 2) {
            Net::LayerId layer1(MxArrayToLayerId(rhs[2]));
            if (nrhs > 3) {
                Net::LayerId layer2(MxArrayToLayerId(rhs[3]));
                obj->forward(layer1, layer2);
            }
            else
                obj->forward(layer1);
        }
        else
            obj->forward();
    }
#else
    else if (method == "forward") {
        nargchk((nrhs==2 || nrhs==3) && nlhs==0);
        if (nrhs == 3)
            obj->forward(MxArrayToLayerId(rhs[2]));
        else
            obj->forward();
    }
#endif
#if 0
    //TODO: linking error, forwardOpt not implemented
    else if (method == "forwardOpt") {
        nargchk(nrhs==3 && nlhs==0);
        obj->forwardOpt(MxArrayToLayerId(rhs[2]));
    }
#endif
#if 0
    //TODO: linking error, readTorchBlob is incorrectly named readTorchMat.
    // This was fixed in PR#750 in opencv_contrib (post 3.1.0)
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
        Blob blob(readTorchBlob(filename, isBinary));
        obj->setBlob(outputName, blob);
    }
#endif
    else if (method == "setBlob") {
        nargchk(nrhs==4 && nlhs==0);
        string outputName(rhs[2].toString());
        if (rhs[3].isNumeric()) {
            Mat img(rhs[3].toMat(CV_32F));
            obj->setBlob(outputName, Blob(img));
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
            obj->setBlob(outputName, Blob(imgs));
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
#if 0
    //TODO: linking error, setParam not implemented
    else if (method == "setParam") {
        nargchk(nrhs==5 && nlhs==0);
        Net::LayerId layer(MxArrayToLayerId(rhs[2]));
        int numParam = rhs[3].toInt();
        if (rhs[4].isNumeric()) {
            Mat img(rhs[4].toMat(CV_32F));
            obj->setParam(layer, numParam, Blob(img));
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
            obj->setParam(layer, numParam, Blob(imgs));
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Invalid arguments");
    }
#endif
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
        Blob blob = obj->getParam(MxArrayToLayerId(rhs[2]), numParam);
        plhs[0] = MxArray(blob.matRefConst());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s",method.c_str());
}
