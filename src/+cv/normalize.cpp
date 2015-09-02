/**
 * @file normalize.cpp
 * @brief mex interface for cv::normalize
 * @ingroup core
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
    nargchk(nrhs>=1 && (nrhs%2)!=0 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    double alpha = 1.0, beta = 0.0;
    int norm_type = cv::NORM_L2;
    int dtype = -1;
    Mat mask, dst;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Alpha")
            alpha = rhs[i+1].toDouble();
        else if (key == "Beta")
            beta = rhs[i+1].toDouble();
        else if (key == "NormType")
            norm_type = (rhs[i+1].isChar()) ?
                NormType[rhs[i+1].toString()] : rhs[i+1].toInt();
        else if (key == "DType")
            dtype = (rhs[i+1].isChar()) ?
                ClassNameMap[rhs[i+1].toString()] : rhs[i+1].toInt();
        else if (key == "Mask")
            mask = rhs[i+1].toMat(CV_8U);
        else if (key == "Dest") {
            dst = rhs[i+1].toMat();
            dtype = dst.depth();
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat src(rhs[0].toMat());
    if (!mask.empty() && dst.empty()) {
        // make sure dst is initialized in case mask was used
        int dst_depth = (dtype < 0) ? src.depth() : dtype;
        dst.create(src.size(), CV_MAKETYPE(dst_depth, src.channels()));
        src.convertTo(dst, dst_depth);  // init as src
        //dst.setTo(Scalar::all(0));    // init as blank
    }
    normalize(src, dst, alpha, beta, norm_type, dtype, mask);
    plhs[0] = MxArray(dst);
}
