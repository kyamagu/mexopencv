/**
 * @file resize.cpp
 * @brief mex interface for cv::resize
 * @ingroup imgproc
 * @author Kota Yamaguchi
 * @date 2012
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
    nargchk(nrhs>=2 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Determine variant
    bool scale_variant = (nrhs>=3 &&
        rhs[1].isNumeric() && rhs[1].numel()==1 &&
        rhs[2].isNumeric() && rhs[2].numel()==1);
    nargchk((nrhs%2) == (scale_variant ? 1 : 0));

    // Option processing
    int interpolation = cv::INTER_LINEAR;
    for (int i=(scale_variant ? 3 : 2); i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="Interpolation")
            interpolation = InterpType[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Decide size/scale arguments
    Size dsize;
    double fx = 0, fy = 0;
    if (scale_variant) {
        fx = rhs[1].toDouble();
        fy = rhs[2].toDouble();
    }
    else
        dsize = rhs[1].toSize();

    // Process
    Mat src(rhs[0].toMat()), dst;
    resize(src, dst, dsize, fx, fy, interpolation);
    plhs[0] = MxArray(dst);
}
