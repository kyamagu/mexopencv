/**
 * @file initWideAngleProjMap.cpp
 * @brief mex interface for cv::initWideAngleProjMap
 * @ingroup imgproc
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/// Map type specification
const ConstMap<string,int> M1Type = ConstMap<string,int>
    ("int16",   CV_16SC2)
    ("single1", CV_32FC1)
    ("single2", CV_32FC2);

/// projection types for option processing
const ConstMap<string,int> ProjTypeMap = ConstMap<string,int>
    ("Ortho",  cv::PROJ_SPHERICAL_ORTHO)
    ("EqRect", cv::PROJ_SPHERICAL_EQRECT);
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
    nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=3);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int m1type = -1;
    int projType = cv::PROJ_SPHERICAL_EQRECT;
    double alpha = 0;
    for (int i=4; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key == "M1Type")
            m1type = (rhs[i+1].isChar()) ?
                M1Type[rhs[i+1].toString()] : rhs[i+1].toInt();
        else if (key == "ProjType")
            projType = ProjTypeMap[rhs[i+1].toString()];
        else if (key == "Alpha")
            alpha = rhs[i+1].toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }

    // Process
    Mat cameraMatrix(rhs[0].toMat(CV_64F)),
        distCoeffs(rhs[1].toMat(CV_64F)),
        map1, map2;
    Size imageSize(rhs[2].toSize());
    int destImageWidth = rhs[3].toInt();
    float scale = initWideAngleProjMap(cameraMatrix, distCoeffs, imageSize,
        destImageWidth, m1type, map1, map2, projType, alpha);
    plhs[0] = MxArray(map1);
    if (nlhs > 1)
        plhs[1] = MxArray(map2);
    if (nlhs > 2)
        plhs[2] = MxArray(scale);
}
