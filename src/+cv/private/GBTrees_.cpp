/**
 * @file GBTrees_.cpp
 * @brief mex interface for GBTrees
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
map<int,CvGBTrees> obj_;

/// Option values for GBTrees types
const ConstMap<std::string,int> GBTreesType = ConstMap<std::string,int>
    ("Squared",  CvGBTrees::SQUARED_LOSS)
    ("Absolute", CvGBTrees::ABSOLUTE_LOSS)
    ("Huber",    CvGBTrees::HUBER_LOSS)
    ("Deviance", CvGBTrees::DEVIANCE_LOSS);

/// Option values for Inverse boost types
const ConstMap<int,std::string> InvGBTreesType = ConstMap<int,std::string>
    (CvGBTrees::SQUARED_LOSS,  "Squared")
    (CvGBTrees::ABSOLUTE_LOSS, "Absolute")
    (CvGBTrees::HUBER_LOSS,    "Huber")
    (CvGBTrees::DEVIANCE_LOSS, "Deviance");

/** Obtain CvGBTreesParams object from input arguments
 * @param it iterator at the beginning of the argument vector
 * @param end iterator at the end of the argument vector
 * @return CvGBTreesParams objects
 */
CvGBTreesParams getParams(vector<MxArray>::iterator it,
                        vector<MxArray>::iterator end)
{
    CvGBTreesParams params;
    for (;it<end;it+=2) {
        string key((*it).toString());
        MxArray& val = *(it+1);
        if (key=="LossFunction")
            params.loss_function_type = GBTreesType[val.toString()];
        else if (key=="WeakCount")
            params.weak_count = val.toInt();
        else if (key=="Shrinkage")
            params.shrinkage = val.toDouble();
        else if (key=="SubsamplePortion")
            params.subsample_portion = val.toDouble();
        else if (key=="MaxDepth")
            params.max_depth = val.toInt();
        else if (key=="UseSurrogates")
            params.use_surrogates = val.toBool();
        //else
        //    mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    return params;
}

/// Field names of boost_params struct
const char* cv_gbtrees_params_fields[] = {"loss_function_type","weak_count",
    "shrinkage","subsample_portion", "max_depth","use_surrogates"};

/** Create a new mxArray* from CvGBTreesParams
 * @param params CvGBTreesParams object
 * @return CvGBTreesParams objects
 */
mxArray* cvGBTreesParamsToMxArray(const CvGBTreesParams& params)
{
    mxArray *p = mxCreateStructMatrix(1,1,6,cv_gbtrees_params_fields);
    if (!p)
        mexErrMsgIdAndTxt("mexopencv:error","Allocation error");
    mxSetField(const_cast<mxArray*>(p),0,"loss_function_type",MxArray(InvGBTreesType[params.loss_function_type]));
    mxSetField(const_cast<mxArray*>(p),0,"weak_count",        MxArray(params.weak_count));
    mxSetField(const_cast<mxArray*>(p),0,"shrinkage",           MxArray(params.shrinkage));
    mxSetField(const_cast<mxArray*>(p),0,"subsample_portion", MxArray(params.subsample_portion));
    mxSetField(const_cast<mxArray*>(p),0,"max_depth",         MxArray(params.max_depth));
    mxSetField(const_cast<mxArray*>(p),0,"use_surrogates",    MxArray(params.use_surrogates));
    return p;
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
        obj_[++last_id] = CvGBTrees();
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
    CvGBTrees& obj = obj_[id];
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
        Mat varIdx, sampleIdx, missingMask;
        Mat varType(1,trainData.cols+1,CV_8U,Scalar(CV_VAR_ORDERED));
        varType.at<uchar>(0,trainData.cols) = CV_VAR_CATEGORICAL;
        CvGBTreesParams params = getParams(rhs.begin()+4,rhs.end());
        bool update=false;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="VarIdx")
                varIdx = rhs[i+1].toMat(CV_32S);
            else if (key=="SampleIdx")
                sampleIdx = rhs[i+1].toMat(CV_32S);
            else if (key=="VarType") {
                if (rhs[i+1].isChar())
                    varType.at<uchar>(0,trainData.cols) = 
                        (rhs[i+1].toString()=="Categorical") ? 
                        CV_VAR_CATEGORICAL : CV_VAR_ORDERED;
                else if (rhs[i+1].isNumeric())
                    varType = rhs[i+1].toMat(CV_8U);
            }
            else if (key=="MissingMask")
                missingMask = rhs[i+1].toMat(CV_8U);
            else if (key=="Update")
                update = rhs[i+1].toBool();
        }
        bool b = obj.train(trainData, CV_ROW_SAMPLE, responses, varIdx,
            sampleIdx, varType, missingMask, params, update);
        plhs[0] = MxArray(b);
    }
    else if (method == "predict") {
        if (nrhs<3 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat samples(rhs[2].toMat(CV_32F)), missing;
        Range slice = Range::all();
        int k=-1;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="MissingMask")
                missing = rhs[i+1].toMat(CV_8U);
            else if (key=="Slice")
                slice = rhs[i+1].toRange();
            else if (key=="K")
                k = rhs[i+1].toInt();
        }
        Mat results(samples.rows,1,CV_64F);
        if (missing.empty())
            for (int i=0; i<samples.rows; ++i)
                results.at<double>(i) = obj.predict(samples.row(i),missing,slice,k);
        else
            for (int i=0; i<samples.rows; ++i)
                results.at<double>(i) = obj.predict(samples.row(i),missing.row(i),slice,k);
        plhs[0] = MxArray(results);
    }
    //else if (method == "get_params") {
    //    if (nrhs!=2 || nlhs>1)
    //        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    //    plhs[0] = MxArray(cvGBTreesParamsToMxArray(obj.get_params()));
    //}
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}

