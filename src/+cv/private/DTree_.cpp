/**
 * @file DTree_.cpp
 * @brief mex interface for DTree
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
map<int,CvDTree> obj_;

/** Obtain CvDTreeParams object from input arguments
 * @param it iterator at the beginning of the argument vector
 * @param end iterator at the end of the argument vector
 * @return CvDTreeParams objects
 */
CvDTreeParams getParams(vector<MxArray>::iterator it,
                        vector<MxArray>::iterator end)
{
    CvDTreeParams params;
    for (;it<end;it+=2) {
        string key((*it).toString());
        MxArray& val = *(it+1);
        if (key=="MaxDepth")
            params.max_depth = val.toInt();
        else if (key=="MinSampleCount")
            params.min_sample_count = val.toInt();
        else if (key=="RegressionAccuracy")
            params.regression_accuracy = val.toDouble();
        else if (key=="UseSurrogates")
            params.use_surrogates = val.toBool();
        else if (key=="MaxCategories")
            params.max_categories = val.toInt();
        else if (key=="CVFolds")
            params.cv_folds = val.toInt();
        else if (key=="Use1seRule")
            params.use_1se_rule = val.toBool();
        else if (key=="TruncatePrunedTree")
            params.truncate_pruned_tree = val.toBool();
        //else
        //    mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    return params;
}

/** Create a struct from CvDTreeParams
 */
MxArray paramsToMxArray(CvDTreeParams& params)
{
    const char* fields[] = {"MaxCategories","MaxDepth","MinSampleCount",
        "CVFolds","UseSurrogates","Use1seRule","TruncatePrunedTree",
        "RegressionAccuracy"};
    MxArray m(fields,8);
    m.set("MaxCategories",params.max_categories);
    m.set("MaxDepth",params.max_depth);
    m.set("MinSampleCount",params.min_sample_count);
    m.set("CVFolds",params.cv_folds);
    m.set("UseSurrogates",params.use_surrogates);
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
        obj_[++last_id] = CvDTree();
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
    CvDTree& obj = obj_[id];
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
        Mat varIdx, sampleIdx, missing_mask;
        Mat varType(1,trainData.cols+1,CV_8U,Scalar(CV_VAR_ORDERED));
        varType.at<uchar>(0,trainData.cols) = CV_VAR_CATEGORICAL;
        CvDTreeParams params = getParams(rhs.begin()+4,rhs.end());
        vector<float> priors;
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
                missing_mask = rhs[i+1].toMat(CV_8U);
            else if (key=="Priors") {
                MxArray& m = rhs[i+1];
                priors.reserve(m.numel());
                for (int j=0; j<m.numel(); ++j)
                    priors.push_back(m.at<float>(j));
                params.priors = &priors[0];
            }
        }
        bool b = obj.train(trainData, CV_ROW_SAMPLE, responses, varIdx,
            sampleIdx, varType, missing_mask, params);
        plhs[0] = MxArray(b);
    }
    else if (method == "predict") {
        if (nrhs<3 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat samples(rhs[2].toMat(CV_32F)), missingDataMask;
        bool preprocessedInput=false;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="MissingMask")
                missingDataMask = rhs[i+1].toMat(CV_8U);
            else if (key=="PreprocessedInput")
                preprocessedInput = rhs[i+1].toBool();
        }
        Mat results(samples.rows,1,CV_64F);
        for (int i=0; i<samples.rows; ++i)
            results.at<double>(i,0) = obj.predict(samples.row(i))->value;
        plhs[0] = MxArray(results);
    }
    else if (method == "getVarImportance") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        const CvMat* m = obj.get_var_importance();
        plhs[0] = MxArray((m) ? Mat(m) : Mat());
    }
    else if (method == "get_pruned_tree_idx") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        plhs[0] = MxArray(obj.get_pruned_tree_idx());
    }
    else if (method == "params") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        CvDTreeTrainData* d = obj.get_data();
        plhs[0] = (d) ? paramsToMxArray(d->params) : MxArray(Mat());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
