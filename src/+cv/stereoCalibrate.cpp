/**
 * @file stereoCalibrate.cpp
 * @brief mex interface for stereoCalibrate
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
 * @param d Re-projection error.
 * @return output MxArray struct object.
 */
MxArray valueStruct(const Mat& cameraMatrix1, const Mat& distCoeffs1,
    const Mat& cameraMatrix2, const Mat& distCoeffs2, const Mat& R,
    const Mat& T, const Mat& E, const Mat& F, double d)
{
    const char* fieldnames[] = {"cameraMatrix1", "distCoeffs1",
        "cameraMatrix2", "distCoeffs2", "R", "T", "E", "F", "d"};
    MxArray s = MxArray::Struct(fieldnames, 9);
    s.set("cameraMatrix1", cameraMatrix1);
    s.set("distCoeffs1",   distCoeffs1);
    s.set("cameraMatrix2", cameraMatrix2);
    s.set("distCoeffs2",   distCoeffs2);
    s.set("R", R);
    s.set("T", T);
    s.set("E", E);
    s.set("F", F);
    s.set("d", d);
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
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
    // Check the number of arguments
    if (nrhs<4 || ((nrhs%2)!=0) || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);

    // Option processing
    Mat cameraMatrix1(Mat::eye(3,3,CV_32FC1)), distCoeffs1;
    Mat cameraMatrix2(Mat::eye(3,3,CV_32FC1)), distCoeffs2;
    TermCriteria termCrit(TermCriteria::COUNT+TermCriteria::EPS, 30, 1e-6);
    bool fixIntrinsic = true;
    bool useIntrinsicGuess = false;
    bool fixPrincipalPoint = false;
    bool fixFocalLength = false;
    bool fixAspectRatio = false;
    bool sameFocalLength = false;
    bool zeroTangentDist = false;
    bool calibRationalModel = false;
    bool fixK1 = false, fixK2 = false, fixK3 = false,
         fixK4 = false, fixK5 = false, fixK6 = false;
    for (int i=4; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="CameraMatrix1")
            cameraMatrix1 = rhs[i+1].toMat(CV_32F);
        else if (key=="DistCoeffs1")
            distCoeffs1 = rhs[i+1].toMat(CV_32F);
        else if (key=="CameraMatrix2")
            cameraMatrix2 = rhs[i+1].toMat(CV_32F);
        else if (key=="DistCoeffs2")
            distCoeffs2 = rhs[i+1].toMat(CV_32F);
        else if (key=="TermCrit")
            termCrit = rhs[i+1].toTermCriteria();
        else if (key=="FixIntrinsic")
            fixIntrinsic = rhs[i+1].toBool();
        else if (key=="UseIntrinsicGuess")
            useIntrinsicGuess = rhs[i+1].toBool();
        else if (key=="FixPrincipalPoint")
            fixPrincipalPoint = rhs[i+1].toBool();
        else if (key=="FixFocalLength")
            fixFocalLength = rhs[i+1].toBool();
        else if (key=="FixAspectRatio")
            fixAspectRatio = rhs[i+1].toBool();
        else if (key=="SameFocalLength")
            sameFocalLength = rhs[i+1].toBool();
        else if (key=="ZeroTangentDist")
            zeroTangentDist = rhs[i+1].toBool();
        else if (key=="FixK1")
            fixK1 = rhs[i+1].toBool();
        else if (key=="FixK2")
            fixK2 = rhs[i+1].toBool();
        else if (key=="FixK3")
            fixK3 = rhs[i+1].toBool();
        else if (key=="FixK4")
            fixK4 = rhs[i+1].toBool();
        else if (key=="FixK5")
            fixK5 = rhs[i+1].toBool();
        else if (key=="FixK6")
            fixK6 = rhs[i+1].toBool();
        else if (key=="RationalModel")
            calibRationalModel = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }
    int flags = (fixIntrinsic       ? cv::CALIB_FIX_INTRINSIC       : 0) |
                (useIntrinsicGuess  ? cv::CALIB_USE_INTRINSIC_GUESS : 0) |
                (fixPrincipalPoint  ? cv::CALIB_FIX_PRINCIPAL_POINT : 0) |
                (fixFocalLength     ? cv::CALIB_FIX_FOCAL_LENGTH    : 0) |
                (fixAspectRatio     ? cv::CALIB_FIX_ASPECT_RATIO    : 0) |
                (sameFocalLength    ? cv::CALIB_SAME_FOCAL_LENGTH   : 0) |
                (zeroTangentDist    ? cv::CALIB_ZERO_TANGENT_DIST   : 0) |
                (fixK1              ? cv::CALIB_FIX_K1              : 0) |
                (fixK2              ? cv::CALIB_FIX_K2              : 0) |
                (fixK3              ? cv::CALIB_FIX_K3              : 0) |
                (fixK4              ? cv::CALIB_FIX_K4              : 0) |
                (fixK5              ? cv::CALIB_FIX_K5              : 0) |
                (fixK6              ? cv::CALIB_FIX_K6              : 0) |
                (calibRationalModel ? cv::CALIB_RATIONAL_MODEL      : 0);

    // Process
    vector<vector<Point3f> > objectPoints(MxArrayToVectorVectorPoint3<float>(rhs[0]));
    vector<vector<Point2f> > imagePoints1(MxArrayToVectorVectorPoint<float>(rhs[1]));
    vector<vector<Point2f> > imagePoints2(MxArrayToVectorVectorPoint<float>(rhs[2]));
    Size imageSize(rhs[3].toSize());
    Mat R, T, E, F;
    double d = stereoCalibrate(objectPoints, imagePoints1, imagePoints2,
        cameraMatrix1, distCoeffs1, cameraMatrix2, distCoeffs2,
        imageSize, R, T, E, F, flags, termCrit);
    plhs[0] = valueStruct(cameraMatrix1, distCoeffs1, cameraMatrix2,
        distCoeffs2, R, T, E, F, d);
}
