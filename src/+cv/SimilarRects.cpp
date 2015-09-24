/**
 * @file SimilarRects.cpp
 * @brief mex interface for cv::SimilarRects
 * @ingroup objdetect
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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    double eps = 0.2;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "EPS")
            eps = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Rect r1(rhs[0].toRect()),
         r2(rhs[1].toRect());
    SimilarRects obj(eps);
    bool b = obj(r1, r2);
    plhs[0] = MxArray(b);
}
