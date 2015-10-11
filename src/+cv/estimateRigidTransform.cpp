/**
 * @file estimateRigidTransform.cpp
 * @brief mex interface for cv::estimateRigidTransform
 * @ingroup video
 * @author Kota Yamaguchi
 * @date 2012
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
    bool fullAffine = false;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="FullAffine")
            fullAffine = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat M;
    if (rhs[0].isNumeric() && rhs[1].isNumeric()) {
        // images
        Mat src(rhs[0].toMat(CV_8U)),
            dst(rhs[1].toMat(CV_8U));
        M = estimateRigidTransform(src, dst, fullAffine);
    }
    else if (rhs[0].isCell() && rhs[1].isCell()) {
        // points
        vector<Point2f> src(rhs[0].toVector<Point2f>()),
                        dst(rhs[1].toVector<Point2f>());
        M = estimateRigidTransform(src, dst, fullAffine);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Invalid argument");
    plhs[0] = MxArray(M);
}
