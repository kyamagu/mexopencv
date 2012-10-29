/**
 * @file Boost_.cpp
 * @brief mex interface for Boost
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
map<int,CvBoost> obj_;

/// Option values for Boost types
const ConstMap<std::string,int> BoostType = ConstMap<std::string,int>
    ("Discrete", CvBoost::DISCRETE)
    ("Real",     CvBoost::REAL)
    ("Logit",    CvBoost::LOGIT)
    ("Gentle",   CvBoost::GENTLE);

/// Option values for Inverse boost types
const ConstMap<int,std::string> InvBoostType = ConstMap<int,std::string>
    (CvBoost::DISCRETE, "Discrete")
    (CvBoost::REAL,     "Real")
    (CvBoost::LOGIT,    "Logit")
    (CvBoost::GENTLE,   "Gentle");

/** Obtain CvBoostParams object from input arguments
 * @param it iterator at the beginning of the argument vector
 * @param end iterator at the end of the argument vector
 * @return CvBoostParams objects
 */
CvBoostParams getParams(vector<MxArray>::iterator it,
                        vector<MxArray>::iterator end)
{
    CvBoostParams params;
    for (;it<end;it+=2) {
        string key((*it).toString());
        MxArray& val = *(it+1);
        if (key=="BoostType")
            params.boost_type = BoostType[val.toString()];
        else if (key=="WeakCount")
            params.weak_count = val.toInt();
        else if (key=="WeightTrimRate")
            params.weight_trim_rate = val.toDouble();
        else if (key=="MaxDepth")
            params.max_depth = val.toInt();
        else if (key=="UseSurrogates")
            params.use_surrogates = val.toBool();
        //else
        //    mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    return params;
}

/** Create a new mxArray* from CvBoostParams
 * @param params CvBoostParams object
 * @return MxArray objects
 */
MxArray paramsToMxArray(const CvBoostParams& params)
{
    const char* fields[] = {"BoostType", "WeakCount", "WeightTrimRate",
        "MaxDepth", "UseSurrogates", "MaxCategories", "MinSampleCount",
        "CVFolds", "Use1seRule", "TruncatePrunedTree", "RegressionAccuracy"};
    MxArray m(fields,11);
    m.set("BoostType",InvBoostType[params.boost_type]);
    m.set("WeakCount",params.weak_count);
    m.set("WeightTrimRate",params.weight_trim_rate);
    m.set("MaxDepth",params.max_depth);
    m.set("UseSurrogates",params.use_surrogates);
    m.set("MaxCategories",params.max_categories);
    m.set("MinSampleCount",params.min_sample_count);
    m.set("CVFolds",params.cv_folds);
    m.set("Use1seRule",params.use_1se_rule);
    m.set("TruncatePrunedTree",params.truncate_pruned_tree);
    m.set("RegressionAccuracy",params.regression_accuracy);
    return m;
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
        obj_[++last_id] = CvBoost();
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
    CvBoost& obj = obj_[id];
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
        CvBoostParams params = getParams(rhs.begin()+4,rhs.end());
        vector<float> priors;
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
            else if (key=="Priors") {
                MxArray& m = rhs[i+1];
                priors.reserve(m.numel());
                for (int j=0; j<m.numel(); ++j)
                    priors.push_back(m.at<float>(j));
                params.priors = &priors[0];
            }
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
        bool rawMode=false, returnSum=false;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="MissingMask")
                missing = rhs[i+1].toMat(CV_8U);
            else if (key=="Slice")
                slice = rhs[i+1].toRange();
            else if (key=="RawMode")
                rawMode = rhs[i+1].toBool();
            else if (key=="ReturnSum")
                returnSum = rhs[i+1].toBool();
        }
        Mat results(samples.rows,1,CV_64F);
        if (missing.empty())
            for (int i=0; i<samples.rows; ++i)
                results.at<double>(i,0) = obj.predict(samples.row(i),missing,slice,rawMode,returnSum);
        else
            for (int i=0; i<samples.rows; ++i)
                results.at<double>(i,0) = obj.predict(samples.row(i),missing.row(i),slice,rawMode,returnSum);
        plhs[0] = MxArray(results);
    }
    else if (method == "get_params") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        plhs[0] = paramsToMxArray(obj.get_params());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
