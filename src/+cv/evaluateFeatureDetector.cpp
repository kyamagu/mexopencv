/**
 * @file evaluateFeatureDetector.cpp
 * @brief mex interface for cv::evaluateFeatureDetector
 * @ingroup features2d
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
#include "mexopencv_features2d.hpp"
#include "opencv2/features2d.hpp"
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
    nargchk(nrhs>=5 && (nrhs%2)==1 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    Ptr<FeatureDetector> fdetector;
    for (int i=5; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Detector") {
            if (rhs[i+1].isChar())
                fdetector = createFeatureDetector(
                    rhs[i+1].toString(), rhs.end(), rhs.end());
            else if (rhs[i+1].isCell() && rhs[i+1].numel() >= 1) {
                vector<MxArray> args(rhs[i+1].toVector<MxArray>());
                fdetector = createFeatureDetector(
                    args[0].toString(), args.begin() + 1, args.end());
            }
            else
                mexErrMsgIdAndTxt("mexopencv:error","Invalid arguments");
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat img1(rhs[0].toMat()),
        img2(rhs[1].toMat()),
        H1to2(rhs[2].toMat(CV_64F));
    vector<KeyPoint> keypoints1(rhs[3].toVector<KeyPoint>()),
                     keypoints2(rhs[4].toVector<KeyPoint>());
    float repeatability = -1.0f;
    int correspCount = -1;
    evaluateFeatureDetector(img1, img2, H1to2, &keypoints1, &keypoints2,
        repeatability, correspCount, fdetector);
    plhs[0] = MxArray(repeatability);
    if (nlhs>1)
        plhs[1] = MxArray(correspCount);
}
