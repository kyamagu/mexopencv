/**
 * @file boardDump.cpp
 * @brief mex interface for cv::aruco::Board
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
    nargchk(nrhs==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    if (rhs[0].isStruct()) {
        Ptr<Board> board = MxArrayToBoard(rhs[0]);
        plhs[0] = toStruct(board);
    }
    else {
        vector<MxArray> args(rhs[0].toVector<MxArray>());
        nargchk(args.size() >= 1);
        string type(args[0].toString());
        if (type == "Board") {
            Ptr<Board> board = create_Board(args.begin() + 1, args.end());
            plhs[0] = toStruct(board);
        }
        else if (type == "GridBoard") {
            Ptr<GridBoard> board = create_GridBoard(
                args.begin() + 1, args.end());
            plhs[0] = toStruct(board);
        }
        else if (type == "CharucoBoard") {
            Ptr<CharucoBoard> board = create_CharucoBoard(
                args.begin() + 1, args.end());
            plhs[0] = toStruct(board);
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized board type %s", type.c_str());
    }
}
