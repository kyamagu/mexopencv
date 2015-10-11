/**
 * @file rectify3Collinear.cpp
 * @brief mex interface for cv::rectify3Collinear
 * @ingroup calib3d
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/** Create a new MxArray from stereo rectified transforms.
 * @param R1 Rectification transform for the first camera.
 * @param R2 Rectification transform for the second camera.
 * @param R3 Rectification transform for the third camera.
 * @param P1 Projection matrix in new coord systems of first camera.
 * @param P2 Projection matrix in new coord systems of second camera.
 * @param P3 Projection matrix in new coord systems of third camera.
 * @param Q Disparity-to-depth mapping matrix.
 * @param roi1 ROI in rectified images in 1st cam where all pixels are valid.
 * @param roi2 ROI in rectified images in 2nd cam where all pixels are valid.
 * @param ratio disparity ratio.
 * @return output MxArray struct object.
 */
MxArray toStruct(const Mat& R1, const Mat& R2, const Mat& R3,
    const Mat& P1, const Mat& P2, const Mat& P3, const Mat& Q,
    const Rect& roi1, const Rect& roi2, float ratio)
{
    const char* fieldnames[] = {"R1", "R2", "R3", "P1", "P2", "P3", "Q",
        "roi1", "roi2", "ratio"};
    MxArray s = MxArray::Struct(fieldnames, 10);
    s.set("R1",    R1);
    s.set("R2",    R2);
    s.set("R3",    R3);
    s.set("P1",    P1);
    s.set("P2",    P2);
    s.set("P3",    P3);
    s.set("Q",     Q);
    s.set("roi1",  roi1);
    s.set("roi2",  roi2);
    s.set("ratio", ratio);
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
    nargchk(nrhs>=11 && (nrhs%2)==1 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    vector<Point2f> imgpt1, imgpt3;
    double alpha = -1;
    Size newImageSize;
    int flags = cv::CALIB_ZERO_DISPARITY;
    for (int i=11; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "ImgPoints1")
            imgpt1 = rhs[i+1].toVector<Point2f>();
        else if (key == "ImgPoints3")
            imgpt3 = rhs[i+1].toVector<Point2f>();
        else if (key == "Alpha")
            alpha = rhs[i+1].toDouble();
        else if (key == "NewImageSize")
            newImageSize = rhs[i+1].toSize();
        else if (key == "ZeroDisparity")
            UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CALIB_ZERO_DISPARITY);
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s",key.c_str());
    }

    // Process
    Mat cameraMatrix1(rhs[0].toMat(CV_64F)),
        distCoeffs1(rhs[1].toMat(CV_64F)),
        cameraMatrix2(rhs[2].toMat(CV_64F)),
        distCoeffs2(rhs[3].toMat(CV_64F)),
        cameraMatrix3(rhs[4].toMat(CV_64F)),
        distCoeffs3(rhs[5].toMat(CV_64F)),
        R12(rhs[7].toMat(CV_64F)),
        T12(rhs[8].toMat(CV_64F)),
        R13(rhs[9].toMat(CV_64F)),
        T13(rhs[10].toMat(CV_64F)),
        R1, R2, R3, P1, P2, P3, Q;
    Size imageSize(rhs[6].toSize());
    Rect roi1, roi2;
    float ratio = rectify3Collinear(cameraMatrix1, distCoeffs1,
        cameraMatrix2, distCoeffs2, cameraMatrix3, distCoeffs3,
        imgpt1, imgpt3, imageSize, R12, T12, R13, T13,
        R1, R2, R3, P1, P2, P3, Q, alpha, newImageSize, &roi1, &roi2, flags);
    plhs[0] = toStruct(R1, R2, R3, P1, P2, P3, Q, roi1, roi2, ratio);
}
