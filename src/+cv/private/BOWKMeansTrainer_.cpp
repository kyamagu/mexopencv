/**
 * @file BOWKMeansTrainer_.cpp
 * @brief mex interface for BOWKMeansTrainer
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,BOWKMeansTrainer> obj_;

/** KMeans initalization types
 */
const ConstMap<std::string,int> Initialization = ConstMap<std::string,int>
    ("Random",KMEANS_RANDOM_CENTERS)
    ("PP",KMEANS_PP_CENTERS);

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
    nargchk(nrhs>=2 && nlhs<=2);
    vector<MxArray> rhs(prhs,prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());
    
    // Constructor call
    if (method == "new") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        int clusterCount = rhs[2].toInt();
        TermCriteria criteria;
        int attempts=3;
        int flags=KMEANS_PP_CENTERS;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="Criteria")
                criteria = rhs[i+1].toTermCriteria();
            else if (key=="Attempts")
                attempts = rhs[i+1].toInt();
            else if (key=="Initialization")
                flags = Initialization[rhs[i+1].toString()];
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unknown option %s",key.c_str());
        }
        //obj_[++last_id] = BOWKMeansTrainer(clusterCount,criteria,attempts,flags);
        obj_.insert(pair<int,BOWKMeansTrainer>(++last_id,
            BOWKMeansTrainer(clusterCount,criteria,attempts,flags)));
        plhs[0] = MxArray(last_id);
        return;
    }
    
    // Big operation switch
    BOWKMeansTrainer& obj = obj_.find(id)->second;
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
    }
    else if (method == "add") {
        nargchk(nrhs==3 && nlhs==0);
        obj.add(rhs[2].toMat(CV_32F));
    }
    else if (method == "getDescriptors") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj.getDescriptors());
    }
    else if (method == "descriptorsCount") {
        nargchk(nrhs==2 && nlhs<=1);
        // plhs[0] = MxArray(obj.descripotorsCount());
        plhs[0] = MxArray(obj.descripotorsCount()); // OpenCV has typo...
    }
    else if (method == "clear") {
        nargchk(nrhs==2 && nlhs==0);
        obj.clear();
    }
    else if (method == "cluster") {
        nargchk(nrhs<=3 && nlhs<=1);
        if (nrhs==2)
            plhs[0] = MxArray(obj.cluster());
        else
            plhs[0] = MxArray(obj.cluster(rhs[2].toMat(CV_32F)));
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation %s", method.c_str());
}
