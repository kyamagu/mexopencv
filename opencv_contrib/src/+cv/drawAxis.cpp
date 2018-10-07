/**
 * @file drawAxis.cpp
 * @brief mex interface for cv::aruco::drawAxis
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
    nargchk(nrhs==6 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    Mat image(rhs[0].toMat()),
        cameraMatrix(rhs[1].toMat(CV_64F)),
        distCoeffs(rhs[2].toMat(CV_64F)),
        rvec(rhs[3].toMat(CV_64F)),
        tvec(rhs[4].toMat(CV_64F));
    float length = rhs[5].toFloat();
    drawAxis(image, cameraMatrix, distCoeffs, rvec, tvec, length);
    plhs[0] = MxArray(image);
}
