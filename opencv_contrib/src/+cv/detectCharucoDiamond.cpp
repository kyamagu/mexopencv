/**
 * @file detectCharucoDiamond.cpp
 * @brief mex interface for cv::aruco::detectCharucoDiamond
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
    nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    Mat cameraMatrix, distCoeffs;
    for (int i=4; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "CameraMatrix")
            cameraMatrix = rhs[i+1].toMat(CV_64F);
        else if (key == "DistCoeffs")
            distCoeffs = rhs[i+1].toMat(CV_64F);
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat image(rhs[0].toMat(CV_8U));
    vector<vector<Point2f> > markerCorners(MxArrayToVectorVectorPoint<float>(rhs[1]));
    vector<int> markerIds(rhs[2].toVector<int>());
    float squareMarkerLengthRate = rhs[3].toFloat();
    vector<vector<Point2f> > diamondCorners;
    vector<Vec4i> diamondIds;
    detectCharucoDiamond(image, markerCorners, markerIds, squareMarkerLengthRate,
        diamondCorners, diamondIds,
        (!cameraMatrix.empty()) ? cameraMatrix : noArray(),
        (!distCoeffs.empty()) ? distCoeffs : noArray());
    plhs[0] = MxArray(diamondCorners);
    if (nlhs > 1)
        plhs[1] = MxArray(diamondIds);
}
