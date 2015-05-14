/**
 * @file DescriptorMatcher_.cpp
 * @brief mex interface for DescriptorMatcher
 * @author Kota Yamaguchi
 * @date 2012
 */
#include <typeinfo>
#include "mexopencv.hpp"
#include "mexopencv_features2d.hpp"
using namespace std;
using namespace cv;

namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<DescriptorMatcher> > obj_;

/// Check number of arguments
void nargchk(bool cond)
{
    if (!cond)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
}
}

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
    nargchk(nrhs>=2 && nlhs<=1);
    
    // Determine argument format between constructor or (id,method,...)
    vector<MxArray> rhs(prhs,prhs+nrhs);
    int id = rhs[0].toInt();
    string method = rhs[1].toString();

    // Big operation switch
    if (method == "new") {
        nargchk(nrhs>=3);
        string descriptorMatcherType(rhs[2].toString());
        obj_[++last_id] = createDescriptorMatcher(descriptorMatcherType,
            rhs.begin() + 3, rhs.end());
        plhs[0] = MxArray(last_id);
        return;
    }
    Ptr<DescriptorMatcher> obj = obj_[id];
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
    }
    else if (method == "type") {
        nargchk(nrhs==2);
        plhs[0] = MxArray(string(typeid(*obj).name()));
    }
    else if (method == "add") {
        nargchk(nrhs==3 && nlhs==0);
        vector<MxArray> v(rhs[2].toVector<MxArray>());
        vector<Mat> descriptors;
        descriptors.reserve(v.size());
        for (vector<MxArray>::iterator it=v.begin();it<v.end();++it)
            descriptors.push_back(((*it).isUint8()) ? (*it).toMat() : (*it).toMat(CV_32F));
        obj->add(descriptors);
    }
    else if (method == "getTrainDescriptors") {
        nargchk(nrhs==2);
        plhs[0] = MxArray(obj->getTrainDescriptors());
    }
    else if (method == "clear") {
        nargchk(nrhs==2 && nlhs==0);
        obj->clear();
    }
    else if (method == "empty") {
        nargchk(nrhs==2);
        plhs[0] = MxArray(obj->empty());
    }
    else if (method == "isMaskSupported") {
        nargchk(nrhs==2);
        plhs[0] = MxArray(obj->isMaskSupported());
    }
    else if (method == "train") {
        nargchk(nrhs==2);
        obj->train();
    }
    else if (method == "match") {
        nargchk(nrhs>=3);
        Mat queryDescriptors((rhs[2].isUint8()) ? rhs[2].toMat() : rhs[2].toMat(CV_32F));
        vector<DMatch> matches;
        if (nrhs>=4 && rhs[3].isNumeric()) { // First format
            nargchk((nrhs%2)==0);
            Mat trainDescriptors((rhs[3].isUint8()) ? rhs[3].toMat() : rhs[3].toMat(CV_32F));
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
            nargchk((nrhs%2)==1);
            vector<Mat> masks;
            for (int i=3; i<nrhs; i+=2) {
                string key(rhs[i].toString());
                if (key=="Mask")
                    masks = rhs[i+1].toVector<Mat>();
                else
                    mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
            }
            obj->match(queryDescriptors, matches, masks);
        }
        plhs[0] = MxArray(matches);
    }
    else if (method == "knnMatch") {
        nargchk(nrhs>=4);
        Mat queryDescriptors((rhs[2].isUint8()) ? rhs[2].toMat() : rhs[2].toMat(CV_32F));
        vector<vector<DMatch> > matches;
        if (nrhs>=5 && rhs[3].isNumeric() && rhs[4].isNumeric()) { // First format
            nargchk((nrhs%2)==1);
            Mat trainDescriptors((rhs[3].isUint8()) ? rhs[3].toMat() : rhs[3].toMat(CV_32F));
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
            nargchk((nrhs%2)==0);
            int k = rhs[3].toInt();
            vector<Mat> masks;
            bool compactResult=false;
            for (int i=4; i<nrhs; i+=2) {
                string key(rhs[i].toString());
                if (key=="Mask")
                    masks = rhs[i+1].toVector<Mat>();
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
        nargchk(nrhs>=4);
        Mat queryDescriptors((rhs[2].isUint8()) ? rhs[2].toMat() : rhs[2].toMat(CV_32F));
        vector<vector<DMatch> > matches;
        if (nrhs>=5 && rhs[3].isNumeric() && rhs[4].isNumeric()) { // First format
            nargchk((nrhs%2)==1);
            Mat trainDescriptors((rhs[3].isUint8()) ? rhs[3].toMat() : rhs[3].toMat(CV_32F));
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
            nargchk((nrhs%2)==0);
            float maxDistance = rhs[3].toDouble();
            vector<Mat> masks;
            bool compactResult=false;
            for (int i=4; i<nrhs; i+=2) {
                string key(rhs[i].toString());
                if (key=="Mask")
                    masks = rhs[i+1].toVector<Mat>();
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
        nargchk(nrhs==3 && nlhs==0);
        FileStorage fs(rhs[2].toString(),FileStorage::READ);
        obj->read(fs.root());
    }
    else if (method == "write") {
        nargchk(nrhs==3 && nlhs==0);
        FileStorage fs(rhs[2].toString(),FileStorage::WRITE);
        obj->write(fs);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
