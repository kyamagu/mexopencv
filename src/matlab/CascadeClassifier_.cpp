/**
 * @file CascadeClassifier_.cpp
 * @brief mex interface for CascadeClassifier_
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

/// Persistent cascade classifier objects
int last_id = 0;
map<int,CascadeClassifier> cls_;

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
	if (nrhs<1 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    
	// Determine argument format between (filename,...) or (id,method,...)
	vector<MxArray> rhs(prhs,prhs+nrhs);
	int cls_id = 0;
	string method;
	if (nrhs==1 && rhs[0].isChar()) {
		// Constructor is called. Allocate a new classifier from filename
		cls_[++last_id] = CascadeClassifier(rhs[0].toString());
		plhs[0] = MxArray(last_id);
		return;
	}
	else if (rhs[0].isNumeric() && rhs[0].numel()==1 && nrhs>1) {
		cls_id = rhs[0].toInt();
		method = rhs[1].toString();
	}
	else
        mexErrMsgIdAndTxt("mexopencv:error","Invalid arguments");
	
	// Big operation switch
	CascadeClassifier& cls = cls_[cls_id];
	if (method == "delete") {
		if (nrhs!=2 || nlhs>0)
			mexErrMsgIdAndTxt("mexopencv:error","Output argument not assigned");
		cls_.erase(cls_id);
	}
    else if (method == "empty") {
		if (nrhs!=2)
    		mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    	plhs[0] = MxArray(cls.empty());
    }
    else if (method == "load") {
    	if (nrhs!=3)
    		mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    	plhs[0] = MxArray(cls.load(rhs[2].toString()));
    }
    else if (method == "detectMultiScale") {
    	if (nrhs<3 || (nrhs%2)!=1)
    		mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    	
    	// Option processing
    	double scaleFactor=1.1;
    	int minNeighbors=3, flags=0;
    	Size minSize, maxSize;
		for (int i=3; i<rhs.size(); i+=2) {
			string key = rhs[i].toString();
			if (key=="ScaleFactor")
				scaleFactor = rhs[i+1].toDouble();
			else if (key=="MinNeighbors")
				minNeighbors = rhs[i+1].toInt();
			else if (key=="Flags")
				flags = rhs[i+1].toInt();
			else if (key=="MinSize")
				minSize = rhs[i+1].toSize();
			else if (key=="MaxSize")
				maxSize = rhs[i+1].toSize();
			else
				mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
		}
    	
    	// Run
    	const Mat image(rhs[2].toMat());
    	vector<Rect> objects;
    	cls.detectMultiScale(image, objects, scaleFactor, minNeighbors, flags, minSize, maxSize);
    	plhs[0] = MxArray(objects);
    }
    else
		mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
