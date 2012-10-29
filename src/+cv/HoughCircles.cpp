/**
 * @file HoughCircles.cpp
 * @brief mex interface for HoughCircles
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
    if (nrhs<1 || ((nrhs%2)!=1) || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    Mat image(rhs[0].toMat(CV_8U));
    vector<Vec3f> circles;
    int method=CV_HOUGH_GRADIENT;
    double dp=1;
    double minDist=image.rows/8;
    double param1=100;
    double param2=100;
    int minRadius=0;
    int maxRadius=0;
    for (int i=1; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="Method")
            method = rhs[i+1].toInt();
        else if (key=="DP")
            dp = rhs[i+1].toDouble();
        else if (key=="MinDist")
            minDist = rhs[i+1].toDouble();
        else if (key=="Param1")
            param1 = rhs[i+1].toDouble();
        else if (key=="Param2")
            param2 = rhs[i+1].toDouble();
        else if (key=="MinRadius")
            minRadius = rhs[i+1].toInt();
        else if (key=="MaxRadius")
            maxRadius = rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Process
    HoughCircles(image, circles, method, dp, minDist, param1, param2, minRadius, maxRadius);
    vector<Mat> vc(circles.size());
    for (int i=0;i<vc.size();++i)
        vc[i] = Mat(1,3,CV_32FC1,&circles[i][0]);
    plhs[0] = MxArray(vc);
}
