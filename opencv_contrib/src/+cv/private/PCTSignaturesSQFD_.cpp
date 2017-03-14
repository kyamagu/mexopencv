/**
 * @file PCTSignaturesSQFD_.cpp
 * @brief mex interface for cv::xfeatures2d::PCTSignaturesSQFD
 * @ingroup xfeatures2d
 * @author Amro
 * @date 2017
 */
#include "mexopencv.hpp"
#include "opencv2/xfeatures2d.hpp"
using namespace std;
using namespace cv;
using namespace cv::xfeatures2d;

namespace {
// Persistent objects
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<PCTSignaturesSQFD> > obj_;

/// Lp distance function selector for option processing
const ConstMap<string,int> DistanceFuncMap = ConstMap<string,int>
    ("L0_25",     cv::xfeatures2d::PCTSignatures::L0_25)
    ("L0_5",      cv::xfeatures2d::PCTSignatures::L0_5)
    ("L1",        cv::xfeatures2d::PCTSignatures::L1)
    ("L2",        cv::xfeatures2d::PCTSignatures::L2)
    ("L2Squared", cv::xfeatures2d::PCTSignatures::L2SQUARED)
    ("L5",        cv::xfeatures2d::PCTSignatures::L5)
    ("L_Inf",     cv::xfeatures2d::PCTSignatures::L_INFINITY);

/// Similarity function selector for option processing
const ConstMap<string,int> SimilarityFuncMap = ConstMap<string,int>
    ("Minus",     cv::xfeatures2d::PCTSignatures::MINUS)
    ("Gaussian",  cv::xfeatures2d::PCTSignatures::GAUSSIAN)
    ("Heuristic", cv::xfeatures2d::PCTSignatures::HEURISTIC);
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
    nargchk(nrhs>=2 && nlhs<=1);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // constructor call
    if (method == "new") {
        nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);
        int distanceFunction = 3;
        int similarityFunction = 2;
        float similarityParameter = 1.0f;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "DistanceFunction")
                distanceFunction = (rhs[i+1].isChar()) ?
                    DistanceFuncMap[rhs[i+1].toString()] : rhs[i+1].toInt();
            else if (key == "SimilarityFunction")
                similarityFunction = (rhs[i+1].isChar()) ?
                    SimilarityFuncMap[rhs[i+1].toString()] : rhs[i+1].toInt();
            else if (key == "SimilarityParameter")
                similarityParameter = rhs[i+1].toFloat();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        obj_[++last_id] = PCTSignaturesSQFD::create(
            distanceFunction, similarityFunction, similarityParameter);
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<PCTSignaturesSQFD> obj = obj_[id];
    if (obj.empty())
        mexErrMsgIdAndTxt("mexopencv:error", "Object not found id=%d", id);
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
        mexUnlock();
    }
    else if (method == "clear") {
        nargchk(nrhs==2 && nlhs==0);
        obj->clear();
    }
    else if (method == "save") {
        nargchk(nrhs==3 && nlhs==0);
        obj->save(rhs[2].toString());
    }
    else if (method == "load") {
        nargchk(nrhs>=3 && (nrhs%2)!=0 && nlhs==0);
        string objname;
        bool loadFromString = false;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "ObjName")
                objname = rhs[i+1].toString();
            else if (key == "FromString")
                loadFromString = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        obj_[id] = (loadFromString ?
            Algorithm::loadFromString<PCTSignaturesSQFD>(rhs[2].toString(), objname) :
            Algorithm::load<PCTSignaturesSQFD>(rhs[2].toString(), objname));
    }
    else if (method == "empty") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->empty());
    }
    else if (method == "getDefaultName") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getDefaultName());
    }
    else if (method == "computeQuadraticFormDistance") {
        nargchk(nrhs==4 && nlhs<=1);
        Mat signature0(rhs[2].toMat(CV_32F)),
            signature1(rhs[3].toMat(CV_32F));
        float dist = obj->computeQuadraticFormDistance(signature0, signature1);
        plhs[0] = MxArray(dist);
    }
    else if (method == "computeQuadraticFormDistances") {
        nargchk(nrhs==4 && nlhs<=1);
        Mat sourceSignature(rhs[2].toMat(CV_32F));
        //vector<Mat> imageSignatures(rhs[3].toVector<Mat>());
        vector<Mat> imageSignatures;
        {
            vector<MxArray> arr(rhs[3].toVector<MxArray>());
            imageSignatures.reserve(arr.size());
            for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
                imageSignatures.push_back(it->toMat(CV_32F));
        }
        vector<float> distances;
        obj->computeQuadraticFormDistances(sourceSignature, imageSignatures,
            distances);
        plhs[0] = MxArray(distances);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
