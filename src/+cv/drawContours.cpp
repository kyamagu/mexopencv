/**
 * @file drawContours.cpp
 * @brief mex interface for cv::drawContours
 * @ingroup imgproc
 * @author Kota Yamaguchi
 * @date 2011
 */
#include "mexopencv.hpp"
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
    nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    // Option processing
    int contourIdx = -1;
    Scalar color(Scalar::all(255));
    int thickness = 1;
    int lineType = cv::LINE_8;
    vector<Vec4i> hierarchy;
    int maxLevel = INT_MAX;
    Point offset;
    for (int i=2; i<nrhs; i+=2) {
        string key(rhs[i].toString());
        if (key=="ContourIdx")
            contourIdx = rhs[i+1].toInt();
        else if (key=="Color")
            color = rhs[i+1].toScalar();
        else if (key=="Thickness")
            thickness = (rhs[i+1].isChar()) ?
                ThicknessType[rhs[i+1].toString()] : rhs[i+1].toInt();
        else if (key=="LineType")
            lineType = (rhs[i+1].isChar()) ?
                LineType[rhs[i+1].toString()] : rhs[i+1].toInt();
        else if (key=="Hierarchy")
            //hierarchy = MxArrayToVectorVec<int,4>(rhs[i+1]);
            hierarchy = rhs[i+1].toVector<Vec4i>();
        else if (key=="MaxLevel")
            maxLevel = rhs[i+1].toInt();
        else if (key=="Offset")
            offset = rhs[i+1].toPoint();
        else
            mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
    }

    // Process
    Mat image(rhs[0].toMat());
    vector<vector<Point> > contours(MxArrayToVectorVectorPoint<int>(rhs[1]));
    drawContours(image, contours, contourIdx, color, thickness, lineType,
        hierarchy, maxLevel, offset);
    plhs[0] = MxArray(image);
}
