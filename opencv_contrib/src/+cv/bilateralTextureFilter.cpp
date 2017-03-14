/**
 * @file bilateralTextureFilter.cpp
 * @brief mex interface for cv::ximgproc::bilateralTextureFilter
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
    int fr = 3;
    int numIter = 1;
    double sigmaAlpha = -1.0;
    double sigmaAvg = -1.0;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "FR")
            fr = rhs[i+1].toInt();
        else if (key == "NumIter")
            numIter = rhs[i+1].toInt();
        else if (key == "SigmaAlpha")
            sigmaAlpha = rhs[i+1].toDouble();
        else if (key == "SigmaAvg")
            sigmaAvg = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat src(rhs[0].toMat(rhs[0].isUint8() ? CV_8U : CV_32F)),
        dst;
    bilateralTextureFilter(src, dst, fr, numIter, sigmaAlpha, sigmaAvg);
    plhs[0] = MxArray(dst);
}
