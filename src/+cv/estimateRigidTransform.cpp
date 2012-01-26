/**
 * @file estimateRigidTransform.cpp
 * @brief mex interface for estimateRigidTransform
 * @author Kota Yamaguchi
 * @date 2012
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
	
	// Option processing
	bool fullAffine=false;
	for (int i=2; i<nrhs; i+=2) {
		string key = rhs[i].toString();
		if (key=="FullAffine")
			fullAffine = rhs[i+1].toBool();
		else
			mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
	}
	
	// Process
#if CV_MINOR_VERSION >= 2
	if (rhs[0].isNumeric() && rhs[1].isNumeric()) {
		Mat src(rhs[0].toMat()), dst(rhs[0].toMat());
		Mat m = estimateRigidTransform(src,dst,fullAffine);
		plhs[0] = MxArray(m);
	}
	else if (rhs[0].isCell() && rhs[1].isCell()) {
		vector<MxArray> vm(rhs[0].toStdVector<MxArray>());
		vector<Point2f> src(vm.size());
		for (int i=0; i<vm.size(); ++i)
			src[i] = vm[i].toPoint_<float>();
		vm = rhs[1].toStdVector<MxArray>();
		vector<Point2f> dst(vm.size());
		for (int i=0; i<vm.size(); ++i)
			dst[i] = vm[i].toPoint_<float>();
		
		Mat m = estimateRigidTransform(src,dst,fullAffine);
		plhs[0] = MxArray(m);
	}
	else
		mexErrMsgIdAndTxt("mexopencv:error","Invalid argument");
#else
		Mat src(rhs[0].toMat()), dst(rhs[0].toMat());
		Mat m = estimateRigidTransform(src,dst,fullAffine);
		plhs[0] = MxArray(m);
#endif
}
