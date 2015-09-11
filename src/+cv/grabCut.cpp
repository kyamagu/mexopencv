/**
 * @file grabCut.cpp
 * @brief mex interface for cv::grabCut
 * @ingroup imgproc
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/// GrabCut algorithm types for option processing
const ConstMap<string,int> GrabCutType = ConstMap<string,int>
    ("InitWithRect", cv::GC_INIT_WITH_RECT)
    ("InitWithMask", cv::GC_INIT_WITH_MASK)
    ("Eval",         cv::GC_EVAL);
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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=3);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    bool rect_variant = (rhs[1].numel() == 4 &&
        (rhs[1].rows()==1 || rhs[1].cols()==1));

    // Option processing
    Mat bgdModel, fgdModel;
    int iterCount = 10;
    int mode = cv::GC_EVAL;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="BgdModel")
            bgdModel = rhs[i+1].toMat(CV_64F);
        else if (key=="FgdModel")
            fgdModel = rhs[i+1].toMat(CV_64F);
        else if (key=="IterCount")
            iterCount = rhs[i+1].toInt();
        else if (key=="Mode")
            mode = GrabCutType[rhs[i+1].toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Initialize mask and rect
    Mat mask;
    Rect rect;
    if (rect_variant) {
        rect = rhs[1].toRect();
        mode = cv::GC_INIT_WITH_RECT;
    }
    else
        mask = rhs[1].toMat(CV_8U);

    // Process
    Mat img(rhs[0].toMat(CV_8U));
    grabCut(img, mask, rect, bgdModel, fgdModel, iterCount, mode);
    plhs[0] = MxArray(mask);
    if (nlhs > 1)
        plhs[1] = MxArray(bgdModel);
    if (nlhs > 2)
        plhs[2] = MxArray(fgdModel);
}
