/**
 * @file drawKeypoints.cpp
 * @brief mex interface for cv::drawKeypoints
 * @ingroup features2d
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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    Mat outImg;
    Scalar color(Scalar::all(-1));
    int flags = DrawMatchesFlags::DEFAULT;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="Color")
            color = rhs[i+1].toScalar();
        else if (key=="DrawRichKeypoints")
            UPDATE_FLAG(flags, rhs[i+1].toBool(),
                DrawMatchesFlags::DRAW_RICH_KEYPOINTS);
        else if (key=="OutImage") {
            outImg = rhs[i+1].toMat(CV_8U);
            flags |= DrawMatchesFlags::DRAW_OVER_OUTIMG;
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat image(rhs[0].toMat(CV_8U));
    vector<KeyPoint> keypoints(rhs[1].toVector<KeyPoint>());
    drawKeypoints(image, keypoints, outImg, color, flags);
    plhs[0] = MxArray(outImg);
}
