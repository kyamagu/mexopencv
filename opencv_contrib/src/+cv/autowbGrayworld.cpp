/**
 * @file autowbGrayworld.cpp
 * @brief mex interface for cv::xphoto::autowbGrayworld
 * @ingroup xphoto
 * @author Amro
 * @date 2016
 */
#include "mexopencv.hpp"
#include "opencv2/xphoto.hpp"
using namespace std;
using namespace cv;
using namespace cv::xphoto;

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
    float thresh = 0.5f;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Thresh")
            thresh = rhs[i+1].toFloat();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat src(rhs[0].toMat(CV_8U)),
        dst;
    autowbGrayworld(src, dst, thresh);
    plhs[0] = MxArray(dst);
}
