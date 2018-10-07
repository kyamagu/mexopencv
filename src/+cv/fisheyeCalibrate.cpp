/**
 * @file fisheyeCalibrate.cpp
 * @brief mex interface for cv::fisheye::calibrate
 * @ingroup calib3d
 * @author Amro
 * @date 2017
 */
#include "mexopencv.hpp"
#include "opencv2/calib3d.hpp"
using namespace std;
using namespace cv;

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
    nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=5);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    Mat K, D;
    int flags = 0;
    TermCriteria criteria(TermCriteria::COUNT+TermCriteria::EPS, 100, DBL_EPSILON);
    for (int i=3; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "CameraMatrix")
            K = rhs[i+1].toMat(CV_64F);
        else if (key == "DistCoeffs")
            D = rhs[i+1].toMat(CV_64F);
        else if (key == "UseIntrinsicGuess")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::fisheye::CALIB_USE_INTRINSIC_GUESS);
        else if (key == "RecomputeExtrinsic")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::fisheye::CALIB_RECOMPUTE_EXTRINSIC);
        else if (key == "CheckCond")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::fisheye::CALIB_CHECK_COND);
        else if (key == "FixSkew")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::fisheye::CALIB_FIX_SKEW);
        else if (key == "FixK1")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::fisheye::CALIB_FIX_K1);
        else if (key == "FixK2")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::fisheye::CALIB_FIX_K2);
        else if (key == "FixK3")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::fisheye::CALIB_FIX_K3);
        else if (key == "FixK4")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::fisheye::CALIB_FIX_K4);
        else if (key == "FixPrincipalPoint")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::fisheye::CALIB_FIX_PRINCIPAL_POINT);
        else if (key == "Criteria")
            criteria = rhs[i+1].toTermCriteria();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    vector<vector<Point3d> > objectPoints(MxArrayToVectorVectorPoint3<double>(rhs[0]));
    vector<vector<Point2d> > imagePoints(MxArrayToVectorVectorPoint<double>(rhs[1]));
    Size imageSize(rhs[2].toSize());
    vector<Mat> rvecs, tvecs;
    double rms = fisheye::calibrate(
        objectPoints, imagePoints, imageSize, K, D,
        (nlhs>3 ? rvecs : noArray()),
        (nlhs>4 ? tvecs : noArray()),
        flags, criteria);
    plhs[0] = MxArray(K);
    if (nlhs > 1)
        plhs[1] = MxArray(D);
    if (nlhs > 2)
        plhs[2] = MxArray(rms);
    if (nlhs > 3)
        plhs[3] = MxArray(rvecs);
    if (nlhs > 4)
        plhs[4] = MxArray(tvecs);
}
