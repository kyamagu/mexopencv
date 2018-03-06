/**
 * @file getBoardObjectAndImagePoints.cpp
 * @brief mex interface for cv::aruco::getBoardObjectAndImagePoints
 * @ingroup aruco
 * @author Amro
 * @date 2017
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
    nargchk(nrhs==3 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs + nrhs);

    // Process
    Ptr<Board> board = MxArrayToBoard(rhs[0]);
    vector<vector<Point2f> > corners(MxArrayToVectorVectorPoint<float>(rhs[1]));
    vector<int> ids(rhs[2].toVector<int>());
    vector<Point3f> objPoints;
    vector<Point2f> imgPoints;
    getBoardObjectAndImagePoints(board, corners, ids, objPoints, imgPoints);
    plhs[0] = MxArray(objPoints);
    if (nlhs > 1)
        plhs[1] = MxArray(imgPoints);
}
