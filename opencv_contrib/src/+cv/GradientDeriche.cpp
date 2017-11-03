/**
 * @file GradientDeriche.cpp
 * @brief mex interface for cv::ximgproc::GradientDericheX, cv::ximgproc::GradientDericheY
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
    double alphaDerive = 1.0;
    double alphaMean = 1.0;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "AlphaDerive")
            alphaDerive = rhs[i+1].toDouble();
        else if (key == "AlphaMean")
            alphaMean = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat op(rhs[0].toMat()), dst;
    string dir(rhs[1].toString());
    if (dir == "X")
        GradientDericheX(op, dst, alphaDerive, alphaMean);
    else if (dir == "Y")
        GradientDericheY(op, dst, alphaDerive, alphaMean);
    else
        mexErrMsgIdAndTxt("mexopencv:error", "Invalid arguments");
    plhs[0] = MxArray(dst);
}
