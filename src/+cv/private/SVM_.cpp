/**
 * @file SVM_.cpp
 * @brief mex interface for SVM
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
map<int,Ptr<SVM> > obj_;

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

/// Option values for SVM types
const ConstMap<std::string,int> SVMType = ConstMap<std::string,int>
    ("C_SVC",     SVM::C_SVC)
    ("NU_SVC",    SVM::NU_SVC)
    ("ONE_CLASS", SVM::ONE_CLASS)
    ("EPS_SVR",   SVM::EPS_SVR)
    ("NU_SVR",    SVM::NU_SVR);

/// Option values for inverse SVM types
const ConstMap<int,std::string> InvSVMType = ConstMap<int,std::string>
    (SVM::C_SVC,     "C_SVC")
    (SVM::NU_SVC,    "NU_SVC")
    (SVM::ONE_CLASS, "ONE_CLASS")
    (SVM::EPS_SVR,   "EPS_SVR")
    (SVM::NU_SVR,    "NU_SVR");

/// Option values for SVM Kernel types
const ConstMap<std::string,int> SVMKernelType = ConstMap<std::string,int>
    ("Custom",       SVM::CUSTOM)
    ("Linear",       SVM::LINEAR)
    ("Poly",         SVM::POLY)
    ("RBF",          SVM::RBF)
    ("Sigmoid",      SVM::SIGMOID)
    ("Chi2",         SVM::CHI2)
    ("Intersection", SVM::INTER);

/// Option values for inverse SVM Kernel types
const ConstMap<int,std::string> InvSVMKernelType = ConstMap<int,std::string>
    (SVM::CUSTOM,  "Custom")
    (SVM::LINEAR,  "Linear")
    (SVM::POLY,    "Poly")
    (SVM::RBF,     "RBF")
    (SVM::SIGMOID, "Sigmoid")
    (SVM::CHI2,    "Chi2")
    (SVM::INTER,   "Intersection");

/** Obtain ParamGrid object from MxArray
 * @param m MxArray object
 * @return ParamGrid objects
 */
ParamGrid toParamGrid(const MxArray& m)
{
    ParamGrid g;
    if (m.isNumeric() && m.numel()==3) {
        g.minVal = m.at<double>(0);
        g.maxVal = m.at<double>(1);
        g.logStep = m.at<double>(2);
    }
    else if (m.isStruct() && m.numel()==1) {
        if (m.isField("minVal"))
            g.minVal = m.at("minVal").toDouble();
        if (m.isField("maxVal"))
            g.maxVal = m.at("maxVal").toDouble();
        if (m.isField("logStep"))
            g.logStep = m.at("logStep").toDouble();
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Invalid argument to grid parameter");
    // SVM::trainAuto permits setting step<=1 if we want to disable optimizing
    // a certain paramter, in which case the value is taken from params.
    // Besides the check is done by the function itself, so its not needed here.
    //if (!g.check())
    //    mexErrMsgIdAndTxt("mexopencv:error","Invalid argument to grid parameter");
    return g;
}

/** Represents custom kernel implemented as a MATLAB function.
 */
class MatlabFunction : public cv::ml::SVM::Kernel
{
public:
    MatlabFunction(const string &func)
    : fun_name(func)
    {}

    /** Evaluates MATLAB kernel function
     * @param vcount number of samples
     * @param n length of each sample
     * @param vecs input array of length \c n*vcount
     * @param another input array of length \p n
     * @param results output array of length \p vcount
     *
     * Calculates <tt>results(i) = K(another, vecs(:,i))</tt>,
     * for <tt>i=1:vcount</tt>
     * (where each sample is of size \p n).
     *
     * Example:
     * @code
     * % the following MATLAB function implements a simple linear kernel
     * function results = my_kernel(vecs, another)
     *     [n,vcount] = size(vecs);
     *     results = zeros(1, vcount, 'single');
     *     for i=1:vcount
     *         results(i) = dot(another, vecs(:,i));
     *     end
     *
     *     % or computed in a vectorized manner as
     *     %results = sum(bsxfun(@times, another, vecs));
     *
     *     % or simply written as
     *     %results = another.' * vecs;
     * end
     * @endcode
     */
    void calc(int vcount, int n, const float* vecs,
        const float* another, float* results)
    {
        // create input to evaluate kernel function
        mxArray *lhs, *rhs[3];
        rhs[0] = MxArray(fun_name);
        rhs[1] = MxArray(Mat(n, vcount, CV_32F, const_cast<float*>(vecs)));
        rhs[2] = MxArray(Mat(n, 1, CV_32F, const_cast<float*>(another)));

        // evaluate specified function in MATLAB as:
        // results = feval("fun_name", vecs, another)
        if (mexCallMATLAB(1, &lhs, 3, rhs, "feval") == 0) {
            MxArray res(lhs);
            CV_Assert(res.isSingle() && !res.isComplex() && res.ndims() == 2);
            vector<float> v(res.toVector<float>());
            CV_Assert(v.size() == vcount);
            std::copy(v.begin(), v.end(), results);
        }
        else {
            //TODO: error
            std::fill(results, results + vcount, 0);
        }

        // cleanup
        mxDestroyArray(lhs);
        mxDestroyArray(rhs[0]);
        mxDestroyArray(rhs[1]);
        mxDestroyArray(rhs[2]);
    }

    int getType() const
    {
        return SVM::CUSTOM;
    }

    static Ptr<MatlabFunction> create(const string &func)
    {
        return makePtr<MatlabFunction>(func);
    }

private:
    string fun_name;
};
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
    if (nrhs<2 || nlhs>3)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    vector<MxArray> rhs(prhs,prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        obj_[++last_id] = SVM::create();
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<SVM> obj = obj_[id];
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
            Algorithm::loadFromString<SVM>(rhs[2].toString(), objname) :
            Algorithm::load<SVM>(rhs[2].toString(), objname));
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
    else if (method == "trainAuto") {
        if (nrhs<4 || (nrhs%2)==1 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        int layout = cv::ml::ROW_SAMPLE;
        Mat varIdx, sampleIdx, sampleWeights, varType;
        int kFold = 10;
        bool balanced = false;
        ParamGrid CGrid      = SVM::getDefaultGrid(SVM::C),
                  gammaGrid  = SVM::getDefaultGrid(SVM::GAMMA),
                  pGrid      = SVM::getDefaultGrid(SVM::P),
                  nuGrid     = SVM::getDefaultGrid(SVM::NU),
                  coeffGrid  = SVM::getDefaultGrid(SVM::COEF),
                  degreeGrid = SVM::getDefaultGrid(SVM::DEGREE);
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="Layout")
                layout = SampleTypesMap[rhs[i+1].toString()];
            else if (key=="VarIdx")
                varIdx = rhs[i+1].toMat(
                    (rhs[i+1].isUint8() || rhs[i+1].isLogical()) ? CV_8U : CV_32S);
            else if (key=="SampleIdx")
                sampleIdx = rhs[i+1].toMat(
                    (rhs[i+1].isUint8() || rhs[i+1].isLogical()) ? CV_8U : CV_32S);
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
            else if (key=="KFold")
                kFold = rhs[i+1].toInt();
            else if (key=="Balanced")
                balanced = rhs[i+1].toBool();
            else if (key=="CGrid")
                CGrid = toParamGrid(rhs[i+1]);
            else if (key=="GammaGrid")
                gammaGrid = toParamGrid(rhs[i+1]);
            else if (key=="PGrid")
                pGrid = toParamGrid(rhs[i+1]);
            else if (key=="NuGrid")
                nuGrid = toParamGrid(rhs[i+1]);
            else if (key=="CoeffGrid")
                coeffGrid = toParamGrid(rhs[i+1]);
            else if (key=="DegreeGrid")
                degreeGrid = toParamGrid(rhs[i+1]);
            else
                mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized option %s", key.c_str());
        }
        Mat samples(rhs[2].toMat(CV_32F));
        Mat responses(rhs[3].toMat(rhs[3].isInt32() ? CV_32S : CV_32F));
        Ptr<TrainData> data = TrainData::create(samples, layout, responses,
            varIdx, sampleIdx, sampleWeights, varType);
        bool b = obj->trainAuto(data, kFold,
            CGrid, gammaGrid, pGrid, nuGrid, coeffGrid, degreeGrid, balanced);
        plhs[0] = MxArray(b);
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
            else
                mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized option %s", key.c_str());
        }
        Mat samples(rhs[2].toMat(CV_32F)), results;
        float f = obj->predict(samples, results, flags);
        plhs[0] = MxArray(results);
        if (nlhs>1)
            plhs[1] = MxArray(f);
    }
    else if (method == "getDecisionFunction") {
        if (nrhs!=3 || nlhs>3)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        int index = rhs[2].toInt();  //TODO check against number of classes?
        Mat alpha, svidx;
        double rho = obj->getDecisionFunction(index, alpha, svidx);
        plhs[0] = MxArray(alpha);
        if (nlhs > 1)
            plhs[1] = MxArray(svidx);
        if (nlhs > 2)
            plhs[2] = MxArray(rho);
    }
    else if (method == "getSupportVectors") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        plhs[0] = MxArray(obj->getSupportVectors());
    }
    else if (method == "setCustomKernel") {
        if (nrhs!=3 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        obj->setCustomKernel(MatlabFunction::create(rhs[2].toString()));
    }
    else if (method == "get") {
        if (nrhs!=3 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        string prop(rhs[2].toString());
        if (prop=="Type")
            plhs[0] = MxArray(InvSVMType[obj->getType()]);
        else if (prop=="KernelType")
            plhs[0] = MxArray(InvSVMKernelType[obj->getKernelType()]);
        else if (prop=="Degree")
            plhs[0] = MxArray(obj->getDegree());
        else if (prop=="Gamma")
            plhs[0] = MxArray(obj->getGamma());
        else if (prop=="Coef0")
            plhs[0] = MxArray(obj->getCoef0());
        else if (prop=="C")
            plhs[0] = MxArray(obj->getC());
        else if (prop=="Nu")
            plhs[0] = MxArray(obj->getNu());
        else if (prop=="P")
            plhs[0] = MxArray(obj->getP());
        else if (prop=="ClassWeights")
            plhs[0] = MxArray(obj->getClassWeights());
        else if (prop=="TermCriteria")
            plhs[0] = MxArray(obj->getTermCriteria());
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        if (nrhs!=4 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        string prop(rhs[2].toString());
        if (prop=="Type")
            obj->setType(SVMType[rhs[3].toString()]);
        else if (prop=="KernelType")
            obj->setKernel(SVMKernelType[rhs[3].toString()]);
        else if (prop=="Degree")
            obj->setDegree(rhs[3].toDouble());
        else if (prop=="Gamma")
            obj->setGamma(rhs[3].toDouble());
        else if (prop=="Coef0")
            obj->setCoef0(rhs[3].toDouble());
        else if (prop=="C")
            obj->setC(rhs[3].toDouble());
        else if (prop=="Nu")
            obj->setNu(rhs[3].toDouble());
        else if (prop=="P")
            obj->setP(rhs[3].toDouble());
        else if (prop=="ClassWeights")
            obj->setClassWeights(rhs[3].toMat());
        else if (prop=="TermCriteria")
            obj->setTermCriteria(rhs[3].toTermCriteria());
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
