/**
 * @file CLAHE.cpp
 * @brief mex interface for cv::CLAHE
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
    nargchk(nrhs>=1 && (nrhs%2)==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    double clipLimit = 40.0;
    Size tileGridSize(8,8);
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="ClipLimit")
            clipLimit = rhs[i+1].toDouble();
        else if (key=="TileGridSize")
            tileGridSize = rhs[i+1].toSize();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat src(rhs[0].toMat(rhs[0].isUint16() ? CV_16U : CV_8U)), dst;
    Ptr<CLAHE> obj = createCLAHE(clipLimit, tileGridSize);
    obj->apply(src, dst);
    plhs[0] = MxArray(dst);
}
