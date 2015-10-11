/**
 * @file findTransformECC.cpp
 * @brief mex interface for cv::findTransformECC
 * @ingroup video
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/// motion types for option processing
const ConstMap<string,int> MotionTypeMap = ConstMap<string,int>
    ("Translation", cv::MOTION_TRANSLATION)
    ("Euclidean",   cv::MOTION_EUCLIDEAN)
    ("Affine",      cv::MOTION_AFFINE)
    ("Homography",  cv::MOTION_HOMOGRAPHY);
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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int motionType = cv::MOTION_AFFINE;
    TermCriteria criteria(TermCriteria::COUNT+TermCriteria::EPS, 50, 0.001);
    Mat inputMask;
    Mat warpMatrix;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "MotionType")
            motionType = MotionTypeMap[rhs[i+1].toString()];
        else if (key == "Criteria")
            criteria = rhs[i+1].toTermCriteria();
        else if (key == "Mask")
            inputMask = rhs[i+1].toMat(CV_8U);
        else if (key == "InputWarp")
            warpMatrix = rhs[i+1].toMat(CV_32F);
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat templateImage(rhs[0].toMat(rhs[0].isUint8() ? CV_8U : CV_32F)),
        inputImage(rhs[1].toMat(rhs[1].isUint8() ? CV_8U : CV_32F));
    double rho = findTransformECC(templateImage, inputImage, warpMatrix,
        motionType, criteria, inputMask);
    plhs[0] = MxArray(warpMatrix);
    if (nlhs > 1)
        plhs[1] = MxArray(rho);
}
