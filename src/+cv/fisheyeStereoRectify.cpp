/**
 * @file fisheyeStereoRectify.cpp
 * @brief mex interface for cv::fisheye::stereoRectify
 * @ingroup calib3d
 * @author Amro
 * @date 2017
 */
#include "mexopencv.hpp"
#include "opencv2/calib3d.hpp"
using namespace std;
using namespace cv;

namespace {
/** Create a new MxArray from stereo rectified transforms.
 * @param R1 Rectification transform for the first camera.
 * @param R2 Rectification transform for the second camera.
 * @param P1 Projection matrix in new coord systems of first camera.
 * @param P2 Projection matrix in new coord systems of second camera.
 * @param Q Disparity-to-depth mapping matrix.
 * @return output MxArray struct object.
 */
MxArray toStruct(const Mat& R1, const Mat& R2, const Mat& P1, const Mat& P2,
    const Mat& Q)
{
    const char* fieldnames[] = {"R1", "R2", "P1", "P2", "Q"};
    MxArray s = MxArray::Struct(fieldnames, 5);
    s.set("R1", R1);
    s.set("R2", R2);
    s.set("P1", P1);
    s.set("P2", P2);
    s.set("Q",  Q);
    return s;
}
}

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
    nargchk(nrhs>=7 && (nrhs%2)==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int flags = cv::CALIB_ZERO_DISPARITY;
    Size newImageSize;
    double balance = 0.0;
    double fov_scale = 1.0;
    for (int i=7; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "ZeroDisparity")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_ZERO_DISPARITY);
        else if (key == "NewImageSize")
            newImageSize = rhs[i+1].toSize();
        else if (key == "Balance")
            balance = rhs[i+1].toDouble();
        else if (key == "FOVScale")
            fov_scale = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat K1(rhs[0].toMat(CV_64F)),
        D1(rhs[1].toMat(CV_64F)),
        K2(rhs[2].toMat(CV_64F)),
        D2(rhs[3].toMat(CV_64F)),
        R(rhs[5].toMat(CV_64F)),
        T(rhs[6].toMat(CV_64F)),
        R1, R2, P1, P2, Q;
    Size imageSize(rhs[4].toSize());
    fisheye::stereoRectify(K1, D1, K2, D2, imageSize, R, T, R1, R2, P1, P2, Q,
        flags, newImageSize, balance, fov_scale);
    plhs[0] = toStruct(R1, R2, P1, P2, Q);
}
