/**
 * @file matchGMS.cpp
 * @brief mex interface for cv::xfeatures2d::matchGMS
 * @ingroup xfeatures2d
 * @author Amro
 * @date 2018
 */
#include "mexopencv.hpp"
#include "opencv2/xfeatures2d.hpp"
using namespace std;
using namespace cv;
using namespace cv::xfeatures2d;

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
    nargchk(nrhs>=5 && (nrhs%2)==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    bool withRotation = false;
    bool withScale = false;
    double thresholdFactor = 6.0;
    for (int i=5; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "WithRotation")
            withRotation = rhs[i+1].toBool();
        else if (key == "WithScale")
            withScale = rhs[i+1].toBool();
        else if (key == "ThresholdFactor")
            thresholdFactor = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Size size1(rhs[0].toSize()),
         size2(rhs[2].toSize());
    vector<KeyPoint> keypoints1(rhs[1].toVector<KeyPoint>()),
                     keypoints2(rhs[3].toVector<KeyPoint>());
    vector<DMatch> matches1to2(rhs[4].toVector<DMatch>()),
                   matchesGMS;
    matchGMS(size1, size2, keypoints1, keypoints2, matches1to2, matchesGMS,
        withRotation, withScale, thresholdFactor);
    plhs[0] = MxArray(matchesGMS);
}
