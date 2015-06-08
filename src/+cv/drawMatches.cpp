/**
 * @file drawMatches.cpp
 * @brief mex interface for drawMatches
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
    if (nrhs<5 || (nrhs%2)!=1 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);

    // Option processing
    Mat outImg;
    Scalar matchColor = Scalar::all(-1);
    Scalar singlePointColor = Scalar::all(-1);
    vector<char> matchesMask;
    int flags = DrawMatchesFlags::DEFAULT;
    for (int i=5; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="MatchColor")
            matchColor = rhs[i+1].toScalar();
        else if (key=="SinglePointColor")
            singlePointColor = rhs[i+1].toScalar();
        else if (key=="MatchesMask")
            rhs[i+1].toMat(CV_8U).reshape(1,1).copyTo(matchesMask);
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
    Mat img1(rhs[0].toMat()),
        img2(rhs[2].toMat());
    vector<KeyPoint> keypoints1(rhs[1].toVector<KeyPoint>()),
                     keypoints2(rhs[3].toVector<KeyPoint>());
    vector<DMatch> matches1to2(rhs[4].toVector<DMatch>());
    drawMatches(img1, keypoints1, img2, keypoints2, matches1to2, outImg,
        matchColor, singlePointColor, matchesMask, flags);
    plhs[0] = MxArray(outImg);
}
