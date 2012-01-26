/**
 * @file findContours.cpp
 * @brief mex interface for findContours
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
	if (nrhs<1 || ((nrhs%2)!=1) || nlhs>2)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
	// Argument vector
	vector<MxArray> rhs(prhs,prhs+nrhs);
	Mat image(rhs[0].toMat(CV_8U));
	vector<vector<Point> > contours;
	vector<Vec4i> hierarchy;
	int mode = CV_RETR_EXTERNAL;
	int method = CV_CHAIN_APPROX_NONE;
	Point offset;
	for (int i=1; i<nrhs; i+=2) {
		string key = rhs[i].toString();
		if (key=="Mode")
			mode = ContourMode[rhs[i+1].toString()];
		else if (key=="Method")
			method = ContourType[rhs[i+1].toString()];
		else if (key=="Offset")
			offset = rhs[i+1].toPoint();
		else
			mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
	}
	
	// Process
	findContours(image, contours, hierarchy, mode, method, offset);
	plhs[0] = MxArray(contours);
#if CV_MINOR_VERSION >= 2
	if (nlhs > 1)
		plhs[1] = MxArray(vector<Mat>(hierarchy.begin(),hierarchy.end()));
#endif
}
