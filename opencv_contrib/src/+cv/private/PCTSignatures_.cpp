/**
 * @file PCTSignatures_.cpp
 * @brief mex interface for cv::xfeatures2d::PCTSignatures
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
map<int,Ptr<PCTSignatures> > obj_;

/// Lp distance function selector for option processing
const ConstMap<string,int> DistanceFuncMap = ConstMap<string,int>
    ("L0_25",     cv::xfeatures2d::PCTSignatures::L0_25)
    ("L0_5",      cv::xfeatures2d::PCTSignatures::L0_5)
    ("L1",        cv::xfeatures2d::PCTSignatures::L1)
    ("L2",        cv::xfeatures2d::PCTSignatures::L2)
    ("L2Squared", cv::xfeatures2d::PCTSignatures::L2SQUARED)
    ("L5",        cv::xfeatures2d::PCTSignatures::L5)
    ("L_Inf",     cv::xfeatures2d::PCTSignatures::L_INFINITY);

/// Random point distributions for option processing
const ConstMap<string,int> PointDistributionMap = ConstMap<string,int>
    ("Uniform", cv::xfeatures2d::PCTSignatures::UNIFORM)
    ("Regular", cv::xfeatures2d::PCTSignatures::REGULAR)
    ("Normal",  cv::xfeatures2d::PCTSignatures::NORMAL);
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
        nargchk(nlhs<=1);
        Ptr<PCTSignatures> p;
        // second/third variants with custom sampling points
        if (nrhs==4 && !rhs[2].isChar()) {
            vector<Point2f> initSamplingPoints(rhs[2].toVector<Point2f>());
            if (rhs[3].numel() == 1) {
                int initSeedCount = rhs[3].toInt();
                p = PCTSignatures::create(initSamplingPoints, initSeedCount);
            }
            else {
                vector<int> initClusterSeedIndexes(rhs[3].toVector<int>());
                p = PCTSignatures::create(initSamplingPoints, initClusterSeedIndexes);
            }
        }
        // first variant
        else {
            nargchk(nrhs>=2 && (nrhs%2)==0);
            int initSampleCount = 2000;
            int initSeedCount = 400;
            int pointDistribution = 0;
            for (int i=2; i<nrhs; i+=2) {
                string key(rhs[i].toString());
                if (key == "InitSampleCount")
                    initSampleCount = rhs[i+1].toInt();
                else if (key == "InitSeedCount")
                    initSeedCount = rhs[i+1].toInt();
                else if (key == "PointDistributiontion")
                    pointDistribution = (rhs[i+1].isChar()) ?
                        PointDistributionMap[rhs[i+1].toString()] :
                        rhs[i+1].toInt();
                else
                    mexErrMsgIdAndTxt("mexopencv:error",
                        "Unrecognized option %s", key.c_str());
            }
            p = PCTSignatures::create(
                initSampleCount, initSeedCount, pointDistribution);
        }
        obj_[++last_id] = p;
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }
    // static methods
    else if (method == "generateInitPoints") {
        nargchk(nrhs==4 && nlhs<=1);
        int count = rhs[2].toInt();
        int pointDistribution = (rhs[3].isChar()) ?
            PointDistributionMap[rhs[3].toString()] : rhs[3].toInt();
        vector<Point2f> initPoints;
        PCTSignatures::generateInitPoints(initPoints, count, pointDistribution);
        plhs[0] = MxArray(Mat(initPoints,false).reshape(1,0));  // N-by-2 numeric matrix
        return;
    }
    else if (method == "drawSignature") {
        nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=1);
        float radiusToShorterSideRatio = 1.0f / 8;
        int borderThickness = 1;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "RadiusToShorterSideRatio")
                radiusToShorterSideRatio = rhs[i+1].toFloat();
            else if (key == "BorderThickness")
                borderThickness = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat source(rhs[2].toMat()),
            signature(rhs[3].toMat(CV_32F)),
            result;
        PCTSignatures::drawSignature(source, signature, result,
            radiusToShorterSideRatio, borderThickness);
        plhs[0] = MxArray(result);
        return;
    }

    // Big operation switch
    Ptr<PCTSignatures> obj = obj_[id];
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
            Algorithm::loadFromString<PCTSignatures>(rhs[2].toString(), objname) :
            Algorithm::load<PCTSignatures>(rhs[2].toString(), objname));
    }
    else if (method == "empty") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->empty());
    }
    else if (method == "getDefaultName") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getDefaultName());
    }
    else if (method == "computeSignature") {
        nargchk(nrhs==3 && nlhs<=1);
        Mat image(rhs[2].toMat(CV_8U)),
            signature;
        obj->computeSignature(image, signature);
        plhs[0] = MxArray(signature);
    }
    else if (method == "computeSignatures") {
        nargchk(nrhs==3 && nlhs<=1);
        //vector<Mat> images(rhs[2].toVector<Mat>());
        vector<Mat> images;
        {
            vector<MxArray> arr(rhs[2].toVector<MxArray>());
            images.reserve(arr.size());
            for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
                images.push_back(it->toMat(CV_8U));
        }
        vector<Mat> signatures;
        obj->computeSignatures(images, signatures);
        plhs[0] = MxArray(signatures);
    }
    else if (method == "getSampleCount") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getSampleCount());
    }
    else if (method == "getSamplingPoints") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getSamplingPoints());
    }
    else if (method == "setSamplingPoints") {
        nargchk(nrhs==3 && nlhs==0);
        obj->setSamplingPoints(rhs[2].toVector<Point2f>());
    }
    else if (method == "setWeight") {
        nargchk(nrhs==4 && nlhs==0);
        obj->setWeight(rhs[2].toInt(), rhs[3].toFloat());
    }
    else if (method == "setWeights") {
        nargchk(nrhs==3 && nlhs==0);
        obj->setWeights(rhs[2].toVector<float>());
    }
    else if (method == "setTranslation") {
        nargchk(nrhs==4 && nlhs==0);
        obj->setTranslation(rhs[2].toInt(), rhs[3].toFloat());
    }
    else if (method == "setTranslations") {
        nargchk(nrhs==3 && nlhs==0);
        obj->setTranslations(rhs[2].toVector<float>());
    }
    else if (method == "getInitSeedCount") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getInitSeedCount());
    }
    else if (method == "getInitSeedIndexes") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getInitSeedIndexes());
    }
    else if (method == "setInitSeedIndexes") {
        nargchk(nrhs==3 && nlhs==0);
        obj->setInitSeedIndexes(rhs[2].toVector<int>());
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "GrayscaleBits")
            plhs[0] = MxArray(obj->getGrayscaleBits());
        else if (prop == "WindowRadius")
            plhs[0] = MxArray(obj->getWindowRadius());
        else if (prop == "WeightX")
            plhs[0] = MxArray(obj->getWeightX());
        else if (prop == "WeightY")
            plhs[0] = MxArray(obj->getWeightY());
        else if (prop == "WeightL")
            plhs[0] = MxArray(obj->getWeightL());
        else if (prop == "WeightA")
            plhs[0] = MxArray(obj->getWeightA());
        else if (prop == "WeightB")
            plhs[0] = MxArray(obj->getWeightB());
        else if (prop == "WeightContrast")
            plhs[0] = MxArray(obj->getWeightContrast());
        else if (prop == "WeightEntropy")
            plhs[0] = MxArray(obj->getWeightEntropy());
        else if (prop == "IterationCount")
            plhs[0] = MxArray(obj->getIterationCount());
        else if (prop == "MaxClustersCount")
            plhs[0] = MxArray(obj->getMaxClustersCount());
        else if (prop == "ClusterMinSize")
            plhs[0] = MxArray(obj->getClusterMinSize());
        else if (prop == "JoiningDistance")
            plhs[0] = MxArray(obj->getJoiningDistance());
        else if (prop == "DropThreshold")
            plhs[0] = MxArray(obj->getDropThreshold());
        else if (prop == "DistanceFunction")
            plhs[0] = MxArray(obj->getDistanceFunction());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "GrayscaleBits")
            obj->setGrayscaleBits(rhs[3].toInt());
        else if (prop == "WindowRadius")
            obj->setWindowRadius(rhs[3].toInt());
        else if (prop == "WeightX")
            obj->setWeightX(rhs[3].toFloat());
        else if (prop == "WeightY")
            obj->setWeightY(rhs[3].toFloat());
        else if (prop == "WeightL")
            obj->setWeightL(rhs[3].toFloat());
        else if (prop == "WeightA")
            obj->setWeightA(rhs[3].toFloat());
        else if (prop == "WeightB")
            obj->setWeightB(rhs[3].toFloat());
        else if (prop == "WeightContrast")
            obj->setWeightContrast(rhs[3].toFloat());
        else if (prop == "WeightEntropy")
            obj->setWeightEntropy(rhs[3].toFloat());
        else if (prop == "IterationCount")
            obj->setIterationCount(rhs[3].toInt());
        else if (prop == "MaxClustersCount")
            obj->setMaxClustersCount(rhs[3].toInt());
        else if (prop == "ClusterMinSize")
            obj->setClusterMinSize(rhs[3].toInt());
        else if (prop == "JoiningDistance")
            obj->setJoiningDistance(rhs[3].toFloat());
        else if (prop == "DropThreshold")
            obj->setDropThreshold(rhs[3].toFloat());
        else if (prop == "DistanceFunction")
            obj->setDistanceFunction(rhs[3].isChar() ?
                DistanceFuncMap[rhs[3].toString()] : rhs[3].toInt());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
