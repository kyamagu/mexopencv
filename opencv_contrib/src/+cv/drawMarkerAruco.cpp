/**
 * @file drawMarkerAruco.cpp
 * @brief mex interface for cv::aruco::drawMarker
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

//HACK: renamed to drawMarkerAruco to avoid name conflict with imgproc function

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
    nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int borderBits = 1;
    for (int i=3; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "BorderBits")
            borderBits = rhs[i+1].toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Ptr<Dictionary> dictionary = MxArrayToDictionary(rhs[0]);
    int id = rhs[1].toInt(),
        sidePixels = rhs[2].toInt();
    Mat img;
    drawMarker(dictionary, id, sidePixels, img, borderBits);
    plhs[0] = MxArray(img);
}
