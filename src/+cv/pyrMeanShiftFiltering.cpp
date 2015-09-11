/**
 * @file pyrMeanShiftFiltering.cpp
 * @brief mex interface for cv::pyrMeanShiftFiltering
 * @ingroup imgproc
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
    nargchk(nrhs>=1 && (nrhs%2)==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    double sp = 5;
    double sr = 10;
    int maxLevel = 1;
    TermCriteria termcrit(TermCriteria::MAX_ITER+TermCriteria::EPS, 5, 1);
    for (int i=1; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="SP")
            sp = rhs[i+1].toDouble();
        else if (key=="SR")
            sr = rhs[i+1].toDouble();
        else if (key=="MaxLevel")
            maxLevel = rhs[i+1].toInt();
        else if (key=="Criteria")
            termcrit = rhs[i+1].toTermCriteria();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat src(rhs[0].toMat(CV_8U)), dst;
    pyrMeanShiftFiltering(src, dst, sp, sr, maxLevel, termcrit);
    plhs[0] = MxArray(dst);
}
