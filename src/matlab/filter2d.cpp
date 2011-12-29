/**
 * @file filter2D.cpp
 * @brief mex interface for filter2D
 * @author Kota Yamaguchi
 * @date 2011
 * @details
 * <pre>
 * Usage:
 *   result = fliter2d(img, kernel)
 * </pre>
 */
#include "mexopencv.hpp"
using namespace cv;

/**
 * Main entry called from Matlab
 * @param nlhs number of left-hand-side arguments
 * @param plhs pointers to mxArrays in the left-hand-side
 * @param nrhs number of right-hand-side arguments
 * @param prhs pointers to mxArrays in the right-hand-side
 *
 * Wrapper for filter2D
 */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
	// Check the number of arguments
	if (nrhs<2 || (nrhs%2)==1 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
	
	// Option processing
	Point anchor(-1,-1);
	int borderType = BORDER_DEFAULT;
	for (int i=2; i<nrhs; i+=2) {
		std::string key = MxArray(prhs[i]).toString();
		if (key=="Anchor")
			anchor = MxArray(prhs[i+1]).toPoint<int>();
		else if (key=="BorderType")
			borderType = BorderType::get(prhs[i+1]);
		else
			mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
	}
	
	// Convert mxArray to cv::Mat
	Mat img(MxArray(prhs[0]).toMat(CV_32F));
	Mat kernel(MxArray(prhs[1]).toMat(CV_32F));
	
	// Apply filter 2D
	// There seems to be a bug in filter when BORDER_CONSTANT is used
	filter2D(
		img,                    // src type
		img,                    // dst type
		-1,                     // dst depth
		kernel,                 // 2D kernel
		anchor,                 // anchor point, center if (-1,-1)
		0,                      // bias added after filtering
		borderType	            // border type
		);
	
	// Convert cv::Mat to mxArray
	plhs[0] = MxArray(img,mxGetClassID(prhs[0]));
}
