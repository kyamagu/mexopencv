/**
 * @file buildOpticalFlowPyramid.cpp
 * @brief mex interface for cv::buildOpticalFlowPyramid
 * @ingroup video
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
    nargchk(nrhs>=1 && (nrhs%2)!=0 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    Size winSize(21,21);
    int maxLevel = 3;
    bool withDerivatives = true;
    int pyrBorder = cv::BORDER_REFLECT_101;
    int derivBorder = cv::BORDER_CONSTANT;
    bool tryReuseInputImage = true;  // TODO: has no effect
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "WinSize")
            winSize = rhs[i+1].toSize();
        else if (key == "MaxLevel")
            maxLevel = rhs[i+1].toInt();
        else if (key == "WithDerivatives")
            withDerivatives = rhs[i+1].toBool();
        else if (key == "PyrBorder")
            pyrBorder = (rhs[i+1].isChar()) ?
                BorderType[rhs[i+1].toString()] : rhs[i+1].toInt();
        else if (key == "DerivBorder")
            derivBorder = (rhs[i+1].isChar()) ?
                BorderType[rhs[i+1].toString()] : rhs[i+1].toInt();
        else if (key == "TryReuseInputImage")
            tryReuseInputImage = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat img(rhs[0].toMat(CV_8U));
    vector<Mat> pyramid;
    int maxLvl = buildOpticalFlowPyramid(img, pyramid, winSize, maxLevel,
        withDerivatives, pyrBorder, derivBorder, tryReuseInputImage);
    plhs[0] = MxArray(pyramid);
    if (nlhs > 1)
        plhs[1] = MxArray(maxLvl);
}
