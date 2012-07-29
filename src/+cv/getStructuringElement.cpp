/**
 * @file getStructuringElement.cpp
 * @brief mex interface for getStructuringElement
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

/** Shape map for morphological operation for option processing
 */
const ConstMap<std::string,int> MorphShape = ConstMap<std::string,int>
    ("Rect",    cv::MORPH_RECT)
    ("Cross",    cv::MORPH_CROSS)
    ("Ellipse",    cv::MORPH_ELLIPSE);

/**
 * Main entry called from Matlab
 * @param nlhs number of left-hand-side arguments
 * @param plhs pointers to mxArrays in the left-hand-side
 * @param nrhs number of right-hand-side arguments
 * @param prhs pointers to mxArrays in the right-hand-side
 */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    // Check the number of arguments
    if ((nrhs%2)!=0 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    // Option processing
    int shape=MORPH_RECT;
    Size ksize(3,3);
    Point anchor=Point(-1,-1);
    for (int i=0; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="Shape")
            shape = MorphShape[rhs[i+1].toString()];
        else if (key=="KSize")
            ksize = rhs[i+1].toSize();
        else if (key=="Anchor")
            anchor = rhs[i+1].toPoint();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Process
    plhs[0] = MxArray(getStructuringElement(shape, ksize, anchor));
}
