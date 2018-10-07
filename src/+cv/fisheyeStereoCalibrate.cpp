/**
 * @file fisheyeStereoCalibrate.cpp
 * @brief mex interface for cv::fisheye::stereoCalibrate
 * @ingroup calib3d
 * @author Amro
 * @date 2017
 */
#include "mexopencv.hpp"
#include "opencv2/calib3d.hpp"
using namespace std;
using namespace cv;

namespace {
/** Create a new MxArray from stereo calibration results.
 * @param K1 First camera matrix.
 * @param D1 Distortion coefficients of first camera.
 * @param K2 Second camera matrix.
 * @param D2 Distortion coefficients of second camera.
 * @param R Rotation matrix between the cameras coordinate systems.
 * @param T Translation vector between the cameras coordinate systems.
 * @param rms Re-projection error.
 * @return output MxArray struct object.
 */
MxArray toStruct(const Mat& K1, const Mat& D1, const Mat& K2, const Mat& D2,
    const Mat& R, const Mat& T, double rms)
{
    const char* fieldnames[] = {"cameraMatrix1", "distCoeffs1",
        "cameraMatrix2", "distCoeffs2", "R", "T", "reprojErr"};
    MxArray s = MxArray::Struct(fieldnames, 7);
    s.set("cameraMatrix1", K1);
    s.set("distCoeffs1",   D1);
    s.set("cameraMatrix2", K2);
    s.set("distCoeffs2",   D2);
    s.set("R",             R);
    s.set("T",             T);
    s.set("reprojErr",     rms);
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
    nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    Mat K1, D1, K2, D2;
    int flags = cv::CALIB_FIX_INTRINSIC;
    TermCriteria criteria(TermCriteria::COUNT+TermCriteria::EPS, 100, DBL_EPSILON);
    for (int i=4; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "CameraMatrix1")
            K1 = rhs[i+1].toMat(CV_64F);
        else if (key == "DistCoeffs1")
            D1 = rhs[i+1].toMat(CV_64F);
        else if (key == "CameraMatrix2")
            K2 = rhs[i+1].toMat(CV_64F);
        else if (key == "DistCoeffs2")
            D2 = rhs[i+1].toMat(CV_64F);
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
        else if (key == "FixIntrinsic")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::fisheye::CALIB_FIX_INTRINSIC);
        else if (key == "Criteria")
            criteria = rhs[i+1].toTermCriteria();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    vector<vector<Point3d> > objectPoints(MxArrayToVectorVectorPoint3<double>(rhs[0]));
    vector<vector<Point2d> > imagePoints1(MxArrayToVectorVectorPoint<double>(rhs[1]));
    vector<vector<Point2d> > imagePoints2(MxArrayToVectorVectorPoint<double>(rhs[2]));
    Size imageSize(rhs[3].toSize());
    Mat R, T;
    double rms = fisheye::stereoCalibrate(objectPoints, imagePoints1, imagePoints2,
        K1, D1, K2, D2, imageSize, R, T, flags, criteria);
    plhs[0] = toStruct(K1, D1, K2, D2, R, T, rms);
}
