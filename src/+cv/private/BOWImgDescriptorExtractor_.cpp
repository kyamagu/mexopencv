/**
 * @file BOWImgDescriptorExtractor_.cpp
 * @brief mex interface for BOWImgDescriptorExtractor
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
#include "opencv2/nonfree/nonfree.hpp"
using namespace std;
using namespace cv;

namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,BOWImgDescriptorExtractor> obj_;
/// Alias for argument number check
inline void nargchk(bool cond)
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
    nargchk(nrhs>=2 && nlhs<=3);
    vector<MxArray> rhs(prhs,prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    if (last_id==0)
        initModule_nonfree();

    // Constructor call
    if (method == "new") {
        nargchk(nrhs>=3 && nrhs<=4 && nlhs<=1);
        string dmatcher = (nrhs==4) ? rhs[3].toString() : string("BruteForce");
        obj_.insert(pair<int,BOWImgDescriptorExtractor>(++last_id,
            BOWImgDescriptorExtractor(
                DescriptorExtractor::create(rhs[2].toString()),
                DescriptorMatcher::create(dmatcher)
            )));
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    BOWImgDescriptorExtractor& obj = obj_.find(id)->second;
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
    }
    else if (method == "setVocabulary") {
        nargchk(nrhs==3 && nlhs==0);
        obj.setVocabulary(rhs[2].isUint8() ? rhs[2].toMat() : rhs[2].toMat(CV_32F));
    }
    else if (method == "getVocabulary") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj.getVocabulary());
    }
    else if (method == "descriptorSize") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj.descriptorSize());
    }
    else if (method == "descriptorType") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj.descriptorType());
    }
    else if (method == "compute") {
        nargchk(nrhs==4 && nlhs<=3);
        Mat image(rhs[2].isUint8() ? rhs[2].toMat() : rhs[2].toMat(CV_32F));
        vector<KeyPoint> keypoints(rhs[3].toVector<KeyPoint>());
        Mat imgDescriptor;
        vector<vector<int> > pointIdxsOfClusters;
        Mat descriptors;
        obj.compute(image,keypoints,imgDescriptor,&pointIdxsOfClusters,&descriptors);
        plhs[0] = MxArray(imgDescriptor);
        if (nrhs>1) {
            vector<Mat> vm;
            vm.reserve(pointIdxsOfClusters.size());
            for (vector<vector<int> >::iterator it=pointIdxsOfClusters.begin();it<pointIdxsOfClusters.end();++it)
                vm.push_back(Mat(*it));
            plhs[1] = MxArray(vm);
        }
        if (nrhs>2)
            plhs[2] = MxArray(descriptors);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation %s", method.c_str());
}
