/**
 * @file phaseCorrelate.cpp
 * @brief mex interface for cv::phaseCorrelate
 * @ingroup imgproc
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    Mat window;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Window")
            window = rhs[i+1].toMat(rhs[i+1].isSingle() ? CV_32F : CV_64F);
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat src1(rhs[0].toMat(rhs[0].isSingle() ? CV_32F : CV_64F)),
        src2(rhs[1].toMat(rhs[1].isSingle() ? CV_32F : CV_64F));
    double response = 0;
    Point2d pshift = phaseCorrelate(src1, src2, window, &response);
    plhs[0] = MxArray(pshift);
    if (nlhs > 1)
        plhs[1] = MxArray(response);
}
