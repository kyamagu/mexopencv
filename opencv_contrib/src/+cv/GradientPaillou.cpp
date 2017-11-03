/**
 * @file GradientPaillou.cpp
 * @brief mex interface for cv::ximgproc::GradientPaillouX, cv::ximgproc::GradientPaillouY
 * @ingroup ximgproc
 * @author Amro
 * @date 2017
 */
#include "mexopencv.hpp"
#include "opencv2/ximgproc.hpp"
using namespace std;
using namespace cv;
using namespace cv::ximgproc;

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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    double alpha = 1.0;
    double omega = 0.1;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Alpha")
            alpha = rhs[i+1].toDouble();
        else if (key == "Omega")
            omega = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat op(rhs[0].toMat()),  // 8u, 8s, 16u, 16s
        dst;
    string dir(rhs[1].toString());
    if (dir == "X")
        GradientPaillouX(op, dst, alpha, omega);
    else if (dir == "Y")
        GradientPaillouY(op, dst, alpha, omega);
    else
        mexErrMsgIdAndTxt("mexopencv:error", "Invalid arguments");
    plhs[0] = MxArray(dst);
}
