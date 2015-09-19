/**
 * @file stereoRectifyUncalibrated.cpp
 * @brief mex interface for cv::stereoRectifyUncalibrated
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
    nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=3);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    double threshold = 5;
    for (int i=4; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="Threshold")
            threshold = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat F(rhs[2].toMat(CV_64F));
    Size imgSize(rhs[3].toSize());
    Mat H1, H2;
    bool b = false;
    if (rhs[0].isNumeric() && rhs[1].isNumeric()) {
        Mat points1(rhs[0].toMat(CV_64F)),
            points2(rhs[0].toMat(CV_64F));
        if (points1.channels() == 1 && points1.cols == 2)
            points1 = points1.reshape(2,0);
        if (points2.channels() == 1 && points2.cols == 2)
            points2 = points2.reshape(2,0);
        b = stereoRectifyUncalibrated(points1, points2, F, imgSize, H1, H2,
            threshold);
    }
    else if (rhs[0].isCell() && rhs[1].isCell()) {
        vector<Point2d> points1(rhs[0].toVector<Point2d>()),
                        points2(rhs[1].toVector<Point2d>());
        b = stereoRectifyUncalibrated(points1, points2, F, imgSize, H1, H2,
            threshold);
    }
    plhs[0] = MxArray(H1);
    if (nlhs>1)
        plhs[1] = MxArray(H2);
    if (nlhs>2)
        plhs[2] = MxArray(b);
}
