/**
 * @file estimatePoseBoard.cpp
 * @brief mex interface for cv::aruco::estimatePoseBoard
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
    nargchk(nrhs>=5 && (nrhs%2)==1 && nlhs<=3);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    Mat rvec, tvec;
    bool useExtrinsicGuess = false;
    for (int i=5; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "Rvec")
            rvec = rhs[i+1].toMat(CV_64F);
        else if (key == "Tvec")
            tvec = rhs[i+1].toMat(CV_64F);
        else if (key == "UseExtrinsicGuess")
            useExtrinsicGuess = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    if (!rvec.empty() && !tvec.empty())
        useExtrinsicGuess = true;

    // Process
    vector<vector<Point2f> > corners(MxArrayToVectorVectorPoint<float>(rhs[0]));
    vector<int> ids(rhs[1].toVector<int>());
    Ptr<Board> board = MxArrayToBoard(rhs[2]);
    Mat cameraMatrix(rhs[3].toMat(CV_64F)),
        distCoeffs(rhs[4].toMat(CV_64F));
    int num = estimatePoseBoard(corners, ids, board, cameraMatrix, distCoeffs,
        rvec, tvec, useExtrinsicGuess);
    plhs[0] = MxArray(rvec);
    if (nlhs > 1)
        plhs[1] = MxArray(tvec);
    if (nlhs > 2)
        plhs[2] = MxArray(num);
}
