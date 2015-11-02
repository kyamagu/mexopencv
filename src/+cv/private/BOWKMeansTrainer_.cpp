/**
 * @file BOWKMeansTrainer_.cpp
 * @brief mex interface for cv::BOWKMeansTrainer
 * @ingroup features2d
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
map<int,Ptr<BOWKMeansTrainer> > obj_;

/// KMeans initalization types
const ConstMap<string,int> KmeansInitMap = ConstMap<string,int>
    ("Random", cv::KMEANS_RANDOM_CENTERS)
    ("PP",     cv::KMEANS_PP_CENTERS);
}

/**
 * Main entry called from Matlab
 * @param nlhs number of left-hand-side arguments
 * @param plhs pointers to mxArrays in the left-hand-side
 * @param nrhs number of right-hand-side arguments
 * @param prhs pointers to mxArrays in the right-hand-side
 */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // Check the number of arguments
    nargchk(nrhs>=2 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor call
    if (method == "new") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        int clusterCount = rhs[2].toInt();
        TermCriteria criteria;
        int attempts = 3;
        int flags = cv::KMEANS_PP_CENTERS;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Criteria")
                criteria = rhs[i+1].toTermCriteria();
            else if (key == "Attempts")
                attempts = rhs[i+1].toInt();
            else if (key == "Initialization")
                flags = KmeansInitMap[rhs[i+1].toString()];
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unknown option %s",key.c_str());
        }
        obj_[++last_id] = makePtr<BOWKMeansTrainer>(
            clusterCount, criteria, attempts, flags);
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<BOWKMeansTrainer> obj = obj_[id];
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
    }
    else if (method == "clear") {
        nargchk(nrhs==2 && nlhs==0);
        obj->clear();
    }
    else if (method == "getDescriptors") {
        nargchk(nrhs==2 && nlhs<=1);
        vector<Mat> descs(obj->getDescriptors());
        plhs[0] = MxArray(descs);
    }
    else if (method == "descriptorsCount") {
        nargchk(nrhs==2 && nlhs<=1);
        int count = obj->descriptorsCount();
        plhs[0] = MxArray(count);
    }
    else if (method == "add") {
        nargchk(nrhs==3 && nlhs==0);
        obj->add(rhs[2].toMat(CV_32F));
    }
    else if (method == "cluster") {
        nargchk((nrhs==2 || nrhs==3) && nlhs<=1);
        Mat vocabulary;
        if (nrhs==2)  // first variant
            vocabulary = obj->cluster();
        else          // second variant
            vocabulary = obj->cluster(rhs[2].toMat(CV_32F));
        plhs[0] = MxArray(vocabulary);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
