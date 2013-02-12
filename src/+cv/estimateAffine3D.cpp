/**
 * @file estimateAffine3D.cpp
 * @brief mex interface for estimateAffine3D
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
    if (nrhs<2 || ((nrhs%2)!=0) || nlhs>2)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    double ransacThreshold=3.0;
    double confidence=0.99;
    for (int i=2; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="RansacThreshold")
            ransacThreshold = rhs[i+1].toDouble();
        else if (key=="Confidence")
            confidence = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Process
    Mat out, inliers;
    if (rhs[0].isNumeric() && rhs[1].isNumeric()) {
        Mat srcpt(rhs[0].toMat()), dstpt(rhs[1].toMat());
        estimateAffine3D(srcpt, dstpt, out, inliers, ransacThreshold, confidence);
    }
    else if (rhs[0].isCell() && rhs[1].isCell()) {        
        vector<Point3f> srcpt(rhs[0].toVector<Point3f>());
        vector<Point3f> dstpt(rhs[1].toVector<Point3f>());
        estimateAffine3D(srcpt, dstpt, out, inliers, ransacThreshold, confidence);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Invalid argument");
    plhs[0] = MxArray(out);
    if (nlhs>1)
        plhs[1] = MxArray(inliers);
}
