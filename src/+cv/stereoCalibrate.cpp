/**
 * @file stereoCalibrate.cpp
 * @brief mex interface for cv::stereoCalibrate
 * @ingroup calib3d
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/** Create a new MxArray from stereo calibration results.
 * @param cameraMatrix1 First camera matrix.
 * @param distCoeffs1 Distortion coefficients of first camera.
 * @param cameraMatrix2 Second camera matrix.
 * @param distCoeffs2 Distortion coefficients of second camera.
 * @param R Rotation matrix between the cameras coordinate systems.
 * @param T Translation vector between the cameras coordinate systems.
 * @param E Essential matrix.
 * @param F Fundamental matrix.
 * @param reprojErr Re-projection error.
 * @return output MxArray struct object.
 */
MxArray toStruct(const Mat& cameraMatrix1, const Mat& distCoeffs1,
    const Mat& cameraMatrix2, const Mat& distCoeffs2, const Mat& R,
    const Mat& T, const Mat& E, const Mat& F, double reprojErr)
{
    const char* fieldnames[] = {"cameraMatrix1", "distCoeffs1",
        "cameraMatrix2", "distCoeffs2", "R", "T", "E", "F", "reprojErr"};
    MxArray s = MxArray::Struct(fieldnames, 9);
    s.set("cameraMatrix1", cameraMatrix1);
    s.set("distCoeffs1",   distCoeffs1);
    s.set("cameraMatrix2", cameraMatrix2);
    s.set("distCoeffs2",   distCoeffs2);
    s.set("R",             R);
    s.set("T",             T);
    s.set("E",             E);
    s.set("F",             F);
    s.set("reprojErr",     reprojErr);
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
    Mat cameraMatrix1, distCoeffs1,
        cameraMatrix2, distCoeffs2;
    int flags = cv::CALIB_FIX_INTRINSIC;
    TermCriteria criteria(TermCriteria::COUNT+TermCriteria::EPS, 30, 1e-6);
    for (int i=4; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "CameraMatrix1")
            cameraMatrix1 = rhs[i+1].toMat(CV_64F);
        else if (key == "DistCoeffs1")
            distCoeffs1 = rhs[i+1].toMat(CV_64F);
        else if (key == "CameraMatrix2")
            cameraMatrix2 = rhs[i+1].toMat(CV_64F);
        else if (key == "DistCoeffs2")
            distCoeffs2 = rhs[i+1].toMat(CV_64F);
        else if (key == "FixIntrinsic")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_FIX_INTRINSIC);
        else if (key == "UseIntrinsicGuess")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_USE_INTRINSIC_GUESS);
        else if (key == "FixPrincipalPoint")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_FIX_PRINCIPAL_POINT);
        else if (key == "FixFocalLength")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_FIX_FOCAL_LENGTH);
        else if (key == "FixAspectRatio")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_FIX_ASPECT_RATIO);
        else if (key == "SameFocalLength")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_SAME_FOCAL_LENGTH);
        else if (key == "ZeroTangentDist")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_ZERO_TANGENT_DIST);
        else if (key == "FixK1")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_FIX_K1);
        else if (key == "FixK2")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_FIX_K2);
        else if (key == "FixK3")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_FIX_K3);
        else if (key == "FixK4")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_FIX_K4);
        else if (key == "FixK5")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_FIX_K5);
        else if (key == "FixK6")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_FIX_K6);
        else if (key == "RationalModel")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_RATIONAL_MODEL);
        else if (key == "ThinPrismModel")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_THIN_PRISM_MODEL);
        else if (key == "FixS1S2S3S4")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_FIX_S1_S2_S3_S4);
        else if (key == "Criteria")
            criteria = rhs[i+1].toTermCriteria();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s",key.c_str());
    }

    // Process
    vector<vector<Point3f> > objectPoints(MxArrayToVectorVectorPoint3<float>(rhs[0]));
    vector<vector<Point2f> > imagePoints1(MxArrayToVectorVectorPoint<float>(rhs[1]));
    vector<vector<Point2f> > imagePoints2(MxArrayToVectorVectorPoint<float>(rhs[2]));
    Size imageSize(rhs[3].toSize());
    Mat R, T, E, F;
    double reprojErr = stereoCalibrate(objectPoints, imagePoints1, imagePoints2,
        cameraMatrix1, distCoeffs1, cameraMatrix2, distCoeffs2, imageSize,
        R, T, E, F, flags, criteria);
    plhs[0] = toStruct(cameraMatrix1, distCoeffs1, cameraMatrix2, distCoeffs2,
        R, T, E, F, reprojErr);
}
