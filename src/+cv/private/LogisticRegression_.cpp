/**
 * @file LogisticRegression_.cpp
 * @brief mex interface for cv::ml::LogisticRegression
 * @ingroup ml
 * @author Amro
 * @date 2015
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
map<int,Ptr<LogisticRegression> > obj_;

/// Option values for Training methods
const ConstMap<string,int> TrainingMethodType = ConstMap<string,int>
    ("Batch",     cv::ml::LogisticRegression::BATCH)
    ("MiniBatch", cv::ml::LogisticRegression::MINI_BATCH);

/// Option values for Inverse Training methods
const ConstMap<int,string> InvTrainingMethodType = ConstMap<int,string>
    (cv::ml::LogisticRegression::BATCH,      "Batch")
    (cv::ml::LogisticRegression::MINI_BATCH, "MiniBatch");

/// Option values for Regularization kinds
const ConstMap<string,int> RegularizationType = ConstMap<string,int>
    ("Disable", cv::ml::LogisticRegression::REG_DISABLE) // Regularization disabled
    ("L1",      cv::ml::LogisticRegression::REG_L1)      // L1 norm
    ("L2",      cv::ml::LogisticRegression::REG_L2);     // L2 norm

/// Option values for Inverse Regularization kinds
const ConstMap<int,string> InvRegularizationType = ConstMap<int,string>
    (cv::ml::LogisticRegression::REG_DISABLE, "Disable")
    (cv::ml::LogisticRegression::REG_L1,      "L1")
    (cv::ml::LogisticRegression::REG_L2,      "L2");
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
        obj_[++last_id] = LogisticRegression::create();
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<LogisticRegression> obj = obj_[id];
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
            Algorithm::loadFromString<LogisticRegression>(rhs[2].toString(), objname) :
            Algorithm::load<LogisticRegression>(rhs[2].toString(), objname));
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
    else if (method == "get_learnt_thetas") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->get_learnt_thetas());
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "Iterations")
            plhs[0] = MxArray(obj->getIterations());
        else if (prop == "LearningRate")
            plhs[0] = MxArray(obj->getLearningRate());
        else if (prop == "MiniBatchSize")
            plhs[0] = MxArray(obj->getMiniBatchSize());
        else if (prop == "Regularization")
            plhs[0] = MxArray(InvRegularizationType[obj->getRegularization()]);
        else if (prop == "TermCriteria")
            plhs[0] = MxArray(obj->getTermCriteria());
        else if (prop == "TrainMethod")
            plhs[0] = MxArray(InvTrainingMethodType[obj->getTrainMethod()]);
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "Iterations")
            obj->setIterations(rhs[3].toInt());
        else if (prop == "LearningRate")
            obj->setLearningRate(rhs[3].toDouble());
        else if (prop == "MiniBatchSize")
            obj->setMiniBatchSize(rhs[3].toInt());
        else if (prop == "Regularization")
            obj->setRegularization(RegularizationType[rhs[3].toString()]);
        else if (prop == "TermCriteria")
            obj->setTermCriteria(rhs[3].toTermCriteria());
        else if (prop == "TrainMethod")
            obj->setTrainMethod(TrainingMethodType[rhs[3].toString()]);
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
