/**
 * @file drawMatches.cpp
 * @brief mex interface for drawMatches
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
    if (nrhs<5 || ((nrhs%2)!=1) || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    // Option processing
    Mat img1(rhs[0].toMat());
    vector<KeyPoint> keypoints1(rhs[1].toVector<KeyPoint>());
    Mat img2(rhs[2].toMat());
    vector<KeyPoint> keypoints2(rhs[3].toVector<KeyPoint>());
    vector<DMatch> matches1to2(rhs[4].toVector<DMatch>());
    Scalar matchColor=Scalar::all(-1);
    Scalar singlePointColor=Scalar::all(-1);
    vector<char> matchesMask=vector<char>();
    int flags=DrawMatchesFlags::DEFAULT;
    for (int i=5; i<nrhs; i+=2) {
        string key = rhs[i].toString();
        if (key=="MatchColor")
            matchColor = rhs[i+1].toScalar();
        else if (key=="SinglePointColor")
            singlePointColor = rhs[i+1].toScalar();
        else if (key=="MachesMask") {
            string s(rhs[i+1].toString());
            matchesMask = vector<char>(s.begin(),s.end());
        }
        else if (key=="NotDrawSinglePoints")
            flags |= DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS;
        else if (key=="DrawRichKeypoints")
            flags |= DrawMatchesFlags::DRAW_RICH_KEYPOINTS;
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    
    // Process
    Mat outImg;
    drawMatches(img1,keypoints1,img2,keypoints2,matches1to2,outImg,
        matchColor,singlePointColor,matchesMask,flags);
    plhs[0] = MxArray(outImg);
}
