/**
 * @file stereoRectifyUncalibrated.cpp
 * @brief mex interface for stereoRectifyUncalibrated
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
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
	// Check the number of arguments
	if (nrhs<4 || ((nrhs%2)!=1) || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
	// Argument vector
	vector<MxArray> rhs(prhs,prhs+nrhs);
	
	vector<Point2f> points1(rhs[0].toStdVector<Point2f>());
	vector<Point2f> points2(rhs[1].toStdVector<Point2f>());
	Mat F(rhs[2].toMat(CV_32F));
	Size imgSize(rhs[3].toSize());
	Mat H1, H2;
	// Option processing
	double threshold=5;
	for (int i=4; i<nrhs; i+=2) {
		string key = rhs[i].toString();
		if (key=="Threshold")
			threshold = rhs[i+1].toDouble();
		else
			mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
	}
	
	// Process
	stereoRectifyUncalibrated(points1, points2, F, imgSize, H1, H2, threshold);
	plhs[0] = MxArray(H1);
	if (nlhs>1)
		plhs[1] = MxArray(H2);
}
