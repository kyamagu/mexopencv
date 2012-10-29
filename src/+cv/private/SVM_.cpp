/**
 * @file SVM_.cpp
 * @brief mex interface for SVM
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,SVM> obj_;

/// Option values for SVM types
const ConstMap<std::string,int> SVMType = ConstMap<std::string,int>
    ("C_SVC",      cv::SVM::C_SVC)
    ("NU_SVC",      cv::SVM::NU_SVC)
    ("ONE_CLASS", cv::SVM::ONE_CLASS)
    ("EPS_SVR",   cv::SVM::EPS_SVR)
    ("NU_SVR",    cv::SVM::NU_SVR);

/// Option values for SVM types
const ConstMap<std::string,int> SVMKernelType = ConstMap<std::string,int>
    ("Linear",      cv::SVM::LINEAR)
    ("Poly",      cv::SVM::POLY)
    ("RBF",       cv::SVM::RBF)
    ("Sigmoid",   cv::SVM::SIGMOID);

/// Option values for SVM types
const ConstMap<int,std::string> InvSVMType = ConstMap<int,std::string>
    (cv::SVM::C_SVC,    "C_SVC")
    (cv::SVM::NU_SVC,   "NU_SVC")
    (cv::SVM::ONE_CLASS,"ONE_CLASS")
    (cv::SVM::EPS_SVR,  "EPS_SVR")
    (cv::SVM::NU_SVR,   "NU_SVR");

/// Option values for SVM types
const ConstMap<int,std::string> InvSVMKernelType = ConstMap<int,std::string>
    (cv::SVM::LINEAR,   "Linear")
    (cv::SVM::POLY,     "Poly")
    (cv::SVM::RBF,      "RBF")
    (cv::SVM::SIGMOID,  "Sigmoid");

/** Obtain CvSVMParams object from input arguments
 * @param it iterator at the beginning of the argument vector
 * @param end iterator at the end of the argument vector
 * @return CvSVMParams objects
 */
CvSVMParams getParams(    vector<MxArray>::iterator it,
                        vector<MxArray>::iterator end)
{
    CvSVMParams params;
    for (;it<end;it+=2) {
        string key((*it).toString());
        MxArray& val = *(it+1);
        if (key=="SVMType")
            params.svm_type = SVMType[val.toString()];
        else if (key=="KernelType")
            params.kernel_type = SVMKernelType[val.toString()];
        else if (key=="Degree")
            params.degree = val.toDouble();
        else if (key=="Gamma")
            params.gamma = val.toDouble();
        else if (key=="Coef0")
            params.coef0 = val.toDouble();
        else if (key=="C")
            params.C = val.toDouble();
        else if (key=="Nu")
            params.nu = val.toDouble();
        else if (key=="P")
            params.p = val.toDouble();
        else if (key=="TermCrit") {
            params.term_crit = val.toTermCriteria();
        }
    }
    return params;
}

/// Field names of svm_params struct
const char* cv_svm_params_fields[] = {"svm_type","kernel_type","degree","gamma",
    "coef0","C","nu","p","class_weights","term_crit"};

/** Create a new mxArray* from CvSVMParams
 * @param params CvSVMParams object
 * @return CvSVMParams objects
 */
mxArray* cvSVMParamsToMxArray(const cv::SVMParams& params)
{
    mxArray *p = mxCreateStructMatrix(1,1,10,cv_svm_params_fields);
    if (!p)
        mexErrMsgIdAndTxt("mexopencv:error","Allocation error");
    mxSetField(const_cast<mxArray*>(p),0,"svm_type",      MxArray(InvSVMType[params.svm_type]));
    mxSetField(const_cast<mxArray*>(p),0,"kernel_type",   MxArray(InvSVMKernelType[params.kernel_type]));
    mxSetField(const_cast<mxArray*>(p),0,"degree",        MxArray(params.degree));
    mxSetField(const_cast<mxArray*>(p),0,"gamma",         MxArray(params.gamma));
    mxSetField(const_cast<mxArray*>(p),0,"coef0",         MxArray(params.coef0));
    mxSetField(const_cast<mxArray*>(p),0,"C",             MxArray(params.C));
    mxSetField(const_cast<mxArray*>(p),0,"nu",            MxArray(params.nu));
    mxSetField(const_cast<mxArray*>(p),0,"p",             MxArray(params.p));
    mxSetField(const_cast<mxArray*>(p),0,"class_weights", MxArray(params.class_weights));
    mxSetField(const_cast<mxArray*>(p),0,"term_crit",     MxArray(params.term_crit));
    return p;
}

/** Obtain CvParamGrid object from MxArray
 * @param m MxArray object
 * @return CvParamGrid objects
 */
CvParamGrid getGrid(MxArray& m)
{
    if (m.isNumeric() && m.numel()==3) {
        CvParamGrid g(m.at<double>(0),m.at<double>(1),m.at<double>(2));
        if (!g.check())
            mexErrMsgIdAndTxt("mexopencv:error","Invalid argument to grid parameter");
        return g;
    }
    else if (m.isStruct() && m.numel()==1) {
        mxArray* pm;
        double min_val = (pm=mxGetField(m,0,"min_val")) ? MxArray(pm).toDouble() : 0;
        double max_val = (pm=mxGetField(m,0,"max_val")) ? MxArray(pm).toDouble() : 0;
        double log_step = (pm=mxGetField(m,0,"log_step")) ? MxArray(pm).toDouble() : 0;
        CvParamGrid g(min_val, max_val, log_step);
        if (!g.check())
            mexErrMsgIdAndTxt("mexopencv:error","Invalid argument to grid parameter");
        return g;
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Invalid argument to grid parameter");
}
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
    if (nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Determine argument format between constructor or (id,method,...)
    vector<MxArray> rhs(prhs,prhs+nrhs);
    int id = 0;
    string method;
    if (nrhs==0) {
        // Constructor is called. Create a new object from argument
        obj_[++last_id] = SVM();
        plhs[0] = MxArray(last_id);
        return;
    }
    else if (rhs[0].isNumeric() && rhs[0].numel()==1 && nrhs>1) {
        id = rhs[0].toInt();
        method = rhs[1].toString();
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Invalid arguments");
    
    // Big operation switch
    SVM& obj = obj_[id];
    if (method == "delete") {
        if (nrhs!=2 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Output not assigned");
        obj_.erase(id);
    }
    else if (method == "clear") {
        if (nrhs!=2 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        obj.clear();
    }
    else if (method == "load") {
        if (nrhs!=3 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        obj.load(rhs[2].toString().c_str());
    }
    else if (method == "save") {
        if (nrhs!=3 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        obj.save(rhs[2].toString().c_str());
    }
    else if (method == "train") {
        if (nrhs<4 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat trainData(rhs[2].toMat(CV_32F));
        Mat responses(rhs[3].toMat(CV_32F));
        Mat varIdx, sampleIdx;
        CvSVMParams params = getParams(rhs.begin()+4,rhs.end());
        Mat class_weights;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="VarIdx")
                varIdx = rhs[i+1].toMat(CV_32S);
            else if (key=="SampleIdx")
                sampleIdx = rhs[i+1].toMat(CV_32S);
            else if (key=="ClassWeights") {
                class_weights = rhs[i+1].toMat();
                CvMat _m = class_weights;
                params.class_weights = &_m;
            }
        }
        bool b = obj.train(trainData,responses,varIdx,sampleIdx,params);
        plhs[0] = MxArray(b);
    }
    else if (method == "predict") {
        if (nrhs<3 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat samples(rhs[2].toMat(CV_32F));
        Mat results(samples.rows,1,CV_32FC1);
        bool returnDFVal=false;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="ReturnDFVal")
                returnDFVal = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        for (int i=0; i<samples.rows; ++i)
            results.at<float>(i,0) = obj.predict(samples.row(i));
        plhs[0] = MxArray(results);
    }
    else if (method == "train_auto") {
        if (nrhs<4 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat trainData(rhs[2].toMat(CV_32F));
        Mat responses(rhs[3].toMat(CV_32F));
        Mat varIdx, sampleIdx;
        int k_fold=10;
        CvParamGrid Cgrid=CvSVM::get_default_grid(CvSVM::C);
        CvParamGrid gammaGrid=CvSVM::get_default_grid(CvSVM::GAMMA);
        CvParamGrid pGrid=CvSVM::get_default_grid(CvSVM::P);
        CvParamGrid nuGrid=CvSVM::get_default_grid(CvSVM::NU);
        CvParamGrid coeffGrid=CvSVM::get_default_grid(CvSVM::COEF);
        CvParamGrid degreeGrid=CvSVM::get_default_grid(CvSVM::DEGREE);
        bool balanced=false;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="VarIdx")
                varIdx = rhs[i+1].toMat(CV_32S);
            else if (key=="SampleIdx")
                sampleIdx = rhs[i+1].toMat(CV_32S);
            else if (key=="KFold")
                k_fold = rhs[i+1].toInt();
            else if (key=="Balanced")
                balanced = rhs[i+1].toInt();
            else if (key=="CGrid")
                Cgrid = getGrid(rhs[i+1]);
            else if (key=="GammaGrid")
                gammaGrid = getGrid(rhs[i+1]);
            else if (key=="PGrid")
                pGrid = getGrid(rhs[i+1]);
            else if (key=="NuGrid")
                nuGrid = getGrid(rhs[i+1]);
            else if (key=="CoeffGrid")
                coeffGrid = getGrid(rhs[i+1]);
            else if (key=="DegreeGrid")
                degreeGrid = getGrid(rhs[i+1]);
        }
        CvSVMParams params = getParams(rhs.begin()+4,rhs.end());
        bool b = obj.train_auto(trainData,responses,varIdx,sampleIdx,params,
            k_fold, Cgrid, gammaGrid, pGrid, nuGrid, coeffGrid, degreeGrid, balanced);
        plhs[0] = MxArray(b);
    }
    else if (method == "get_var_count") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        plhs[0] = MxArray(obj.get_var_count());
    }
    else if (method == "get_params") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        CvSVMParams params = obj.get_params();
        plhs[0] = MxArray(cvSVMParamsToMxArray(params));
    }
    else if (method == "get_support_vector_count") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        plhs[0] = MxArray(obj.get_support_vector_count());
    }
    else if (method == "get_support_vector") {
        if (nrhs!=3 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        const float *sv = obj.get_support_vector(rhs[2].toInt());
        vector<float> svv(sv,sv+obj.get_var_count());
        plhs[0] = MxArray(Mat(svv));
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
