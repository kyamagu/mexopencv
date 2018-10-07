/**
 * @file SVMSGD_.cpp
 * @brief mex interface for cv::ml::SVMSGD
 * @ingroup ml
 * @author Amro
 * @date 2017
 */
#include "mexopencv.hpp"
#include "mexopencv_ml.hpp"
#include "opencv2/ml.hpp"
using namespace std;
using namespace cv;
using namespace cv::ml;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<SVMSGD> > obj_;

/// Option values for margin types
const ConstMap<string,int> MarginTypeMap = ConstMap<string,int>
    ("SoftMargin", cv::ml::SVMSGD::SOFT_MARGIN)
    ("HardMargin", cv::ml::SVMSGD::HARD_MARGIN);

/// Option values for inverse margin types
const ConstMap<int,string> InvMarginTypeMap = ConstMap<int,string>
    (cv::ml::SVMSGD::SOFT_MARGIN, "SoftMargin")
    (cv::ml::SVMSGD::HARD_MARGIN, "HardMargin");

/// Option values for SVMSGD types
const ConstMap<string,int> SvmsgdTypeMap = ConstMap<string,int>
    ("SGD",  cv::ml::SVMSGD::SGD)
    ("ASGD", cv::ml::SVMSGD::ASGD);

/// Option values for inverse SVMSGD types
const ConstMap<int,string> InvSvmsgdTypeMap = ConstMap<int,string>
    (cv::ml::SVMSGD::SGD,  "SGD")
    (cv::ml::SVMSGD::ASGD, "ASGD");
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
        obj_[++last_id] = SVMSGD::create();
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<SVMSGD> obj = obj_[id];
    if (obj.empty())
        mexErrMsgIdAndTxt("mexopencv:error", "Object not found id=%d", id);
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
        mexUnlock();
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
        //obj_[id] = SVMSGD::load(rhs[2].toString());
        obj_[id] = (loadFromString ?
            Algorithm::loadFromString<SVMSGD>(rhs[2].toString(), objname) :
            Algorithm::load<SVMSGD>(rhs[2].toString(), objname));
    }
    else if (method == "save") {
        nargchk(nrhs==3 && nlhs<=1);
        string fname(rhs[2].toString());
        if (nlhs > 0) {
            // write to memory, and return string
            FileStorage fs(fname, FileStorage::WRITE + FileStorage::MEMORY);
            if (!fs.isOpened())
                mexErrMsgIdAndTxt("mexopencv:error", "Failed to open file");
            fs << obj->getDefaultName() << "{";
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
            else if (key == "RawOutput")
                UPDATE_FLAG(flags, rhs[i+1].toBool(), StatModel::RAW_OUTPUT);
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
    else if (method == "getShift") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getShift());
    }
    else if (method == "getWeights") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getWeights());
    }
    else if (method == "setOptimalParameters") {
        nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs==0);
        int svmsgdType = cv::ml::SVMSGD::ASGD;
        int marginType = cv::ml::SVMSGD::SOFT_MARGIN;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "SvmsgdType")
                svmsgdType = SvmsgdTypeMap[rhs[i+1].toString()];
            else if (key == "MarginType")
                marginType = MarginTypeMap[rhs[i+1].toString()];
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        obj->setOptimalParameters(svmsgdType, marginType);
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "InitialStepSize")
            plhs[0] = MxArray(obj->getInitialStepSize());
        else if (prop == "MarginRegularization")
            plhs[0] = MxArray(obj->getMarginRegularization());
        else if (prop == "MarginType")
            plhs[0] = MxArray(InvMarginTypeMap[obj->getMarginType()]);
        else if (prop == "StepDecreasingPower")
            plhs[0] = MxArray(obj->getStepDecreasingPower());
        else if (prop == "SvmsgdType")
            plhs[0] = MxArray(InvSvmsgdTypeMap[obj->getSvmsgdType()]);
        else if (prop == "TermCriteria")
            plhs[0] = MxArray(obj->getTermCriteria());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "InitialStepSize")
            obj->setInitialStepSize(rhs[3].toFloat());
        else if (prop == "MarginRegularization")
            obj->setMarginRegularization(rhs[3].toFloat());
        else if (prop == "MarginType")
            obj->setMarginType(MarginTypeMap[rhs[3].toString()]);
        else if (prop == "StepDecreasingPower")
            obj->setStepDecreasingPower(rhs[3].toFloat());
        else if (prop == "SvmsgdType")
            obj->setSvmsgdType(SvmsgdTypeMap[rhs[3].toString()]);
        else if (prop == "TermCriteria")
            obj->setTermCriteria(rhs[3].toTermCriteria());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
