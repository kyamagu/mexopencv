/**
 * @file initCameraMatrix2D.cpp
 * @brief mex interface for cv::initCameraMatrix2D
 * @ingroup calib3d
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
    nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    double aspectRatio = 1.0;
    for (int i=3; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="AspectRatio")
            aspectRatio = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    vector<vector<Point3f> > objectPoints(MxArrayToVectorVectorPoint3<float>(rhs[0]));
    vector<vector<Point2f> > imagePoints(MxArrayToVectorVectorPoint<float>(rhs[1]));
    Size imageSize(rhs[2].toSize());
    Mat A = initCameraMatrix2D(objectPoints, imagePoints, imageSize, aspectRatio);
    plhs[0] = MxArray(A);
}
