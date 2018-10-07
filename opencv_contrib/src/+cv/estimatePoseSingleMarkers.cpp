/**
 * @file estimatePoseSingleMarkers.cpp
 * @brief mex interface for cv::aruco::estimatePoseSingleMarkers
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
    nargchk(nrhs==4 && nlhs<=3);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    vector<vector<Point2f> > corners(MxArrayToVectorVectorPoint<float>(rhs[0]));
    float markerLength = rhs[1].toFloat();
    Mat cameraMatrix(rhs[2].toMat(CV_64F)),
        distCoeffs(rhs[3].toMat(CV_64F));
    vector<Vec3d> rvecs, tvecs;
    vector<Point3f> objPoints;
    estimatePoseSingleMarkers(corners, markerLength, cameraMatrix, distCoeffs,
        rvecs, tvecs, (nlhs > 2) ? objPoints : noArray());
    plhs[0] = MxArray(rvecs);
    if (nlhs > 1)
        plhs[1] = MxArray(tvecs);
    if (nlhs > 2)
        plhs[2] = MxArray(objPoints);
}
