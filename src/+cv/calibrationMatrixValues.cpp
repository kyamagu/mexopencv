/**
 * @file calibrationMatrixValues.cpp
 * @brief mex interface for cv::calibrationMatrixValues
 * @ingroup calib3d
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/** Create a new MxArray from characteristics of camera matrix.
 * @param fovx Field of view along the horizontal sensor axis.
 * @param fovy Field of view along the vertical sensor axis.
 * @param focalLength Focal length of the lens.
 * @param principalPoint Principal point.
 * @param aspectRatio Aspect ratio <tt>fy/fx</tt>.
 * @return output MxArray struct object.
 */
MxArray toStruct(double fovx, double fovy, double focalLength,
    const Point2d& principalPoint, double aspectRatio)
{
    const char* fieldnames[] = {
        "fovx", "fovy", "focalLength", "principalPoint", "aspectRatio"};
    MxArray s = MxArray::Struct(fieldnames, 5);
    s.set("fovx",           fovx);
    s.set("fovy",           fovy);
    s.set("focalLength",    focalLength);
    s.set("principalPoint", principalPoint);
    s.set("aspectRatio",    aspectRatio);
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
    nargchk(nrhs==4 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    Mat cameraMatrix(rhs[0].toMat(CV_64F));
    Size imageSize(rhs[1].toSize());
    double apertureWidth = rhs[2].toDouble(),
           apertureHeight = rhs[3].toDouble(),
           fovx, fovy, focalLength, aspectRatio;
    Point2d principalPoint;
    calibrationMatrixValues(cameraMatrix, imageSize,
        apertureWidth, apertureHeight,
        fovx, fovy, focalLength, principalPoint, aspectRatio);
    plhs[0] = toStruct(fovx, fovy, focalLength, principalPoint, aspectRatio);
}
