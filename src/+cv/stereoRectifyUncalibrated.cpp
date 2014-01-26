/**
 * @file stereoRectifyUncalibrated.cpp
 * @brief mex interface for stereoRectifyUncalibrated
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
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    // Check the number of arguments
    if (nrhs<4 || ((nrhs%2)==1) || nlhs>2)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    Mat F(rhs[2].toMat(CV_32F));
    Size imgSize(rhs[3].toSize());
    // Option processing
    double threshold=5;
    for (int i=4; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="Threshold")
            threshold = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Process
    Mat H1, H2;
    if (rhs[0].isNumeric() && rhs[1].isNumeric()) {
        Mat points1(rhs[0].toMat(CV_32F)), points2(rhs[0].toMat(CV_32F));
        stereoRectifyUncalibrated(points1, points2, F, imgSize, H1, H2, threshold);
    }
    else if (rhs[0].isCell() && rhs[1].isCell()) {
        vector<Point2f> points1(rhs[0].toVector<Point2f>());
        vector<Point2f> points2(rhs[1].toVector<Point2f>());
        stereoRectifyUncalibrated(points1, points2, F, imgSize, H1, H2, threshold);
    }
    plhs[0] = MxArray(H1);
    if (nlhs>1)
        plhs[1] = MxArray(H2);
}
