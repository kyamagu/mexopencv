/**
 * @file findFundamentalMat.cpp
 * @brief mex interface for findFundamentalMat
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

/** Method for option processing
 */
const ConstMap<std::string,int> FMMethod = ConstMap<std::string,int>
    ("7Point",    CV_FM_7POINT)
    ("8Point",    CV_FM_8POINT)
    ("Ransac",    CV_FM_RANSAC)
    ("LMedS",    CV_FM_LMEDS);

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
    int method=FM_RANSAC;
    double param1=3.;
    double param2=0.99;
    for (int i=2; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="Method")
            method = FMMethod[rhs[i+1].toString()];
        else if (key=="Param1")
            param1 = rhs[i+1].toDouble();
        else if (key=="Param2")
            param2 = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Process
    Mat mask, F;
    Mat points1(rhs[0].toMat()), points2(rhs[1].toMat());
    vector<uchar> status(points1.cols*points1.rows,0);
    F = findFundamentalMat(points1, points2, status, method, param1, param2);
    plhs[0] = MxArray(F);
    if (nlhs>1)
        plhs[1] = MxArray(mask);
}
