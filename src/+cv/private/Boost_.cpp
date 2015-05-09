/**
 * @file Boost_.cpp
 * @brief mex interface for Boost
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
map<int,Ptr<Boost> > obj_;

/// Option values for Boost types
const ConstMap<std::string,int> BoostType = ConstMap<std::string,int>
    ("Discrete", Boost::DISCRETE)
    ("Real",     Boost::REAL)
    ("Logit",    Boost::LOGIT)
    ("Gentle",   Boost::GENTLE);

/// Option values for Inverse boost types
const ConstMap<int,std::string> InvBoostType = ConstMap<int,std::string>
    (Boost::DISCRETE, "Discrete")
    (Boost::REAL,     "Real")
    (Boost::LOGIT,    "Logit")
    (Boost::GENTLE,   "Gentle");
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
        obj_[++last_id] = Boost::create();
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<Boost> obj = obj_[id];
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
        obj = Algorithm::load<Boost>(rhs[2].toString());
    }
    else if (method == "save") {
        if (nrhs!=3 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        obj->save(rhs[2].toString());
    }
    else if (method == "train") {
        if (nrhs!=4 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat samples(rhs[2].toMat(CV_32F));
        Mat responses(rhs[3].toMat(CV_32F));
        bool b = obj->train(samples, ROW_SAMPLE, responses);
        plhs[0] = MxArray(b);
    }
    else if (method == "predict") {
        if (nrhs!=3 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat samples(rhs[2].toMat(CV_32F)), results;
        obj->predict(samples, results);
        plhs[0] = MxArray(results);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
