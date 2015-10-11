/**
 * @file getDerivKernels.cpp
 * @brief mex interface for cv::getDerivKernels
 * @ingroup imgproc
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/// KSize map for option processing
const ConstMap<string,int> KSizeMap = ConstMap<string,int>
    ("Scharr", CV_SCHARR);
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
    nargchk((nrhs%2)==0 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int dx = 1;
    int dy = 1;
    int ksize = 3;
    bool normalize = false;
    int ktype = CV_32F;
    for (int i=0; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="Dx")
            dx = rhs[i+1].toInt();
        else if (key=="Dy")
            dy = rhs[i+1].toInt();
        else if (key=="KSize")
            ksize = (rhs[i+1].isChar()) ?
                KSizeMap[rhs[i+1].toString()] : rhs[i+1].toInt();
        else if (key=="Normalize")
            normalize = rhs[i+1].toBool();
        else if (key=="KType")
            ktype = (rhs[i+1].isChar()) ?
                ClassNameMap[rhs[i+1].toString()] : rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat kx, ky;
    getDerivKernels(kx, ky, dx, dy, ksize, normalize, ktype);
    plhs[0] = MxArray(kx);
    if (nlhs>1)
        plhs[1] = MxArray(ky);
}
