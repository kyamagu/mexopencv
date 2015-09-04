/**
 * @file meanShift.cpp
 * @brief mex interface for cv::meanShift
 * @ingroup video
 * @author Kota Yamaguchi
 * @date 2011
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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    TermCriteria criteria(TermCriteria::COUNT+TermCriteria::EPS, 100, 1.0);
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="Criteria")
            criteria = rhs[i+1].toTermCriteria();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat probImage(rhs[0].toMat());
    Rect window(rhs[1].toRect());
    int iter = meanShift(probImage, window, criteria);
    plhs[0] = MxArray(window);
    if (nlhs>1)
        plhs[1] = MxArray(iter);
}
