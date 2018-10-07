/**
 * @file drawDetectedMarkers.cpp
 * @brief mex interface for cv::aruco::drawDetectedMarkers
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
    vector<int> ids;
    Scalar borderColor(0, 255, 0);
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "IDs")
            ids = rhs[i+1].toVector<int>();
        else if (key == "BorderColor")
            borderColor = (rhs[i+1].isChar()) ?
                ColorType[rhs[i+1].toString()] : rhs[i+1].toScalar();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat image(rhs[0].toMat());
    vector<vector<Point2f> > corners(MxArrayToVectorVectorPoint<float>(rhs[1]));
    drawDetectedMarkers(image, corners,
        (!ids.empty()) ? ids : noArray(), borderColor);
    plhs[0] = MxArray(image);
}
