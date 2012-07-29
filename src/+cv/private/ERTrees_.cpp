/**
 * @file ERTrees_.cpp
 * @brief mex interface for ERTrees
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
map<int,CvERTrees> obj_;

/** Obtain CvRTParams object from input arguments
 * @param it iterator at the beginning of the argument vector
 * @param end iterator at the end of the argument vector
 * @return CvRTParams objects
 */
CvRTParams getParams(vector<MxArray>::iterator it,
                        vector<MxArray>::iterator end)
{
    CvRTParams params;
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
        else if (key=="CalcVarImportance")
            params.calc_var_importance = val.toBool();
        else if (key=="NActiveVars")
            params.nactive_vars = val.toInt();
        else if (key=="MaxNumOfTreesInTheForest")
            params.term_crit.max_iter = val.toInt();
        else if (key=="ForestAccuracy")
            params.term_crit.epsilon = val.toDouble();
        else if (key=="TermCritType") {
            if (val.isChar()) {
                string s(val.toString());
                if (s=="Iter")
                    params.term_crit.type = CV_TERMCRIT_ITER;
                else if (s=="EPS")
                    params.term_crit.type = CV_TERMCRIT_EPS;
                else if (s=="Iter+EPS")
                    params.term_crit.type = CV_TERMCRIT_ITER|CV_TERMCRIT_EPS;
                else
                    mexErrMsgIdAndTxt("mexopencv:error","Unrecognized TermCritType");
            }
            else
                params.term_crit.type = val.toInt();
        }
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
        obj_[++last_id] = CvERTrees();
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
    CvERTrees& obj = obj_[id];
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
        CvRTParams params = getParams(rhs.begin()+4,rhs.end());
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
                missingMask = rhs[i+1].toMat(CV_8U);
            else if (key=="Priors") {
                MxArray& m = rhs[i+1];
                priors.reserve(m.numel());
                for (int j=0; j<m.numel(); ++j)
                    priors.push_back(m.at<float>(j));
                params.priors = &priors[0];
            }
        }
        bool b = obj.train(trainData, CV_ROW_SAMPLE, responses, varIdx,
            sampleIdx, varType, missingMask, params);
        plhs[0] = MxArray(b);
    }
    else if (method == "predict") {
        if (nrhs<3 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat samples(rhs[2].toMat(CV_32F)), missing;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="MissingMask")
                missing = rhs[i+1].toMat(CV_8U);
        }
        Mat results(samples.rows,1,CV_64F);
        if (missing.empty())
            for (int i=0; i<samples.rows; ++i)
                results.at<double>(i,0) = obj.predict(samples.row(i),missing);
        else
            for (int i=0; i<samples.rows; ++i)
                results.at<double>(i,0) = obj.predict(samples.row(i),missing.row(i));
        plhs[0] = MxArray(results);
    }
    else if (method == "predict_prob") {
        if (nrhs<3 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat samples(rhs[2].toMat(CV_32F)), missing;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="MissingDataMask")
                missing = rhs[i+1].toMat(CV_8U);
        }
        Mat results(samples.rows,1,CV_64F);
        if (missing.empty())
            for (int i=0; i<samples.rows; ++i)
                results.at<double>(i,0) = obj.predict_prob(samples.row(i),missing);
        else
            for (int i=0; i<samples.rows; ++i)
                results.at<double>(i,0) = obj.predict_prob(samples.row(i),missing.row(i));
        plhs[0] = MxArray(results);
    }
    else if (method == "getVarImportance") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        const CvMat* m = obj.get_var_importance();
        plhs[0] = MxArray((m) ? Mat(m) : Mat());
    }
    else if (method == "get_proximity") {
        if (nrhs<4 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat sample1(rhs[2].toMat(CV_32F)), sample2(rhs[3].toMat(CV_32F));
        Mat missing1, missing2;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="Missing1")
                missing1 = rhs[i+1].toMat(CV_8U);
            else if (key=="Missing2")
                missing2 = rhs[i+1].toMat(CV_8U);
        }
        CvMat _sample1 = sample1, _sample2 = sample2;
        CvMat _missing1 = missing1, _missing2 = missing2;
        float x = obj.get_proximity(&_sample1, &_sample2,
            (missing1.empty()) ? NULL : &_missing1,
            (missing2.empty()) ? NULL : &_missing2);
        plhs[0] = MxArray(x);
    }
    else if (method == "get_train_error") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        plhs[0] = MxArray(obj.get_train_error());
    }
    else if (method == "get_tree_count") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        plhs[0] = MxArray(obj.get_tree_count());
    }
    else if (method == "get_active_var_mask") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        CvMat* m = obj.get_active_var_mask();
        plhs[0] = MxArray((m) ? Mat(m) : Mat());
    }
    else if (method == "params") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        CvDTreeTrainData* d = (obj.get_tree_count()>0) ?
            obj.get_tree(0)->get_data() : 0;
        plhs[0] = (d) ? paramsToMxArray(d->params) : MxArray(Mat());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
