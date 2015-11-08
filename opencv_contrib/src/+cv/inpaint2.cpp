/**
 * @file inpaint2.cpp
 * @brief mex interface for cv::xphoto::inpaint
 * @ingroup xphoto
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
#include "opencv2/xphoto.hpp"
using namespace std;
using namespace cv;
using namespace cv::xphoto;

namespace {
/// Inpainting algorithm types for option processing
const ConstMap<string,int> InpaintTypeMap = ConstMap<string,int>
    ("ShiftMap", cv::xphoto::INPAINT_SHIFTMAP);
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
    int algorithmType = cv::xphoto::INPAINT_SHIFTMAP;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Method")
            algorithmType = InpaintTypeMap[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat src(rhs[0].toMat()),
        mask(rhs[1].toMat(CV_8U)),
        dst;
    cv::xphoto::inpaint(src, mask, dst, algorithmType);
    plhs[0] = MxArray(dst);
}
