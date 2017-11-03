/**
 * @file anisotropicDiffusion.cpp
 * @brief mex interface for cv::ximgproc::anisotropicDiffusion
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
    nargchk(nrhs>=1 && (nrhs%2)==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    float alpha = 1.0f;  // 1.0/7
    float K = 0.02f;
    int niters = 10;  // 1
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Alpha")
            alpha = rhs[i+1].toFloat();
        else if (key == "K")
            K = rhs[i+1].toFloat();
        else if (key == "Iterations")
            niters = rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat src(rhs[0].toMat(CV_8U)), dst;
    anisotropicDiffusion(src, dst, alpha, K, niters);
    plhs[0] = MxArray(dst);
}
