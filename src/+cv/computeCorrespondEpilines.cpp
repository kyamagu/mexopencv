/**
 * @file computeCorrespondEpilines.cpp
 * @brief mex interface for cv::computeCorrespondEpilines
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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int whichImage = 1;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="WhichImage")
            whichImage = rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    if (whichImage!=1 && whichImage!=2)
        mexErrMsgIdAndTxt("mexopencv:error","Invalid WhichImage");

    // Process
    Mat F(rhs[1].toMat(CV_64F));
    if (rhs[0].isNumeric()) {
        Mat points(rhs[0].toMat(rhs[0].isSingle() ? CV_32F : CV_64F)), lines;
        bool cn1 = (points.channels() == 1 && (points.cols == 2 || points.cols == 3));
        if (cn1) points = points.reshape(points.cols, 0);  // Nxd => Nx1xd
        computeCorrespondEpilines(points, whichImage, F, lines);
        if (cn1) lines = lines.reshape(1,0);  // Nx1x3 => Nx3
        plhs[0] = MxArray(lines);
    }
    else if (rhs[0].isCell()) {
        vector<Point2d> points(rhs[0].toVector<Point2d>());
        vector<Point3d> lines;
        computeCorrespondEpilines(points, whichImage, F, lines);
        plhs[0] = MxArray(lines);  // {[a,b,c], ...}
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Invalid input");
}
