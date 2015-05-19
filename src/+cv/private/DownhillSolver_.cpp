/**
 * @file DownhillSolver_.cpp
 * @brief mex interface for DownhillSolver
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<DownhillSolver> > obj_;

/** Represents function being optimized.
 */
class MatlabFunction : public cv::MinProblemSolver::Function
{
public:
    MatlabFunction(int num_dims, const string &func)
    : dims(num_dims), fun_name(func)
    {}

    double calc(const double *x) const
    {
        // create input to evaluate objective function
        mxArray *lhs, *rhs[2];
        rhs[0] = mxCreateString(fun_name.c_str());
        rhs[1] = mxCreateDoubleMatrix(1, dims, mxREAL);
        memcpy(mxGetPr(rhs[1]), x, sizeof(double)*dims);

        // evaluate specified function: val = feval("fun_name", x)
        double val = 0;
        if (mexCallMATLAB(1, &lhs, 2, rhs, "feval") == 0)
            val = mxGetScalar(lhs);

        // cleanup
        mxDestroyArray(lhs);
        mxDestroyArray(rhs[0]);
        mxDestroyArray(rhs[1]);

        // return scalar value of objective function evaluated at x
        return val;
    }

    MxArray toStruct() const
    {
        MxArray s(MxArray::Struct());
        s.set("dims",    dims);
        s.set("fun",     fun_name);
        return s;
    }

    static Ptr<MatlabFunction> create(const MxArray &s)
    {
        if (!s.isStruct() || s.numel()!=1)
            mexErrMsgIdAndTxt("mexopencv:error", "Invalid objective function");
        return makePtr<MatlabFunction>(
            s.at("dims").toInt(), s.at("fun").toString());
    }

private:
    int dims;
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
    if (nrhs<2 || nlhs>2)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    // Arguments vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        if (nrhs<2 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Ptr<MinProblemSolver::Function> f;
        Mat initStep(Mat_<double>(1, 1, 0.0));
        TermCriteria termcrit(TermCriteria::MAX_ITER+TermCriteria::EPS, 5000, 1e-6);
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="Function")
                f = MatlabFunction::create(rhs[i+1]);
            else if (key=="InitStep")
                initStep = rhs[i+1].toMat(CV_64F);
            else if (key=="TermCriteria")
                termcrit = rhs[i+1].toTermCriteria();
            else
                mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized option %s", key.c_str());
        }
        obj_[++last_id] = DownhillSolver::create(f, initStep, termcrit);
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<DownhillSolver> obj = obj_[id];
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
        //TODO
    }
    else if (method == "save") {
        //TODO
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
    else if (method == "minimize") {
        if (nrhs!=3 || nlhs>2)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        Mat x(rhs[2].toMat());
        double fx = obj->minimize(x);
        plhs[0] = MxArray(x);
        if (nlhs>1)
            plhs[1] = MxArray(fx);
    }
    else if (method == "get") {
        if (nrhs!=3 || nlhs>1)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        string prop(rhs[2].toString());
        if (prop == "Function") {
            Ptr<MinProblemSolver::Function> f(obj->getFunction());
            plhs[0] = (f.empty()) ? MxArray::Struct() :
                (f.dynamicCast<MatlabFunction>())->toStruct();
        }
        else if (prop == "InitStep") {
            Mat initStep;
            obj->getInitStep(initStep);
            plhs[0] = MxArray(initStep);
        }
        else if (prop == "TermCriteria")
            plhs[0] = MxArray(obj->getTermCriteria());
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        if (nrhs!=4 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        string prop(rhs[2].toString());
        if (prop == "Function")
            obj->setFunction(MatlabFunction::create(rhs[3]));
        else if (prop == "InitStep")
            obj->setInitStep(rhs[3].toMat(CV_64F));
        else if (prop == "TermCriteria")
            obj->setTermCriteria(rhs[3].toTermCriteria());
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
