/**
 * @file ConjGradSolver_.cpp
 * @brief mex interface for cv::ConjGradSolver
 * @ingroup core
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
map<int,Ptr<ConjGradSolver> > obj_;

/// Represents objective function being optimized, implemented as a MATLAB file.
class MatlabFunction : public cv::MinProblemSolver::Function
{
public:
    /** Constructor
     * @param num_dims number of variables of the objective function
     * @param func name of an M-file that computes the objective function
     * @param grad_func name of an M-file that computes the gradient of the
     *                  objective function. Can be empty.
     * @param h gradient epsilon
     */
    MatlabFunction(int num_dims, const string &func, const string &grad_func = "", double h = 1e-3)
    : dims(num_dims), fun_name(func), grad_fun_name(grad_func), gradeps(h)
    {}

    /** Evaluates MATLAB objective function
     * @param[in] x input array of length \c dims
     * @return objective function evaluated at \p x (scalar value)
     *
     * Calculates <tt>y = F(x)</tt>, for the scalar-valued multivariate
     * objective function evaluated at the \c dims -dimensional point \c x
     *
     * Example:
     * @code
     * % the following MATLAB function implements the Rosenbrock function.
     * function f = rosenbrock(x)
     *     dims = numel(x);  % dims == 2
     *     f = (x(1) - 1)^2 + 100*(x(2) - x(1)^2)^2;
     * end
     * @endcode
     */
    double calc(const double *x) const
    {
        // create input to evaluate objective function
        mxArray *lhs, *rhs[2];
        rhs[0] = MxArray(fun_name);
        rhs[1] = MxArray(vector<double>(x, x + dims));

        // evaluate specified function in MATLAB as:
        // val = feval("fun_name", x)
        double val;
        if (mexCallMATLAB(1, &lhs, 2, rhs, "feval") == 0) {
            MxArray res(lhs);
            CV_Assert(res.isDouble() && !res.isComplex() && res.numel() == 1);
            val = res.at<double>(0);
        }
        else {
            //TODO: error
            val = 0;
        }

        // cleanup
        mxDestroyArray(lhs);
        mxDestroyArray(rhs[0]);
        mxDestroyArray(rhs[1]);

        // return scalar value of objective function evaluated at x
        return val;
    }

    /** Evaluates MATLAB gradient function
     * @param[in] x input array of length \c dims
     * @param[out] grad output array of length \c dims
     *
     * Evaluates gradient of multivariate function at the specified point,
     * by computing <tt>grad = del F(x)</tt>, where <tt>grad_i = dF/dx_i</tt>
     * for <tt>i=1:dims</tt> (partial derivatives w.r.t each dimension).
     *
     * Example:
     * @code
     * function df = rosenbrockGrad(x)
     *     dims = numel(x);  % dims == 2
     *     df = [2*(x(1)-1) - 400*x(1)*(x(2)-x(1)^2), 200*(x(2)-x(1)^2)];
     * end
     * @endcode
     */
    void getGradient(const double* x, double* grad) /*const*/
    {
        // if no function is specified, approximate the gradient using
        // finite difference method: F'(x) = (F(x+h) - F(x-h)) / 2*h
        if (grad_fun_name.empty()) {
            cv::MinProblemSolver::Function::getGradient(x, grad);
            return;
        }

        // create input to evaluate gradient function
        mxArray *lhs, *rhs[2];
        rhs[0] = MxArray(grad_fun_name);
        rhs[1] = MxArray(vector<double>(x, x + dims));

        // evaluate specified function in MATLAB as:
        // grad = feval("grad_fun_name", x)
        if (mexCallMATLAB(1, &lhs, 2, rhs, "feval") == 0) {
            MxArray res(lhs);
            CV_Assert(res.isDouble() && !res.isComplex() && res.ndims() == 2);
            vector<double> v(res.toVector<double>());
            CV_Assert(v.size() == dims);
            std::copy(v.begin(), v.end(), grad);
        }
        else {
            //TODO: error
            std::fill(grad, grad + dims, 0.0);
        }

        // cleanup
        mxDestroyArray(lhs);
        mxDestroyArray(rhs[0]);
        mxDestroyArray(rhs[1]);
    }

    /** Gradient epsilon
     * @return gradient eps
     */
    double getGradientEps() const
    {
        return gradeps;
    }

    /** Return number of dimensions.
     * @return dimensionality of the objective function domain
     */
    int getDims() const
    {
        return dims;
    }

    /** Convert object to MxArray
     * @return output MxArray structure
     */
    MxArray toStruct() const
    {
        MxArray s(MxArray::Struct());
        s.set("dims",    dims);
        s.set("fun",     fun_name);
        s.set("gradfun", grad_fun_name);
        s.set("gradeps", gradeps);
        return s;
    }

    /** Factory function
     * @param s input MxArray structure with the following fields:
     *    - dims
     *    - fun
     *    - gradfun (optional, default '')
     *    - gradeps (optional, default 1e-3)
     * @return smart pointer to newly created instance
     */
    static Ptr<MatlabFunction> create(const MxArray &s)
    {
        if (!s.isStruct() || s.numel()!=1)
            mexErrMsgIdAndTxt("mexopencv:error", "Invalid objective function");
        return makePtr<MatlabFunction>(
            s.at("dims").toInt(),
            s.at("fun").toString(),
            s.isField("gradfun") ? s.at("gradfun").toString() : "",
            s.isField("gradeps") ? s.at("gradeps").toDouble() : 1e-3);
    }

private:
    int dims;              ///<! number of dimensions
    string fun_name;       ///<! name of M-file (objective function)
    string grad_fun_name;  ///<! name of M-file (gradient function)
    double gradeps;        ///<! gradient epsilon
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
    nargchk(nrhs>=2 && nlhs<=2);

    // Arguments vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);
        Ptr<MinProblemSolver::Function> f;
        TermCriteria termcrit(TermCriteria::MAX_ITER+TermCriteria::EPS, 5000, 1e-6);
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="Function")
                f = MatlabFunction::create(rhs[i+1]);
            else if (key=="TermCriteria")
                termcrit = rhs[i+1].toTermCriteria();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        obj_[++last_id] = ConjGradSolver::create(f, termcrit);
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<ConjGradSolver> obj = obj_[id];
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
    }
    else if (method == "clear") {
        nargchk(nrhs==2 && nlhs==0);
        obj->clear();
    }
    else if (method == "load") {
        //TODO
        nargchk(false);
    }
    else if (method == "save") {
        //TODO
        nargchk(false);
    }
    else if (method == "empty") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->empty());
    }
    else if (method == "getDefaultName") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getDefaultName());
    }
    else if (method == "minimize") {
        nargchk(nrhs==3 && nlhs<=2);
        Mat x(rhs[2].toMat(CV_64F));
        double fx = obj->minimize(x);
        plhs[0] = MxArray(x);
        if (nlhs>1)
            plhs[1] = MxArray(fx);
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "Function") {
            Ptr<MinProblemSolver::Function> f(obj->getFunction());
            plhs[0] = (f.empty()) ? MxArray::Struct() :
                (f.dynamicCast<MatlabFunction>())->toStruct();
        }
        else if (prop == "TermCriteria")
            plhs[0] = MxArray(obj->getTermCriteria());
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "Function")
            obj->setFunction(MatlabFunction::create(rhs[3]));
        else if (prop == "TermCriteria")
            obj->setTermCriteria(rhs[3].toTermCriteria());
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
