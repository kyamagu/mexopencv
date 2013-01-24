/**
 * @file stereoRectify.cpp
 * @brief mex interface for stereoRectify
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

/// Field names for struct
const char* _fieldnames[] = {"R1", "R2", "P1", "P2", "Q", "roi1", "roi2"};
/// Create a struct
mxArray* valueStruct(const Mat& R1, const Mat& R2, const Mat& P1, const Mat& P2,
    const Mat& Q, const Rect& roi1, const Rect& roi2)
{
    MxArray s = MxArray::Struct(_fieldnames,7);
    s.set("R1",R1);
    s.set("R2",R2);
    s.set("P1",P1);
    s.set("P2",P2);
    s.set("Q",Q);
    s.set("roi1",roi1);
    s.set("roi2",roi2);
    return s;
}

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
    if (nrhs<7 || ((nrhs%2)!=1) || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    Mat cameraMatrix1(rhs[0].toMat()), distCoeffs1(rhs[1].toMat());
    Mat cameraMatrix2(rhs[2].toMat()), distCoeffs2(rhs[3].toMat());
    Size imageSize(rhs[4].toSize());
    Mat R(rhs[5].toMat()), T(rhs[6].toMat());
    double alpha=-1;
    Size newImageSize(0,0);
    bool zeroDisparity=false;
    // Option processing
    for (int i=7; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="Alpha")
            alpha = rhs[i+1].toDouble();
        else if (key=="NewImageSize")
            newImageSize = rhs[i+1].toSize();
        else if (key=="ZeroDisparity")
            zeroDisparity = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    int flags = ((zeroDisparity) ? CV_CALIB_ZERO_DISPARITY : 0);
    
    // Process
    Mat R1, R2, P1, P2, Q;
    Rect roi1, roi2;
    stereoRectify(cameraMatrix1, distCoeffs1, cameraMatrix2, distCoeffs2,
        imageSize, R, T, R1, R2, P1, P2, Q, flags, alpha, newImageSize,
        &roi1, &roi2);
    plhs[0] = valueStruct(R1, R2, P1, P2, Q, roi1, roi2);
}
