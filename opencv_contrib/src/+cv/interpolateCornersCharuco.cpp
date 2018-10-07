/**
 * @file interpolateCornersCharuco.cpp
 * @brief mex interface for cv::aruco::interpolateCornersCharuco
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
    nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=3);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    Mat cameraMatrix, distCoeffs;
    int minMarkers = 2;
    for (int i=4; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "CameraMatrix")
            cameraMatrix = rhs[i+1].toMat(CV_64F);
        else if (key == "DistCoeffs")
            distCoeffs = rhs[i+1].toMat(CV_64F);
        else if (key == "MinMarkers")
            minMarkers = rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    vector<vector<Point2f> > markerCorners(MxArrayToVectorVectorPoint<float>(rhs[0]));
    vector<int> markerIds(rhs[1].toVector<int>());
    Mat image(rhs[2].toMat(CV_8U));
    Ptr<CharucoBoard> board;
    {
        vector<MxArray> args(rhs[3].toVector<MxArray>());
        board = create_CharucoBoard(args.begin(), args.end());
    }
    vector<Point2f> charucoCorners;
    vector<int> charucoIds;
    int num = interpolateCornersCharuco(markerCorners, markerIds, image,
        board, charucoCorners, charucoIds,
        (!cameraMatrix.empty()) ? cameraMatrix : noArray(),
        (!distCoeffs.empty()) ? distCoeffs : noArray(), minMarkers);
    plhs[0] = MxArray(charucoCorners);
    if (nlhs > 1)
        plhs[1] = MxArray(charucoIds);
    if (nlhs > 2)
        plhs[2] = MxArray(num);
}
