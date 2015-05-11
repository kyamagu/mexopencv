/**
 * @file SVM_.cpp
 * @brief mex interface for SVM
 * @author Kota Yamaguchi
 * @date 2012
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

/// Option values for SVM types
const ConstMap<std::string,int> SVMType = ConstMap<std::string,int>
    ("C_SVC",     SVM::C_SVC)
    ("NU_SVC",    SVM::NU_SVC)
    ("ONE_CLASS", SVM::ONE_CLASS)
    ("EPS_SVR",   SVM::EPS_SVR)
    ("NU_SVR",    SVM::NU_SVR);

/// Option values for SVM types
const ConstMap<std::string,int> SVMKernelType = ConstMap<std::string,int>
    ("Linear",    SVM::LINEAR)
    ("Poly",      SVM::POLY)
    ("RBF",       SVM::RBF)
    ("Sigmoid",   SVM::SIGMOID);

/// Option values for SVM types
const ConstMap<int,std::string> InvSVMType = ConstMap<int,std::string>
    (SVM::C_SVC,    "C_SVC")
    (SVM::NU_SVC,   "NU_SVC")
    (SVM::ONE_CLASS,"ONE_CLASS")
    (SVM::EPS_SVR,  "EPS_SVR")
    (SVM::NU_SVR,   "NU_SVR");

/// Option values for SVM types
const ConstMap<int,std::string> InvSVMKernelType = ConstMap<int,std::string>
    (SVM::LINEAR,   "Linear")
    (SVM::POLY,     "Poly")
    (SVM::RBF,      "RBF")
    (SVM::SIGMOID,  "Sigmoid");

/** Obtain ParamGrid object from MxArray
 * @param m MxArray object
 * @return ParamGrid objects
 */
ParamGrid getGrid(MxArray& m)
{
    ParamGrid g;
    if (m.isNumeric() && m.numel()==3) {
        g.minVal = m.at<double>(0);
        g.maxVal = m.at<double>(1);
        g.logStep = m.at<double>(2);
    } else if (m.isStruct() && m.numel()==1) {
        mxArray* pm;
        if ((pm = mxGetField(m,0,"minVal"))) g.minVal = MxArray(pm).toDouble();
        if ((pm = mxGetField(m,0,"maxVal"))) g.maxVal = MxArray(pm).toDouble();
        if ((pm = mxGetField(m,0,"logStep"))) g.logStep = MxArray(pm).toDouble();
    } else {
        mexErrMsgIdAndTxt("mexopencv:error","Invalid argument to grid parameter");
    }
    
    // SVM::trainAuto permits setting step<=1 if we want to disable optimizing
    // a certain paramter, in which case the value is taken from params.
    // Besides the check is done by the function itself, so its not needed here.
    //if (!g.check())
    //    mexErrMsgIdAndTxt("mexopencv:error","Invalid argument to grid parameter");
    return g;
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
    if (nrhs<2 || nlhs>1)
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
        if (nrhs!=3 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        obj = Algorithm::load<SVM>(rhs[2].toString());
    }
    else if (method == "save") {
        if (nrhs!=3 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        obj->save(rhs[2].toString());
    }
    else if (method == "train") {
        if (nrhs!=4 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        int layout = cv::ml::ROW_SAMPLE;
        Mat samples(rhs[2].toMat(CV_32F));
        Mat responses(rhs[3].toMat(rhs[3].isInt32() ? CV_32S : CV_32F));
        bool b = obj->train(samples, layout, responses);
        plhs[0] = MxArray(b);
    }
    else if (method == "predict") {
        if (nrhs!=3 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat samples(rhs[2].toMat(CV_32F));
        Mat results;
        int flags = 0;
        obj->predict(samples, results, flags);
        plhs[0] = MxArray(results);
    }
    else if (method == "trainAuto") {
        if (nrhs<4 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat varIdx, sampleIdx;
        int layout = cv::ml::ROW_SAMPLE;
        int kFold = 10;
        ParamGrid CGrid      = SVM::getDefaultGrid(SVM::C),
                  gammaGrid  = SVM::getDefaultGrid(SVM::GAMMA),
                  pGrid      = SVM::getDefaultGrid(SVM::P),
                  nuGrid     = SVM::getDefaultGrid(SVM::NU),
                  coeffGrid  = SVM::getDefaultGrid(SVM::COEF),
                  degreeGrid = SVM::getDefaultGrid(SVM::DEGREE);
        bool balanced = false;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="VarIdx")
                varIdx = rhs[i+1].toMat(
                    (rhs[i+1].isUint8() || rhs[i+1].isLogical()) ? CV_8U : CV_32S);
            else if (key=="SampleIdx")
                sampleIdx = rhs[i+1].toMat(
                    (rhs[i+1].isUint8() || rhs[i+1].isLogical()) ? CV_8U : CV_32S);
            else if (key=="KFold")
                kFold = rhs[i+1].toInt();
            else if (key=="Balanced")
                balanced = rhs[i+1].toBool();
            else if (key=="CGrid")
                CGrid = getGrid(rhs[i+1]);
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
        Mat samples(rhs[2].toMat(CV_32F));
        Mat responses(rhs[3].toMat(rhs[3].isInt32() ? CV_32S : CV_32F));
        Ptr<TrainData> data = TrainData::create(samples, layout, responses,
            varIdx, sampleIdx);
        bool b = obj->trainAuto(data, kFold,
            CGrid, gammaGrid, pGrid, nuGrid, coeffGrid, degreeGrid, balanced);
        plhs[0] = MxArray(b);
    }
    else if (method == "getSupportVectors") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        plhs[0] = MxArray(obj->getSupportVectors());
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
