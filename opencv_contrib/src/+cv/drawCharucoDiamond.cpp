/**
 * @file drawCharucoDiamond.cpp
 * @brief mex interface for cv::aruco::drawCharucoDiamond
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
    nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int marginSize = 0;
    int borderBits = 1;
    for (int i=4; i<nrhs; i+=2) {
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
    Ptr<Dictionary> dictionary = MxArrayToDictionary(rhs[0]);
    Vec4i ids(rhs[1].toVec<int,4>());
    int squareLength = rhs[2].toInt(),
        markerLength = rhs[3].toInt();
    Mat img;
    drawCharucoDiamond(dictionary, ids, squareLength, markerLength, img,
        marginSize, borderBits);
    plhs[0] = MxArray(img);
}
