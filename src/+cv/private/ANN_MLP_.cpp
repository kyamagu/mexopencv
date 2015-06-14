/**
 * @file ANN_MLP_.cpp
 * @brief mex interface for ANN_MLP
 * @author Kota Yamaguchi, Amro
 * @date 2012, 2015
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;
using namespace cv::ml;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<ANN_MLP> > obj_;

/// Option values for SampleTypes
const ConstMap<std::string, int> SampleTypesMap = ConstMap<std::string, int>
    ("Row", cv::ml::ROW_SAMPLE)   //!< each training sample is a row of samples
    ("Col", cv::ml::COL_SAMPLE);  //!< each training sample occupies a column of samples

/// Option values for TrainData VariableTypes
const ConstMap<std::string, int> VariableTypeMap = ConstMap<std::string, int>
    ("Numerical",   cv::ml::VAR_NUMERICAL)     //!< same as VAR_ORDERED
    ("Ordered",     cv::ml::VAR_ORDERED)       //!< ordered variables
    ("Categorical", cv::ml::VAR_CATEGORICAL)   //!< categorical variables
    ("N",           cv::ml::VAR_NUMERICAL)     //!< shorthand for (N)umerical
    ("O",           cv::ml::VAR_ORDERED)       //!< shorthand for (O)rdered
    ("C",           cv::ml::VAR_CATEGORICAL);  //!< shorthand for (C)ategorical

/// Option values for ANN_MLP train types
const ConstMap<std::string,int> ANN_MLPTrain = ConstMap<std::string,int>
    ("Backprop", ANN_MLP::BACKPROP)
    ("RProp",    ANN_MLP::RPROP);

/// Inverse option values for ANN_MLP train types
const ConstMap<int,std::string> InvANN_MLPTrain = ConstMap<int,std::string>
    (ANN_MLP::BACKPROP, "Backprop")
    (ANN_MLP::RPROP,    "RProp");

/// Option values for ANN_MLP activation function
const ConstMap<std::string,int> ActivateFunc = ConstMap<std::string,int>
    ("Identity", ANN_MLP::IDENTITY)
    ("Sigmoid",  ANN_MLP::SIGMOID_SYM)
    ("Gaussian", ANN_MLP::GAUSSIAN);

/// Inverse option values for ANN_MLP activation function
const ConstMap<int,std::string> InvActivateFunc = ConstMap<int,std::string>
    (ANN_MLP::IDENTITY,    "Identity")
    (ANN_MLP::SIGMOID_SYM, "Sigmoid")
    (ANN_MLP::GAUSSIAN,    "Gaussian");
}

/**
 * Main entry called from Matlab
 * @param nlhs number of left-hand-side arguments
 * @param plhs pointers to mxArrays in the left-hand-side
 * @param nrhs number of right-hand-side arguments
 * @param prhs pointers to mxArrays in the right-hand-side
 */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    if (nrhs<2 || nlhs>2)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    vector<MxArray> rhs(prhs,prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        obj_[++last_id] = ANN_MLP::create();
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<ANN_MLP> obj = obj_[id];
    if (method == "delete") {
        if (nrhs!=2 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Output not assigned");
        obj_.erase(id);
    }
    else if (method == "clear") {
        if (nrhs!=2 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        obj->clear();
    }
    else if (method == "load") {
        if (nrhs<3 || (nrhs%2)==0 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        string objname;
        bool loadFromString = false;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="ObjName")
                objname = rhs[i+1].toString();
            else if (key=="FromString")
                loadFromString = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized option %s", key.c_str());
        }
        obj_[id] = (loadFromString ?
            Algorithm::loadFromString<ANN_MLP>(rhs[2].toString(), objname) :
            Algorithm::load<ANN_MLP>(rhs[2].toString(), objname));
    }
    else if (method == "save") {
        if (nrhs!=3 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        obj->save(rhs[2].toString());
    }
    else if (method == "empty") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        plhs[0] = MxArray(obj->empty());
    }
    else if (method == "getDefaultName") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        plhs[0] = MxArray(obj->getDefaultName());
    }
    else if (method == "getVarCount") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        plhs[0] = MxArray(obj->getVarCount());
    }
    else if (method == "isClassifier") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        plhs[0] = MxArray(obj->isClassifier());
    }
    else if (method == "isTrained") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        plhs[0] = MxArray(obj->isTrained());
    }
    else if (method == "train") {
        if (nrhs<4 || (nrhs%2)==1 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        int layout = cv::ml::ROW_SAMPLE;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="Layout")
                layout = SampleTypesMap[rhs[i+1].toString()];
            else
                mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized option %s", key.c_str());
        }
        Mat samples(rhs[2].toMat(CV_32F));
        Mat responses(rhs[3].toMat(rhs[3].isInt32() ? CV_32S : CV_32F));
        bool b = obj->train(samples, layout, responses);
        plhs[0] = MxArray(b);
    }
    else if (method == "train_") {
        if (nrhs<4 || (nrhs%2)==1 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        int flags = 0;
        int layout = cv::ml::ROW_SAMPLE;
        Mat varIdx, sampleIdx, sampleWeights, varType;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="Flags")
                flags = rhs[i+1].toInt();
            else if (key=="UpdateModel")
                UPDATE_FLAG(flags, rhs[i+1].toBool(), StatModel::UPDATE_MODEL);
            else if (key=="RawOuput")
                UPDATE_FLAG(flags, rhs[i+1].toBool(), StatModel::RAW_OUTPUT);
            else if (key=="CompressedInput")
                UPDATE_FLAG(flags, rhs[i+1].toBool(), StatModel::COMPRESSED_INPUT);
            else if (key=="PreprocessedInput")
                UPDATE_FLAG(flags, rhs[i+1].toBool(), StatModel::PREPROCESSED_INPUT);
            else if (key=="UpdateWeights")
                UPDATE_FLAG(flags, rhs[i+1].toBool(), ANN_MLP::UPDATE_WEIGHTS);
            else if (key=="NoInputScale")
                UPDATE_FLAG(flags, rhs[i+1].toBool(), ANN_MLP::NO_INPUT_SCALE);
            else if (key=="NoOutputScale")
                UPDATE_FLAG(flags, rhs[i+1].toBool(), ANN_MLP::NO_OUTPUT_SCALE);
            else if (key=="Layout")
                layout = SampleTypesMap[rhs[i+1].toString()];
            else if (key=="VarIdx")
                varIdx = rhs[i+1].toMat((rhs[i+1].isUint8() || rhs[i+1].isLogical()) ? CV_8U : CV_32S);
            else if (key=="SampleIdx")
                sampleIdx = rhs[i+1].toMat((rhs[i+1].isUint8() || rhs[i+1].isLogical()) ? CV_8U : CV_32S);
            else if (key=="SampleWeights")
                sampleWeights = rhs[i+1].toMat(CV_32F);
            else if (key=="VarType") {
                if (rhs[i+1].isCell()) {
                    vector<string> vtypes(rhs[i+1].toVector<string>());
                    varType.create(1, vtypes.size(), CV_8U);
                    for (size_t idx = 0; idx < vtypes.size(); idx++)
                        varType.at<uchar>(idx) = VariableTypeMap[vtypes[idx]];
                }
                else if (rhs[i+1].isNumeric())
                    varType = rhs[i+1].toMat(CV_8U);
                else
                    mexErrMsgIdAndTxt("mexopencv:error", "Invalid VarType value");
            }
            else
                mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized option %s", key.c_str());
        }
        Mat samples(rhs[2].toMat(CV_32F));
        Mat responses(rhs[3].toMat(rhs[3].isInt32() ? CV_32S : CV_32F));
        Ptr<TrainData> trainData = TrainData::create(samples, layout, responses,
            varIdx, sampleIdx, sampleWeights, varType);
        bool b = obj->train(trainData, flags);
        plhs[0] = MxArray(b);
    }
    else if (method == "calcError") {
        if (nrhs<5 || (nrhs%2)==0 || nlhs>2)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        int layout = cv::ml::ROW_SAMPLE;
        Mat varIdx, sampleIdx, sampleWeights, varType;
        for (int i=5; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="Layout")
                layout = SampleTypesMap[rhs[i+1].toString()];
            else if (key=="VarIdx")
                varIdx = rhs[i+1].toMat((rhs[i+1].isUint8() || rhs[i+1].isLogical()) ? CV_8U : CV_32S);
            else if (key=="SampleIdx")
                sampleIdx = rhs[i+1].toMat((rhs[i+1].isUint8() || rhs[i+1].isLogical()) ? CV_8U : CV_32S);
            else if (key=="SampleWeights")
                sampleWeights = rhs[i+1].toMat(CV_32F);
            else if (key=="VarType") {
                if (rhs[i+1].isCell()) {
                    vector<string> vtypes(rhs[i+1].toVector<string>());
                    varType.create(1, vtypes.size(), CV_8U);
                    for (size_t idx = 0; idx < vtypes.size(); idx++)
                        varType.at<uchar>(idx) = VariableTypeMap[vtypes[idx]];
                }
                else if (rhs[i+1].isNumeric())
                    varType = rhs[i+1].toMat(CV_8U);
                else
                    mexErrMsgIdAndTxt("mexopencv:error", "Invalid VarType value");
            }
            else
                mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized option %s", key.c_str());
        }
        Mat samples(rhs[2].toMat(CV_32F));
        Mat responses(rhs[3].toMat(rhs[3].isInt32() ? CV_32S : CV_32F));
        bool test = rhs[4].toBool();
        Ptr<TrainData> data = TrainData::create(samples, layout, responses,
            varIdx, sampleIdx, sampleWeights, varType);
        Mat resp;
        float err = obj->calcError(data, test, resp);
        plhs[0] = MxArray(err);
        if (nlhs>1)
            plhs[1] = MxArray(resp);
    }
    else if (method == "predict") {
        if (nrhs<3 || (nrhs%2)==0 || nlhs>2)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        int flags = 0;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="Flags")
                flags = rhs[i+1].toInt();
            else if (key=="UpdateModel")
                UPDATE_FLAG(flags, rhs[i+1].toBool(), StatModel::UPDATE_MODEL);
            else if (key=="RawOuput")
                UPDATE_FLAG(flags, rhs[i+1].toBool(), StatModel::RAW_OUTPUT);
            else if (key=="CompressedInput")
                UPDATE_FLAG(flags, rhs[i+1].toBool(), StatModel::COMPRESSED_INPUT);
            else if (key=="PreprocessedInput")
                UPDATE_FLAG(flags, rhs[i+1].toBool(), StatModel::PREPROCESSED_INPUT);
            else if (key=="UpdateWeights")
                UPDATE_FLAG(flags, rhs[i+1].toBool(), ANN_MLP::UPDATE_WEIGHTS);
            else if (key=="NoInputScale")
                UPDATE_FLAG(flags, rhs[i+1].toBool(), ANN_MLP::NO_INPUT_SCALE);
            else if (key=="NoOutputScale")
                UPDATE_FLAG(flags, rhs[i+1].toBool(), ANN_MLP::NO_OUTPUT_SCALE);
            else
                mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized option %s", key.c_str());
        }
        Mat samples(rhs[2].toMat(CV_32F)), results;
        float f = obj->predict(samples, results, flags);
        plhs[0] = MxArray(results);
        if (nlhs>1)
            plhs[1] = MxArray(f);
    }
    else if (method == "getWeights") {
        if (nrhs!=3 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        int layerIdx = rhs[2].toInt();
        plhs[0] = MxArray(obj->getWeights(layerIdx));
    }
    else if (method == "setActivationFunction" || method == "setTrainMethod") {
        if (nrhs<3 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        double param1 = 0, param2 = 0;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="Param1")
                param1 = rhs[i+1].toDouble();
            else if (key=="Param2")
                param2 = rhs[i+1].toDouble();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
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
        if (nrhs!=3 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
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
        //else if (prop == "ActivationFunction")
        //    plhs[0] = MxArray(InvActivateFunc[obj->getActivationFunction()]);
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        if (nrhs!=4 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
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
            mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
