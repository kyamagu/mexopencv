/**
 * @file drawContours.cpp
 * @brief mex interface for drawContours
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
	if (nrhs<2 || ((nrhs%2)!=0) || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
	// Argument vector
	vector<MxArray> rhs(prhs,prhs+nrhs);
	
	Mat image(rhs[0].toMat(CV_8U));
	
	vector<MxArray> cm(rhs[1].toStdVector<MxArray>());
	vector<vector<Point> > contours(cm.size());
	for (int i=0; i<cm.size(); ++i)
		contours[i] = cm[i].toStdVector<Point>();
	
	int contourIdx=-1;
	Scalar color(255,255,255);
	int thickness=1;
	int lineType=8;
	vector<Vec4i> hierarchy;
	int maxLevel=INT_MAX;
	Point offset;
	
	for (int i=2; i<nrhs; i+=2) {
		string key = rhs[i].toString();
		if (key=="ContourIdx")
			contourIdx = rhs[i+1].toInt();
		else if (key=="Color")
			color = rhs[i+1].toScalar();
		else if (key=="Thickness")
			thickness = rhs[i+1].toInt();
		else if (key=="LineType")
			lineType = rhs[i+1].toInt();
		else if (key=="Hierarchy") {
#if CV_MINOR_VERSION >= 2
			vector<Mat> hm(rhs[i+1].toStdVector<Mat>());
			hierarchy = vector<Vec4i>(hm.begin(),hm.end());
#endif
			//for (int i=0; i<hm.size(); ++i)
			//	  hierarchy.push_back(Vec4i(hm[i].at<int>(0),hm[i].at<int>(1),
			//        hm[i].at<int>(2),hm[i].at<int>(3)));
		}
		else if (key=="MaxLevel")
			maxLevel = rhs[i+1].toInt();
		else if (key=="Offset")
			offset = rhs[i+1].toPoint();
		else
			mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
	}
	
	// Process
	drawContours(image, contours, contourIdx, color, thickness, lineType,
		hierarchy, maxLevel, offset);
	plhs[0] = MxArray(image);
}
