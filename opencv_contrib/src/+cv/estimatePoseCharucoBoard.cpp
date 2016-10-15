/**
 * @file estimatePoseCharucoBoard.cpp
 * @brief mex interface for cv::aruco::estimatePoseCharucoBoard
 * @ingroup aruco
 * @author Amro
 * @date 2016
 */
#include "mexopencv.hpp"
#include "mexopencv_aruco.hpp"
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
    nargchk(nrhs==5 && nlhs<=3);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    vector<Point2f> charucoCorners(rhs[0].toVector<Point2f>());
    vector<int> charucoIds(rhs[1].toVector<int>());
    CharucoBoard board;
    {
        vector<MxArray> args(rhs[2].toVector<MxArray>());
        board = create_CharucoBoard(args.begin(), args.end());
    }
    Mat cameraMatrix(rhs[3].toMat(CV_64F)),
        distCoeffs(rhs[4].toMat(CV_64F));
    Vec3d rvec, tvec;
    bool valid = estimatePoseCharucoBoard(charucoCorners, charucoIds, board,
        cameraMatrix, distCoeffs, rvec, tvec);
    plhs[0] = MxArray(rvec);
    if (nlhs > 1)
        plhs[1] = MxArray(tvec);
    if (nlhs > 2)
        plhs[2] = MxArray(valid);
}
