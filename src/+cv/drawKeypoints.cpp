/**
 * @file drawKeypoints.cpp
 * @brief mex interface for drawKeypoints
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

/// set or clear a bit in flag depending on bool value
#define UPDATE_FLAG(NUM, TF, BIT)       \
    do {                                \
        if ((TF)) { (NUM) |=  (BIT); }  \
        else      { (NUM) &= ~(BIT); }  \
    } while(0)

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
    if (nrhs<2 || (nrhs%2)!=0 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);

    // Option processing
    Mat outImg;
    Scalar color = Scalar::all(-1);
    int flags = DrawMatchesFlags::DEFAULT;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="Color")
            color = rhs[i+1].toScalar();
        else if (key=="NotDrawSinglePoints")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS);
        else if (key=="DrawRichKeypoints")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), DrawMatchesFlags::DRAW_RICH_KEYPOINTS);
        else if (key=="OutImage") {
            outImg = rhs[i+1].toMat();
            flags |= DrawMatchesFlags::DRAW_OVER_OUTIMG;
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat image(rhs[0].toMat());
    vector<KeyPoint> keypoints(rhs[1].toVector<KeyPoint>());
    drawKeypoints(image, keypoints, outImg, color, flags);
    plhs[0] = MxArray(outImg);
}
