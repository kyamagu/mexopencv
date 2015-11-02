/**
 * @file SVM_.cpp
 * @brief mex interface for cv::ml::SVM
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
map<int,Ptr<SVM> > obj_;

/// Option values for SVM types
const ConstMap<string,int> SVMType = ConstMap<string,int>
    ("C_SVC",     cv::ml::SVM::C_SVC)
    ("NU_SVC",    cv::ml::SVM::NU_SVC)
    ("ONE_CLASS", cv::ml::SVM::ONE_CLASS)
    ("EPS_SVR",   cv::ml::SVM::EPS_SVR)
    ("NU_SVR",    cv::ml::SVM::NU_SVR);

/// Option values for inverse SVM types
const ConstMap<int,string> InvSVMType = ConstMap<int,string>
    (cv::ml::SVM::C_SVC,     "C_SVC")
    (cv::ml::SVM::NU_SVC,    "NU_SVC")
    (cv::ml::SVM::ONE_CLASS, "ONE_CLASS")
    (cv::ml::SVM::EPS_SVR,   "EPS_SVR")
    (cv::ml::SVM::NU_SVR,    "NU_SVR");

/// Option values for SVM Kernel types
const ConstMap<string,int> SVMKernelType = ConstMap<string,int>
    ("Custom",       cv::ml::SVM::CUSTOM)
    ("Linear",       cv::ml::SVM::LINEAR)
    ("Poly",         cv::ml::SVM::POLY)
    ("RBF",          cv::ml::SVM::RBF)
    ("Sigmoid",      cv::ml::SVM::SIGMOID)
    ("Chi2",         cv::ml::SVM::CHI2)
    ("Intersection", cv::ml::SVM::INTER);

/// Option values for inverse SVM Kernel types
const ConstMap<int,string> InvSVMKernelType = ConstMap<int,string>
    (cv::ml::SVM::CUSTOM,  "Custom")
    (cv::ml::SVM::LINEAR,  "Linear")
    (cv::ml::SVM::POLY,    "Poly")
    (cv::ml::SVM::RBF,     "RBF")
    (cv::ml::SVM::SIGMOID, "Sigmoid")
    (cv::ml::SVM::CHI2,    "Chi2")
    (cv::ml::SVM::INTER,   "Intersection");

/// Option values for SVM params grid types
const ConstMap<string,int> SVMParamType = ConstMap<string,int>
    ("C",      cv::ml::SVM::C)
    ("Gamma",  cv::ml::SVM::GAMMA)
    ("P",      cv::ml::SVM::P)
    ("Nu",     cv::ml::SVM::NU)
    ("Coef",   cv::ml::SVM::COEF)
    ("Degree", cv::ml::SVM::DEGREE);

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
    else if (m.isChar())
        g = SVM::getDefaultGrid(SVMParamType[m.toString()]);
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Invalid argument to grid parameter");
    // SVM::trainAuto permits setting step<=1 if we want to disable optimizing
    // a certain paramter, in which case the value is taken from the props.
    // Besides the check is done by function itself, so its not needed here.
    //if (!g.check())
    //    mexErrMsgIdAndTxt("mexopencv:error","Invalid argument to grid parameter");
    return g;
}

/** Represents custom kernel implemented as a MATLAB function.
 */
class MatlabFunction : public cv::ml::SVM::Kernel
{
public:
    /** Constructor
     * @param func name of an M-file function that implements an SVM kernel
     */
    explicit MatlabFunction(const string &func)
    : fun_name(func)
    {}

    /** Evaluates MATLAB kernel function
     * @param[in] vcount number of samples
     * @param[in] n length of each sample
     * @param[in] vecs input array of length \c vcount*n
     * @param[in] another input array of length \p n
     * @param[out] results output array of length \p vcount
     *
     * Calculates <tt>results(i) = K(vecs(i,:), another)</tt>,
     * for <tt>i=1:vcount</tt>
     * (where each sample is of length \p n).
     */
    void calc(int vcount, int n, const float* vecs,
        const float* another, float* results)
    {
        // create input to evaluate kernel function
        mxArray *lhs, *rhs[3];
        rhs[0] = MxArray(fun_name);
        rhs[1] = MxArray(Mat(vcount, n, CV_32F, const_cast<float*>(vecs)));
        rhs[2] = MxArray(Mat(1, n, CV_32F, const_cast<float*>(another)));

        //TODO: mexCallMATLAB is not thread-safe!
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
            std::fill(results, results + vcount, 0.0f);
        }

        // cleanup
        mxDestroyArray(lhs);
        mxDestroyArray(rhs[0]);
        mxDestroyArray(rhs[1]);
        mxDestroyArray(rhs[2]);
    }

    /** Return type of SVM formulation
     * @return SVM type (custom)
     */
    int getType() const
    {
        return cv::ml::SVM::CUSTOM;
    }

    /** Factory function
     * @param func MATLAB function name.
     * @return smart pointer to newly created instance
     */
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
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // Check the number of arguments
    nargchk(nrhs>=2 && nlhs<=3);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        nargchk(nrhs==2 && nlhs<=1);
        obj_[++last_id] = SVM::create();
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<SVM> obj = obj_[id];
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
            Algorithm::loadFromString<SVM>(rhs[2].toString(), objname) :
            Algorithm::load<SVM>(rhs[2].toString(), objname));
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
                rhs[3].toMat(rhs[3].isInt32() ? CV_32S : CV_32F),
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
                rhs[3].toMat(rhs[3].isInt32() ? CV_32S : CV_32F),
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
    else if (method == "trainAuto") {
        nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=1);
        vector<MxArray> dataOptions;
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
            if (key == "Data")
                dataOptions = rhs[i+1].toVector<MxArray>();
            else if (key == "KFold")
                kFold = rhs[i+1].toInt();
            else if (key == "Balanced")
                balanced = rhs[i+1].toBool();
            else if (key == "CGrid")
                CGrid = toParamGrid(rhs[i+1]);
            else if (key == "GammaGrid")
                gammaGrid = toParamGrid(rhs[i+1]);
            else if (key == "PGrid")
                pGrid = toParamGrid(rhs[i+1]);
            else if (key == "NuGrid")
                nuGrid = toParamGrid(rhs[i+1]);
            else if (key == "CoeffGrid")
                coeffGrid = toParamGrid(rhs[i+1]);
            else if (key == "DegreeGrid")
                degreeGrid = toParamGrid(rhs[i+1]);
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
                rhs[3].toMat(rhs[3].isInt32() ? CV_32S : CV_32F),
                dataOptions.begin(), dataOptions.end());
        bool b = obj->trainAuto(data, kFold,
            CGrid, gammaGrid, pGrid, nuGrid, coeffGrid, degreeGrid, balanced);
        plhs[0] = MxArray(b);
    }
    else if (method == "getDecisionFunction") {
        nargchk(nrhs==3 && nlhs<=3);
        int index = rhs[2].toInt();
        Mat alpha, svidx;
        double rho = obj->getDecisionFunction(index, alpha, svidx);
        plhs[0] = MxArray(alpha);
        if (nlhs > 1)
            plhs[1] = MxArray(svidx);
        if (nlhs > 2)
            plhs[2] = MxArray(rho);
    }
    else if (method == "getSupportVectors") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getSupportVectors());
    }
    else if (method == "setCustomKernel") {
        nargchk(nrhs==3 && nlhs==0);
        obj->setCustomKernel(MatlabFunction::create(rhs[2].toString()));
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "Type")
            plhs[0] = MxArray(InvSVMType[obj->getType()]);
        else if (prop == "KernelType")
            plhs[0] = MxArray(InvSVMKernelType[obj->getKernelType()]);
        else if (prop == "Degree")
            plhs[0] = MxArray(obj->getDegree());
        else if (prop == "Gamma")
            plhs[0] = MxArray(obj->getGamma());
        else if (prop == "Coef0")
            plhs[0] = MxArray(obj->getCoef0());
        else if (prop == "C")
            plhs[0] = MxArray(obj->getC());
        else if (prop == "Nu")
            plhs[0] = MxArray(obj->getNu());
        else if (prop == "P")
            plhs[0] = MxArray(obj->getP());
        else if (prop == "ClassWeights")
            plhs[0] = MxArray(obj->getClassWeights());
        else if (prop == "TermCriteria")
            plhs[0] = MxArray(obj->getTermCriteria());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "Type")
            obj->setType(SVMType[rhs[3].toString()]);
        else if (prop == "KernelType")
            obj->setKernel(SVMKernelType[rhs[3].toString()]);
        else if (prop == "Degree")
            obj->setDegree(rhs[3].toDouble());
        else if (prop == "Gamma")
            obj->setGamma(rhs[3].toDouble());
        else if (prop == "Coef0")
            obj->setCoef0(rhs[3].toDouble());
        else if (prop == "C")
            obj->setC(rhs[3].toDouble());
        else if (prop == "Nu")
            obj->setNu(rhs[3].toDouble());
        else if (prop == "P")
            obj->setP(rhs[3].toDouble());
        else if (prop == "ClassWeights")
            obj->setClassWeights(rhs[3].toMat());
        else if (prop == "TermCriteria")
            obj->setTermCriteria(rhs[3].toTermCriteria());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
