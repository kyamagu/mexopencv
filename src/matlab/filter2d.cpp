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
#include "cvmx.hpp"
#include <string.h>
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
	if(nrhs<2 || (nrhs%2)==1 || nlhs>1)
        mexErrMsgIdAndTxt("filter2D:invalidArgs","Wrong number of arguments");
	
	// Option processing
	Point anchor(-1,-1);
	int borderType = BORDER_DEFAULT;
	for (int i=2; i<nrhs; i+=2) {
		if (mxGetClassID(prhs[i])==mxCHAR_CLASS) {
			std::string key(cvmxArrayToString(prhs[i]));
			mxClassID classid = mxGetClassID(prhs[i+1]);
			if (key=="Anchor" && classid==mxDOUBLE_CLASS) {
				Mat m(cvmxArrayToMat(prhs[i+1],CV_32S));
				if ((m.cols*m.rows)!=2)
					mexErrMsgIdAndTxt("filter2D:invalidOption","Invalid anchor");
				anchor = Point(m.at<int>(0),m.at<int>(1));
			}
			else if (key=="BorderType" && classid==mxCHAR_CLASS)
				borderType = BorderType::get(prhs[i+1]);
			else
				mexErrMsgIdAndTxt("filter2D:invalidOption","Unrecognized option");
		}
		else
			mexErrMsgIdAndTxt("filter2D:invalidOption","Unrecognized option");
	}
	
	// Convert mxArray to cv::Mat
	Mat img = cvmxArrayToMat(prhs[0],CV_32F);
	Mat kernel = cvmxArrayToMat(prhs[1],CV_32F);
	
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
	plhs[0] = cvmxArrayFromMat(img,mxGetClassID(prhs[0]));
}
