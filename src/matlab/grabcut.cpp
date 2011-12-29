/**
 * @file grabCut.cpp
 * @brief mex interface for OpenCV's grabCut
 * @author Kota Yamaguchi
 * @date 2011
 * @details
 * <pre>
 * Usage:
 *   [ trimap ] = grabCut(img, bbox);
 *   [ trimap ] = grabCut(img, trimap);
 *   [ trimap ] = grabCut(img, trimap, 'Init', initMethod, ...);
 *   [ trimap ] = grabCut(img, trimap, 'MaxIter', maxIter, ...);
 * Input:
 *   img: uint8 type H-by-W-by-3 RGB array
 *   bbox: 1-by-4 double array [x y w h]
 *         It will automatically create a trimap initialized with
 *         label 0 for background and label 3 for foreground (see trimap)
 *   trimap: uint8 H-by-W array of labels {0:bg, 1:fg, 2:probably-bg, 3:probably-fg}
 *   options: 'Init' can take either 'Rect' or 'Mask'. Default to the form of second argument
 *            'MaxIter' specifies maximum number of iteration.
 * Output:
 *   trimap: uint8 H-by-W array with {0:bg, 1:fg, 2:probably-bg, 3:probably-fg}
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
 * This is the entry point of the function
 */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
	// Check the input format
	if (nrhs<2 || (nrhs%2)!=0 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
	if (mxGetClassID(prhs[0])!=mxUINT8_CLASS)
        mexErrMsgIdAndTxt("mexopencv:error","Only UINT8 type is supported");
    if (mxGetNumberOfDimensions(prhs[0])!=3)
        mexErrMsgIdAndTxt("mexopencv:error","Only RGB format is supported");
	
	// Option processing
	MxArray prhs1(prhs[1]);
	int iterCount = 10;
	int mode = (prhs1.isDouble() && prhs1.numel()==4) ?
	            GC_INIT_WITH_RECT : GC_INIT_WITH_MASK; // Automatic determination
	if (nrhs>2) {
	    for (int i=2; i<nrhs; i+=2) {
			std::string key = MxArray(prhs[i]).toString();
			if (key=="Init") {
				std::string val = MxArray(prhs[i+1]).toString();
				if (val=="Rect")
					mode = GC_INIT_WITH_RECT;
				else if (val=="Mask")
					mode = GC_INIT_WITH_MASK;
				else
					mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
			}
			else if (key=="MaxIter")
				iterCount = MxArray(prhs[i+1]).toInt();
			else
				mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
	}
	
	// Initialize mask and rect
	Mat mask;
	Rect rect;
	if (mode == GC_INIT_WITH_MASK)
		mask = prhs1.toMat(CV_8U);
	else
		rect = prhs1.toRect<int>();
	
	// Apply grabCut
	Mat img(MxArray(prhs[0]).toMat());
	Mat bgdModel, fgdModel;
	grabCut(img, mask, rect, bgdModel, fgdModel, iterCount, mode);
	
	// Convert cv::Mat to mxArray
	plhs[0] = MxArray(mask, mxUINT8_CLASS);
}
