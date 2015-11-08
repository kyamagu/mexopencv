/**
 * @file balanceWhite.cpp
 * @brief mex interface for cv::xphoto::balanceWhite
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
/// White balance algorithm types for option processing
const ConstMap<string,int> WhitebalanceTypeMap = ConstMap<string,int>
    ("Simple",    cv::xphoto::WHITE_BALANCE_SIMPLE)
    ("GrayWorld", cv::xphoto::WHITE_BALANCE_GRAYWORLD);
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
    nargchk(nrhs>=1 && (nrhs%2)==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int algorithmType = cv::xphoto::WHITE_BALANCE_SIMPLE;
    float inputMin = 0.0f;
    float inputMax = 255.0f;
    float outputMin = 0.0f;
    float outputMax = 255.0f;
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Type")
            algorithmType = WhitebalanceTypeMap[rhs[i+1].toString()];
        else if (key == "InputMin")
            inputMin = rhs[i+1].toFloat();
        else if (key == "InputMax")
            inputMax = rhs[i+1].toFloat();
        else if (key == "OutputMin")
            outputMin = rhs[i+1].toFloat();
        else if (key == "OutputMax")
            outputMax = rhs[i+1].toFloat();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat src(rhs[0].toMat()),
        dst;
    balanceWhite(src, dst, algorithmType,
        inputMin, inputMax, outputMin, outputMax);
    plhs[0] = MxArray(dst);
}
