/**
 * @file refineDetectedMarkers.cpp
 * @brief mex interface for cv::aruco::refineDetectedMarkers
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
    nargchk(nrhs>=5 && (nrhs%2)==1 && nlhs<=4);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    Mat cameraMatrix, distCoeffs;
    float minRepDistance = 10.0f;
    float errorCorrectionRate = 3.0f;
    bool checkAllOrders = true;
    Ptr<DetectorParameters> params;
    for (int i=5; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "CameraMatrix")
            cameraMatrix = rhs[i+1].toMat(CV_64F);
        else if (key == "DistCoeffs")
            distCoeffs = rhs[i+1].toMat(CV_64F);
        else if (key == "MinRepDistance")
            minRepDistance = rhs[i+1].toFloat();
        else if (key == "ErrorCorrectionRate")
            errorCorrectionRate = rhs[i+1].toFloat();
        else if (key == "CheckAllOrders")
            checkAllOrders = rhs[i+1].toBool();
        else if (key == "DetectorParameters")
            params = MxArrayToDetectorParameters(rhs[i+1]);
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    if (params.empty())
        params = DetectorParameters::create();

    // Process
    Mat image(rhs[0].toMat(CV_8U));
    Ptr<Board> board = MxArrayToBoard(rhs[1]);
    vector<vector<Point2f> > detectedCorners(MxArrayToVectorVectorPoint<float>(rhs[2])),
        rejectedCorners(MxArrayToVectorVectorPoint<float>(rhs[4]));
    vector<int> detectedIds(rhs[3].toVector<int>()),
        recoveredIdxs;
    refineDetectedMarkers(image, board, detectedCorners, detectedIds,
        rejectedCorners, cameraMatrix, distCoeffs, minRepDistance,
        errorCorrectionRate, checkAllOrders,
        (nlhs==4) ? recoveredIdxs : noArray(), params);
    plhs[0] = MxArray(detectedCorners);
    if (nlhs > 1)
        plhs[1] = MxArray(detectedIds);
    if (nlhs > 2)
        plhs[2] = MxArray(rejectedCorners);
    if (nlhs > 3)
        plhs[3] = MxArray(recoveredIdxs);
}
