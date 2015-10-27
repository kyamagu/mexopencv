/**
 * @file ANN_MLP_.cpp
 * @brief mex interface for cv::ml::ANN_MLP
 * @ingroup ml
 * @author Kota Yamaguchi, Amro
 * @date 2012, 2015
 */
#include "mexopencv.hpp"
#include "mexopencv_ml.hpp"
using namespace std;
using namespace cv;
using namespace cv::ml;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<ANN_MLP> > obj_;

/// Option values for ANN_MLP train types
const ConstMap<string,int> ANN_MLPTrain = ConstMap<string,int>
    ("Backprop", cv::ml::ANN_MLP::BACKPROP)
    ("RProp",    cv::ml::ANN_MLP::RPROP);

/// Inverse option values for ANN_MLP train types
const ConstMap<int,string> InvANN_MLPTrain = ConstMap<int,string>
    (cv::ml::ANN_MLP::BACKPROP, "Backprop")
    (cv::ml::ANN_MLP::RPROP,    "RProp");

/// Option values for ANN_MLP activation function
const ConstMap<string,int> ActivateFunc = ConstMap<string,int>
    ("Identity", cv::ml::ANN_MLP::IDENTITY)
    ("Sigmoid",  cv::ml::ANN_MLP::SIGMOID_SYM)
    ("Gaussian", cv::ml::ANN_MLP::GAUSSIAN);

/// Inverse option values for ANN_MLP activation function
const ConstMap<int,string> InvActivateFunc = ConstMap<int,string>
    (cv::ml::ANN_MLP::IDENTITY,    "Identity")
    (cv::ml::ANN_MLP::SIGMOID_SYM, "Sigmoid")
    (cv::ml::ANN_MLP::GAUSSIAN,    "Gaussian");
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
        nargchk(nrhs==2 && nlhs<=1);
        obj_[++last_id] = ANN_MLP::create();
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<ANN_MLP> obj = obj_[id];
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
    }
    else if (method == "clear") {
        nargchk(nrhs==2 && nlhs==0);
        obj->clear();
    }
    else if (method == "load") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs==0);
        string objname;
        bool loadFromString = false;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "ObjName")
                objname = rhs[i+1].toString();
            else if (key == "FromString")
                loadFromString = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        obj_[id] = (loadFromString ?
            Algorithm::loadFromString<ANN_MLP>(rhs[2].toString(), objname) :
            Algorithm::load<ANN_MLP>(rhs[2].toString(), objname));
    }
    else if (method == "save") {
        nargchk(nrhs==3 && nlhs<=1);
        string fname(rhs[2].toString());
        if (nlhs > 0) {
            // write to memory, and return string
            FileStorage fs(fname, FileStorage::WRITE + FileStorage::MEMORY);
            fs << obj->getDefaultName() << "{";
            fs << "format" << 3;
            obj->write(fs);
            fs << "}";
            plhs[0] = MxArray(fs.releaseAndGetString());
        }
        else
            // write to disk
            obj->save(fname);
    }
    else if (method == "empty") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->empty());
    }
    else if (method == "getDefaultName") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getDefaultName());
    }
    else if (method == "getVarCount") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getVarCount());
    }
    else if (method == "isClassifier") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->isClassifier());
    }
    else if (method == "isTrained") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->isTrained());
    }
    else if (method == "train") {
        nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=1);
        vector<MxArray> dataOptions;
        int flags = 0;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Data")
                dataOptions = rhs[i+1].toVector<MxArray>();
            else if (key == "Flags")
                flags = rhs[i+1].toInt();
            else if (key=="UpdateWeights")
                UPDATE_FLAG(flags, rhs[i+1].toBool(), ANN_MLP::UPDATE_WEIGHTS);
            else if (key=="NoInputScale")
                UPDATE_FLAG(flags, rhs[i+1].toBool(), ANN_MLP::NO_INPUT_SCALE);
            else if (key=="NoOutputScale")
                UPDATE_FLAG(flags, rhs[i+1].toBool(), ANN_MLP::NO_OUTPUT_SCALE);
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Ptr<TrainData> data;
        if (rhs[2].isChar())
            data = loadTrainData(rhs[2].toString(),
                dataOptions.begin(), dataOptions.end());
        else
            data = createTrainData(
                rhs[2].toMat(CV_32F),
                rhs[3].toMat(CV_32F),
                dataOptions.begin(), dataOptions.end());
        bool b = obj->train(data, flags);
        plhs[0] = MxArray(b);
    }
    else if (method == "calcError") {
        nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=2);
        vector<MxArray> dataOptions;
        bool test = false;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Data")
                dataOptions = rhs[i+1].toVector<MxArray>();
            else if (key == "TestError")
                test = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Ptr<TrainData> data;
        if (rhs[2].isChar())
            data = loadTrainData(rhs[2].toString(),
                dataOptions.begin(), dataOptions.end());
        else
            data = createTrainData(
                rhs[2].toMat(CV_32F),
                rhs[3].toMat(CV_32F),
                dataOptions.begin(), dataOptions.end());
        Mat resp;
        float err = obj->calcError(data, test, (nlhs>1 ? resp : noArray()));
        plhs[0] = MxArray(err);
        if (nlhs>1)
            plhs[1] = MxArray(resp);
    }
    else if (method == "predict") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=2);
        int flags = 0;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Flags")
                flags = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat samples(rhs[2].toMat(CV_32F)),
            results;
        float f = obj->predict(samples, results, flags);
        plhs[0] = MxArray(results);
        if (nlhs>1)
            plhs[1] = MxArray(f);
    }
    else if (method == "getWeights") {
        nargchk(nrhs==3 && nlhs<=1);
        int layerIdx = rhs[2].toInt();
        plhs[0] = MxArray(obj->getWeights(layerIdx));
    }
    else if (method == "setActivationFunction" || method == "setTrainMethod") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs==0);
        double param1 = 0,
               param2 = 0;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="Param1")
                param1 = rhs[i+1].toDouble();
            else if (key=="Param2")
                param2 = rhs[i+1].toDouble();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        if (method == "setActivationFunction") {
            int type = ActivateFunc[rhs[2].toString()];
            obj->setActivationFunction(type, param1, param2);
        }
        else {
            int tmethod = ANN_MLPTrain[rhs[2].toString()];
            obj->setTrainMethod(tmethod, param1, param2);
        }
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "BackpropMomentumScale")
            plhs[0] = MxArray(obj->getBackpropMomentumScale());
        else if (prop == "BackpropWeightScale")
            plhs[0] = MxArray(obj->getBackpropWeightScale());
        else if (prop == "LayerSizes")
            plhs[0] = MxArray(obj->getLayerSizes());
        else if (prop == "RpropDW0")
            plhs[0] = MxArray(obj->getRpropDW0());
        else if (prop == "RpropDWMax")
            plhs[0] = MxArray(obj->getRpropDWMax());
        else if (prop == "RpropDWMin")
            plhs[0] = MxArray(obj->getRpropDWMin());
        else if (prop == "RpropDWMinus")
            plhs[0] = MxArray(obj->getRpropDWMinus());
        else if (prop == "RpropDWPlus")
            plhs[0] = MxArray(obj->getRpropDWPlus());
        else if (prop == "TermCriteria")
            plhs[0] = MxArray(obj->getTermCriteria());
        else if (prop == "TrainMethod")
            plhs[0] = MxArray(InvANN_MLPTrain[obj->getTrainMethod()]);
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "BackpropMomentumScale")
            obj->setBackpropMomentumScale(rhs[3].toDouble());
        else if (prop == "BackpropWeightScale")
            obj->setBackpropWeightScale(rhs[3].toDouble());
        else if (prop == "LayerSizes")
            obj->setLayerSizes(rhs[3].toMat());
        else if (prop == "RpropDW0")
            obj->setRpropDW0(rhs[3].toDouble());
        else if (prop == "RpropDWMax")
            obj->setRpropDWMax(rhs[3].toDouble());
        else if (prop == "RpropDWMin")
            obj->setRpropDWMin(rhs[3].toDouble());
        else if (prop == "RpropDWMinus")
            obj->setRpropDWMinus(rhs[3].toDouble());
        else if (prop == "RpropDWPlus")
            obj->setRpropDWPlus(rhs[3].toDouble());
        else if (prop == "TermCriteria")
            obj->setTermCriteria(rhs[3].toTermCriteria());
        else if (prop == "TrainMethod")
            obj->setTrainMethod(ANN_MLPTrain[rhs[3].toString()]);
        else if (prop == "ActivationFunction")
            obj->setActivationFunction(ActivateFunc[rhs[3].toString()]);
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
