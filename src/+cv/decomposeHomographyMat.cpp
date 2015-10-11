/**
 * @file decomposeHomographyMat.cpp
 * @brief mex interface for cv::decomposeHomographyMat
 * @ingroup calib3d
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/** Create a new MxArray from decomposed homography matrix.
 * @param rotations Array of rotation matrices.
 * @param translations Array of translation matrices.
 * @param normals Array of plane normal matrices.
 * @return output MxArray struct object.
 */
MxArray toStruct(const vector<Mat>& rotations,
    const vector<Mat>& translations, const vector<Mat>& normals)
{
    const char* fieldnames[] = {"R", "t", "n"};
    MxArray s = MxArray::Struct(fieldnames, 3);
    s.set("R", rotations);
    s.set("t", translations);
    s.set("n", normals);
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
    nargchk(nrhs==2 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Process
    Mat H(rhs[0].toMat(CV_64F)),
        K(rhs[1].toMat(CV_64F));
    vector<Mat> rotations, translations, normals;
    int nsols = decomposeHomographyMat(H, K, rotations, translations, normals);
    plhs[0] = toStruct(rotations, translations, normals);
    if (nlhs > 1)
        plhs[1] = MxArray(nsols);
}
