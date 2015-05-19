/**
 * @file solveLP.cpp
 * @brief mex interface for solveLP
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

/** SolveLPResult map for option processing
 */
const ConstMap<int,string> SolveLPResultInvMap = ConstMap<int,string>
    (cv::SOLVELP_UNBOUNDED,  "Unbound")
    (cv::SOLVELP_UNFEASIBLE, "Unfeasible")
    (cv::SOLVELP_SINGLE,     "Single")
    (cv::SOLVELP_MULTI,      "Multi");

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
    if (nrhs!=2 || nlhs>2)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);

    // Process
    Mat Func(rhs[0].toMat(rhs[0].isSingle() ? CV_32F : CV_64F)),
        Constr(rhs[1].toMat(rhs[1].isSingle() ? CV_32F : CV_64F)),
        z;
    int result = solveLP(Func, Constr, z);
    plhs[0] = MxArray(z);
    if (nlhs>1)
        plhs[1] = MxArray(SolveLPResultInvMap[result]);
}
