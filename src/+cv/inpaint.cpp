/**
 * @file inpaint.cpp
 * @brief mex interface for cv::inpaint
 * @ingroup photo
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
#include "opencv2/photo.hpp"
using namespace std;
using namespace cv;

namespace {
/// Inpainting algorithm types for option processing
const ConstMap<string,int> InpaintType = ConstMap<string,int>
    ("NS",    cv::INPAINT_NS)
    ("Telea", cv::INPAINT_TELEA);
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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    double inpaintRadius = 3.0;
    int flags = cv::INPAINT_NS;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="Radius")
            inpaintRadius = rhs[i+1].toDouble();
        else if (key=="Method")
            flags = InpaintType[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat src(rhs[0].toMat(CV_8U)),
        mask(rhs[1].toMat(CV_8U)),
        dst;
    inpaint(src, mask, dst, inpaintRadius, flags);
    plhs[0] = MxArray(dst);
}
