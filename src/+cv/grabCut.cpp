/**
 * @file grabCut.cpp
 * @brief mex interface for grabCut
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

/** GrabCut algorithm types for option processing
 */
const ConstMap<std::string,int> GrabCutType = ConstMap<std::string,int>
    ("Rect",cv::GC_INIT_WITH_RECT)
    ("Mask",cv::GC_INIT_WITH_MASK)
    ("Eval",cv::GC_EVAL);

/**
 * Main entry called from Matlab
 * @param nlhs number of left-hand-side arguments
 * @param plhs pointers to mxArrays in the left-hand-side
 * @param nrhs number of right-hand-side arguments
 * @param prhs pointers to mxArrays in the right-hand-side
 *
 * This is the entry point of the function
 */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    // Check the input format
    if (nrhs<2 || (nrhs%2)!=0 || nlhs>3)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");    
    if (rhs[0].classID()!=mxUINT8_CLASS)
        mexErrMsgIdAndTxt("mexopencv:error","Only UINT8 type is supported");
    if (rhs[0].ndims()!=3)
        mexErrMsgIdAndTxt("mexopencv:error","Only RGB format is supported");
    
    // Option processing
    Mat bgdModel, fgdModel;
    int iterCount = 10;
    int mode = (rhs[1].isDouble() && rhs[1].numel()==4) ?
                GC_INIT_WITH_RECT : GC_INIT_WITH_MASK; // Automatic determination
    if (nrhs>2) {
        for (int i=2; i<nrhs; i+=2) {
            string key = rhs[i].toString();
            if (key=="BgdModel")
                bgdModel = rhs[i+1].toMat();
            else if (key=="FgdModel")
                fgdModel = rhs[i+1].toMat();
            else if (key=="Init")
                mode = GrabCutType[rhs[i+1].toString()];
            else if (key=="MaxIter")
                iterCount = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
    }
    
    // Initialize mask and rect
    Mat mask;
    Rect rect;
    if (mode == GC_INIT_WITH_MASK)
        mask = rhs[1].toMat(CV_8U);
    else
        rect = rhs[1].toRect();
    
    // Apply grabCut
    Mat img(rhs[0].toMat());
    grabCut(img, mask, rect, bgdModel, fgdModel, iterCount, mode);
    
    // Convert cv::Mat to mxArray
    plhs[0] = MxArray(mask);
    if (nlhs > 1)
        plhs[1] = MxArray(bgdModel);
    if (nlhs > 2)
        plhs[2] = MxArray(fgdModel);
}
