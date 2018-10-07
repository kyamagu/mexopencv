/**
 * @file detectMarkers.cpp
 * @brief mex interface for cv::aruco::detectMarkers
 * @ingroup aruco
 * @author Amro
 * @date 2016
 */
#include "mexopencv.hpp"
#include "mexopencv_aruco.hpp"
#include "opencv2/aruco.hpp"
using namespace std;
using namespace cv;
using namespace cv::aruco;

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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=3);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    Ptr<DetectorParameters> params;
    Mat cameraMatrix, distCoeffs;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "DetectorParameters")
            params = MxArrayToDetectorParameters(rhs[i+1]);
        else if (key == "CameraMatrix")
            cameraMatrix = rhs[i+1].toMat(CV_64F);
        else if (key == "DistCoeffs")
            distCoeffs = rhs[i+1].toMat(CV_64F);
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    if (params.empty())
        params = DetectorParameters::create();

    // Process
    Mat image(rhs[0].toMat(CV_8U));
    Ptr<Dictionary> dictionary = MxArrayToDictionary(rhs[1]);
    vector<vector<Point2f> > corners, rejectedImgPoints;
    vector<int> ids;
    detectMarkers(image, dictionary, corners, ids, params,
        (nlhs==3) ? rejectedImgPoints : noArray(), cameraMatrix, distCoeffs);
    plhs[0] = MxArray(corners);
    if (nlhs > 1)
        plhs[1] = MxArray(ids);
    if (nlhs > 2)
        plhs[2] = MxArray(rejectedImgPoints);
}
