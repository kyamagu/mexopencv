/**
 * @file drawPlanarBoard.cpp
 * @brief mex interface for cv::aruco::drawPlanarBoard
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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int marginSize = 0;
    int borderBits = 1;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "MarginSize")
            marginSize = rhs[i+1].toInt();
        else if (key == "BorderBits")
            borderBits = rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Ptr<Board> board = MxArrayToBoard(rhs[0]);
    Size outSize(rhs[1].toSize());
    Mat img;
    drawPlanarBoard(board, outSize, img, marginSize, borderBits);
    plhs[0] = MxArray(img);
}
