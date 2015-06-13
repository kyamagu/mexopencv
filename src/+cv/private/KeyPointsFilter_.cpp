/**
 * @file KeyPointsFilter_.cpp
 * @brief mex interface for KeyPointsFilter
 * @author Amro
 * @date 2015
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
    nargchk(nrhs>=2 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    string method(rhs[0].toString());
    vector<KeyPoint> keypoints(rhs[1].toVector<KeyPoint>());

    // Operation switch
    if (method == "removeDuplicated") {
        nargchk(nrhs==2 && nlhs<=1);
        KeyPointsFilter::removeDuplicated(keypoints);
    }
    else if (method == "retainBest") {
        nargchk(nrhs==3 && nlhs<=1);
        int npoints = rhs[2].toInt();
        KeyPointsFilter::retainBest(keypoints, npoints);
    }
    else if (method == "runByImageBorder") {
        nargchk(nrhs==4 && nlhs<=1);
        Size imageSize(rhs[2].toSize());
        int borderSize = rhs[3].toInt();
        KeyPointsFilter::runByImageBorder(keypoints, imageSize, borderSize);
    }
    else if (method == "runByKeypointSize") {
        nargchk((nrhs==3 || nrhs==4) && nlhs<=1);
        float minSize = rhs[2].toFloat();
        float maxSize = (nrhs==4) ? rhs[3].toFloat() : FLT_MAX;
        KeyPointsFilter::runByKeypointSize(keypoints, minSize, maxSize);
    }
    else if (method == "runByPixelsMask") {
        nargchk(nrhs==3 && nlhs<=1);
        Mat mask(rhs[2].toMat(CV_8U));
        KeyPointsFilter::runByPixelsMask(keypoints, mask);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());

    plhs[0] = MxArray(keypoints);
}
