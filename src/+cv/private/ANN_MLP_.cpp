/**
 * @file ANN_MLP_.cpp
 * @brief mex interface for ANN_MLP
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
map<int,CvANN_MLP> obj_;

/// Option values for ANN_MLP train types
const ConstMap<std::string,int> ANN_MLPTrain = ConstMap<std::string,int>
    ("Backprop",  CvANN_MLP_TrainParams::BACKPROP)
    ("RProp",     CvANN_MLP_TrainParams::RPROP);
/// Inverse option values for ANN_MLP train types
const ConstMap<int,std::string> InvANN_MLPTrain = ConstMap<int,std::string>
    (CvANN_MLP_TrainParams::BACKPROP, "Backprop")
    (CvANN_MLP_TrainParams::RPROP,    "RProp");
/// Option values for ANN_MLP activation function
const ConstMap<std::string,int> ActivateFunc = ConstMap<std::string,int>
    ("Identity",  CvANN_MLP::IDENTITY)
    ("Sigmoid",   CvANN_MLP::SIGMOID_SYM)
    ("Gaussian",  CvANN_MLP::GAUSSIAN);
/// Inverse option values for ANN_MLP activation function
const ConstMap<int,std::string> InvActivateFunc = ConstMap<int,std::string>
    (CvANN_MLP::IDENTITY,   "Identity")
    (CvANN_MLP::SIGMOID_SYM, "Sigmoid")
    (CvANN_MLP::GAUSSIAN,   "Gaussian");

/** Obtain CvANN_MLP_TrainParams object from input arguments
 * @param it iterator at the beginning of the argument vector
 * @param end iterator at the end of the argument vector
 * @return CvANN_MLP_TrainParams objects
 */
CvANN_MLP_TrainParams getParams(vector<MxArray>::iterator it,
                                vector<MxArray>::iterator end)
{
    CvANN_MLP_TrainParams params;
    for (;it<end;it+=2) {
        string key((*it).toString());
        MxArray& val = *(it+1);
        if (key=="BpDwScale")
            params.bp_dw_scale = val.toDouble();
        else if (key=="BpMomentScale")
            params.bp_moment_scale = val.toDouble();
        else if (key=="RpDw0")
            params.rp_dw0 = val.toDouble();
        else if (key=="RpDwPlus")
            params.rp_dw_plus = val.toDouble();
        else if (key=="RpDwMinus")
            params.rp_dw_minus = val.toDouble();
        else if (key=="RpDwMin")
            params.rp_dw_min = val.toDouble();
        else if (key=="RpDwMax")
            params.rp_dw_max = val.toDouble();
        else if (key=="TermCrit")
            params.term_crit = val.toTermCriteria();
        else if (key=="TrainMethod")
            params.train_method = ANN_MLPTrain[val.toString()];
    }
    return params;
}

/// Field names of svm_params struct
const char* cv_ann_mlp_train_params_fields[] = {"term_crit"};

/** Create a new mxArray* from CvANN_MLPParams
 * @param params CvANN_MLPParams object
 * @return CvANN_MLPParams objects
 */
mxArray* cvANN_MLP_TrainParamsToMxArray(const cv::ANN_MLP_TrainParams& params)
{
    mxArray *p = mxCreateStructMatrix(1,1,1,cv_ann_mlp_train_params_fields);
    if (!p)
        mexErrMsgIdAndTxt("mexopencv:error","Allocation error");
    mxSetField(const_cast<mxArray*>(p),0,"term_crit",MxArray(TermCriteria(params.term_crit)));
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
        obj_[++last_id] = CvANN_MLP();
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
    CvANN_MLP& obj = obj_[id];
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
    else if (method == "create") {
        if (nrhs<3 || nlhs>0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat layerSizes(rhs[2].toMat(CV_32S));
        int activateFunc=CvANN_MLP::SIGMOID_SYM;
        double fparam1=0, fparam2=0;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="ActivateFunc")
                activateFunc = ActivateFunc[rhs[i+1].toString()];
            else if (key=="FParam1")
                fparam1 = rhs[i+1].toDouble();
            else if (key=="FParam2")
                fparam2 = rhs[i+1].toDouble();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        obj.create(layerSizes, activateFunc, fparam1, fparam2);
    }
    else if (method == "train") {
        if (nrhs<4 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat inputs(rhs[2].toMat(CV_32F));
        Mat outputs(rhs[3].toMat(CV_32F));
        Mat sampleWeights, sampleIdx;
        CvANN_MLP_TrainParams params = getParams(rhs.begin()+4,rhs.end());
        bool updateWeights=false;
        bool noInputScale=false;
        bool noOutputScale=false;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="SampleWeights")
                sampleWeights = rhs[i+1].toMat(CV_32F);
            else if (key=="SampleIdx")
                sampleIdx = rhs[i+1].toMat(CV_32S);
            else if (key=="UpdateWeights")
                updateWeights = rhs[i+1].toBool();
            else if (key=="NoInputScale")
                noInputScale = rhs[i+1].toBool();
            else if (key=="NoOutputScale")
                noOutputScale = rhs[i+1].toBool();
        }
        int flags = (updateWeights ? CvANN_MLP::UPDATE_WEIGHTS  : 0) |
                    (noInputScale ?  CvANN_MLP::NO_INPUT_SCALE  : 0) |
                    (noOutputScale ? CvANN_MLP::NO_OUTPUT_SCALE : 0);
        int x = obj.train(inputs, outputs, sampleWeights, sampleIdx, params, flags);
        plhs[0] = MxArray(x);
    }
    else if (method == "predict") {
        if (nrhs<3 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat inputs(rhs[2].toMat(CV_32F)), outputs;
        obj.predict(inputs, outputs);
        plhs[0] = MxArray(outputs);
    }
    else if (method == "get_layer_count") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        plhs[0] = MxArray(obj.get_layer_count());
    }
    else if (method == "get_layer_sizes") {
        if (nrhs!=2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        const CvMat* ls = obj.get_layer_sizes();
        plhs[0] = MxArray(Mat(ls));
    }
    else if (method == "get_weights") {
        if (nrhs!=3 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        int layer = rhs[2].toInt();
        const Mat ls(obj.get_layer_sizes());
        double* w = obj.get_weights(layer);
        vector<double> wv(w,w+ls.at<int>(0,layer));
        plhs[0] = MxArray(Mat(wv));
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
