/**
 * @file calibrateCameraCharuco.cpp
 * @brief mex interface for cv::aruco::calibrateCameraCharuco
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
    nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=8);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    Mat cameraMatrix, distCoeffs;
    int flags = 0;
    TermCriteria criteria(TermCriteria::COUNT+TermCriteria::EPS, 30, DBL_EPSILON);
    for (int i=4; i<nrhs; i+=2) {
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
    vector<vector<Point2f> > charucoCorners(MxArrayToVectorVectorPoint<float>(rhs[0]));
    vector<vector<int> > charucoIds(MxArrayToVectorVectorPrimitive<int>(rhs[1]));
    Ptr<CharucoBoard> board;
    {
        vector<MxArray> args(rhs[2].toVector<MxArray>());
        board = create_CharucoBoard(args.begin(), args.end());
    }
    Size imageSize(rhs[3].toSize());
    vector<Vec3d> rvecs, tvecs;
    Mat stdDeviationsIntrinsics, stdDeviationsExtrinsics, perViewErrors;
    double reprojErr = calibrateCameraCharuco(charucoCorners, charucoIds,
        board, imageSize, cameraMatrix, distCoeffs,
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
