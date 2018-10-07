/**
 * @file calibrateCamera.cpp
 * @brief mex interface for cv::calibrateCamera
 * @ingroup calib3d
 * @author Kota Yamaguchi
 * @date 2011
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
    nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=8);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    Mat cameraMatrix, distCoeffs;
    int flags = 0;
    TermCriteria criteria(TermCriteria::COUNT+TermCriteria::EPS, 30, DBL_EPSILON);
    for (int i=3; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "CameraMatrix")
            cameraMatrix = rhs[i+1].toMat(CV_64F);
        else if (key == "DistCoeffs")
            distCoeffs = rhs[i+1].toMat(CV_64F);
        else if (key == "UseIntrinsicGuess")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_USE_INTRINSIC_GUESS);
        else if (key == "FixPrincipalPoint")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_FIX_PRINCIPAL_POINT);
        else if (key == "FixFocalLength")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_FIX_FOCAL_LENGTH);
        else if (key == "FixAspectRatio")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_FIX_ASPECT_RATIO);
        else if (key == "ZeroTangentDist")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_ZERO_TANGENT_DIST);
        else if (key == "FixTangentDist")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_FIX_TANGENT_DIST);
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
        else if (key == "TiltedModel")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_TILTED_MODEL);
        else if (key == "FixTauXTauY")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_FIX_TAUX_TAUY);
        else if (key == "UseLU")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_USE_LU);
        else if (key == "UseQR")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_USE_QR);
        else if (key == "Criteria")
            criteria = rhs[i+1].toTermCriteria();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    vector<vector<Point3f> > objectPoints(MxArrayToVectorVectorPoint3<float>(rhs[0]));
    vector<vector<Point2f> > imagePoints(MxArrayToVectorVectorPoint<float>(rhs[1]));
    Size imageSize(rhs[2].toSize());
    vector<Mat> rvecs, tvecs;
    Mat stdDeviationsIntrinsics, stdDeviationsExtrinsics, perViewErrors;
    double reprojErr = calibrateCamera(
        objectPoints, imagePoints, imageSize, cameraMatrix, distCoeffs,
        (nlhs>3 ? rvecs : noArray()),
        (nlhs>4 ? tvecs : noArray()),
        (nlhs>5 ? stdDeviationsIntrinsics : noArray()),
        (nlhs>6 ? stdDeviationsExtrinsics : noArray()),
        (nlhs>7 ? perViewErrors : noArray()),
        flags, criteria);
    plhs[0] = MxArray(cameraMatrix);
    if (nlhs > 1)
        plhs[1] = MxArray(distCoeffs);
    if (nlhs > 2)
        plhs[2] = MxArray(reprojErr);
    if (nlhs > 3)
        plhs[3] = MxArray(rvecs);
    if (nlhs > 4)
        plhs[4] = MxArray(tvecs);
    if (nlhs > 5)
        plhs[5] = MxArray(stdDeviationsIntrinsics);
    if (nlhs > 6)
        plhs[6] = MxArray(stdDeviationsExtrinsics);
    if (nlhs > 7)
        plhs[7] = MxArray(perViewErrors);
}
