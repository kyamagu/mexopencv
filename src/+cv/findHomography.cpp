/**
 * @file findHomography.cpp
 * @brief mex interface for findHomography
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

/** Methods for option processing
 */
const ConstMap<std::string,int> Method = ConstMap<std::string,int>
    ("0",    0)
    ("Ransac",    CV_RANSAC)
    ("LMedS",    CV_LMEDS);

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
    int method=0;
    double ransacReprojThreshold=3.;
    for (int i=2; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="Method")
            method = Method[rhs[i+1].toString()];
        else if (key=="RansacReprojThreshold")
            ransacReprojThreshold = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Process
    Mat mask, H;
    if (rhs[0].isNumeric() && rhs[1].isNumeric()) {
        Mat points1(rhs[0].toMat()), points2(rhs[1].toMat());
        H = findHomography(points1, points2, method, ransacReprojThreshold, mask);
    }
    else if (rhs[0].isCell() && rhs[1].isCell()) {
        vector<Point2f> points1(rhs[0].toVector<Point2f>());
        vector<Point2f> points2(rhs[1].toVector<Point2f>());
        H = findHomography(points1, points2, method, ransacReprojThreshold, mask);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Invalid argument");
    plhs[0] = MxArray(H);
    if (nlhs>1)
        plhs[1] = MxArray(mask);
}
