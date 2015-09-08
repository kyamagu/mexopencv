/**
 * @file cornerSubPix.cpp
 * @brief mex interface for cv::cornerSubPix
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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    Size winSize(3,3);
    Size zeroZone(-1,-1);
    TermCriteria criteria(TermCriteria::COUNT+TermCriteria::EPS, 50, 0.001);
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="WinSize")
            winSize = rhs[i+1].toSize();
        else if (key=="ZeroZone")
            zeroZone = rhs[i+1].toSize();
        else if (key=="Criteria")
            criteria = rhs[i+1].toTermCriteria();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat image(rhs[0].toMat(rhs[0].isUint8() ? CV_8U : CV_32F));
    if (rhs[1].isNumeric()) {
        Mat corners(rhs[1].toMat(CV_32F));
        cornerSubPix(image, corners, winSize, zeroZone, criteria);
        plhs[0] = MxArray(corners);
    }
    else if (rhs[1].isCell()) {
        vector<Point2f> corners(rhs[1].toVector<Point2f>());
        cornerSubPix(image, corners, winSize, zeroZone, criteria);
        plhs[0] = MxArray(corners);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error", "Invalid input");
}
