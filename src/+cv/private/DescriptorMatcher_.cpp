/**
 * @file DescriptorMatcher_.cpp
 * @brief mex interface for DescriptorMatcher
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

// Persistent objects

/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<DescriptorMatcher> > obj_;

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
    
	// Determine argument format between constructor or (id,method,...)
	vector<MxArray> rhs(prhs,prhs+nrhs);
	int id = 0;
	string method;
	if (rhs[0].isChar() && nrhs==1) {
		// Constructor is called. Create a new object from argument
		string descriptorMatcherType(rhs[0].toString());
		obj_[++last_id] = DescriptorMatcher::create(descriptorMatcherType);
		plhs[0] = MxArray(last_id);
		return;
	}
	else if (rhs[0].isNumeric() && rhs[0].numel()==1 && nrhs>1) {
		id = rhs[0].toInt();
		method = rhs[1].toString();
	}
	else
        mexErrMsgIdAndTxt("mexopencv:error","Invalid arguments");
	
	// Big operation switch
	Ptr<DescriptorMatcher> obj = obj_[id];
    if (method == "delete") {
    	if (nrhs!=2 || nlhs!=0)
    		mexErrMsgIdAndTxt("mexopencv:error","Output not assigned");
    	obj_.erase(id);
    }
    else if (method == "type") {
    	if (nrhs!=2)
    		mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    	plhs[0] = MxArray(string(typeid(*obj).name()));
    }
    else if (method == "add") {
    	if (nrhs!=3 || nlhs!=0)
    		mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    	vector<Mat> descriptors(rhs[2].toStdVector<Mat>());
    	obj->add(descriptors);
    }
    else if (method == "getTrainDescriptors") {
    	if (nrhs!=2)
    		mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    	plhs[0] = MxArray(obj->getTrainDescriptors());
    }
    else if (method == "clear") {
    	if (nrhs!=2 || nlhs!=0)
    		mexErrMsgIdAndTxt("mexopencv:error","Output not assigned");
    	obj->clear();
    }
    else if (method == "empty") {
    	if (nrhs!=2 || nlhs!=1)
    		mexErrMsgIdAndTxt("mexopencv:error","Output not assigned");
    	plhs[0] = MxArray(obj->empty());
    }
    else if (method == "isMaskSupported") {
    	if (nrhs!=2)
    		mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    	plhs[0] = MxArray(obj->isMaskSupported());
    }
    else if (method == "train") {
    	if (nrhs!=2 || nlhs!=0)
    		mexErrMsgIdAndTxt("mexopencv:error","Output not assigned");
    	obj->train();
    }
    else if (method == "match") {
    	if (nrhs<3)
    		mexErrMsgIdAndTxt("mexopencv:error","Output not assigned");
    	Mat queryDescriptors(rhs[2].toMat());
        vector<DMatch> matches;
    	if (rhs[3].isNumeric()) { // First format
			Mat trainDescriptors(rhs[3].toMat());
			Mat mask;
			for (int i=4; i<nrhs; i+=2) {
				string key(rhs[i].toString());
				if (key=="Mask")
					mask = rhs[i+1].toMat(CV_8U);
				else
					mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
			}
			obj->match(queryDescriptors, trainDescriptors, matches, mask);
		}
		else { // Second format
			vector<Mat> masks;
			for (int i=3; i<nrhs; i+=2) {
				string key(rhs[i].toString());
				if (key=="Mask")
					masks = rhs[i+1].toStdVector<Mat>();
				else
					mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
			}
			obj->match(queryDescriptors, matches, masks);
    	}
    	plhs[0] = MxArray(matches);
    }
    else if (method == "knnMatch") {
    	if (nrhs<4)
    		mexErrMsgIdAndTxt("mexopencv:error","Output not assigned");
    	Mat queryDescriptors(rhs[2].toMat());
        vector<vector<DMatch> > matches;
        if (rhs[3].isNumeric()) { // First format
        	Mat trainDescriptors(rhs[3].toMat());
			int k = rhs[4].toInt();
			Mat mask;
			bool compactResult=false;
			for (int i=5; i<nrhs; i+=2) {
				string key(rhs[i].toString());
				if (key=="Mask")
					mask = rhs[i+1].toMat(CV_8U);
				else if (key=="CompactResult")
					compactResult = rhs[i+1].toBool();
				else
					mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
			}
			obj->knnMatch(queryDescriptors, trainDescriptors, matches, k, mask,
				compactResult);
		}
		else { // Second format
			int k = rhs[3].toInt();
			vector<Mat> masks;
			bool compactResult=false;
			for (int i=4; i<nrhs; i+=2) {
				string key(rhs[i].toString());
				if (key=="Mask")
					masks = rhs[i+1].toStdVector<Mat>();
				else if (key=="CompactResult")
					compactResult = rhs[i+1].toBool();
				else
					mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
			}
			obj->knnMatch(queryDescriptors, matches, k, masks, compactResult);
		}
    	plhs[0] = MxArray(matches);
    }
    else if (method == "radiusMatch") {
    	if (nrhs<4)
    		mexErrMsgIdAndTxt("mexopencv:error","Output not assigned");
    	Mat queryDescriptors(rhs[2].toMat());
        vector<vector<DMatch> > matches;
        if (rhs[3].isNumeric()) { // First format
        	Mat trainDescriptors(rhs[3].toMat());
			float maxDistance = rhs[4].toDouble();
			Mat mask;
			bool compactResult=false;
			for (int i=5; i<nrhs; i+=2) {
				string key(rhs[i].toString());
				if (key=="Mask")
					mask = rhs[i+1].toMat(CV_8U);
				else if (key=="CompactResult")
					compactResult = rhs[i+1].toBool();
				else
					mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
			}
			obj->radiusMatch(queryDescriptors, trainDescriptors, matches, 
				maxDistance, mask, compactResult);
		}
		else { // Second format
			float maxDistance = rhs[3].toDouble();
			vector<Mat> masks;
			bool compactResult=false;
			for (int i=4; i<nrhs; i+=2) {
				string key(rhs[i].toString());
				if (key=="Mask")
					masks = rhs[i+1].toStdVector<Mat>();
				else if (key=="CompactResult")
					compactResult = rhs[i+1].toBool();
				else
					mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
			}
			obj->radiusMatch(queryDescriptors, matches, maxDistance, masks, compactResult);
		}
    	plhs[0] = MxArray(matches);
    }
    else if (method == "read") {
    	if (nrhs!=3 || nlhs!=0)
    		mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    	FileStorage fs(rhs[2].toString(),FileStorage::READ);
    	obj->read(fs.root());
    }
    else if (method == "write") {
    	if (nrhs!=3 || nlhs!=0)
    		mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    	FileStorage fs(rhs[2].toString(),FileStorage::WRITE);
    	obj->write(fs);
    }
    else
		mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
