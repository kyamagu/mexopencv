/**
 * @file BackgroundSubtractorLSBP_.cpp
 * @brief mex interface for cv::bgsegm::BackgroundSubtractorLSBP
 * @ingroup bgsegm
 * @author Amro
 * @date 2018
 */
#include "mexopencv.hpp"
#include "opencv2/bgsegm.hpp"
using namespace std;
using namespace cv;
using namespace cv::bgsegm;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<BackgroundSubtractorLSBP> > obj_;

/// motion compensation types for option processing
const ConstMap<string,int> MotionCompensationsMap = ConstMap<string,int>
    ("None", cv::bgsegm::LSBP_CAMERA_MOTION_COMPENSATION_NONE)
    ("LK",   cv::bgsegm::LSBP_CAMERA_MOTION_COMPENSATION_LK);
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
        int mc = cv::bgsegm::LSBP_CAMERA_MOTION_COMPENSATION_NONE;
        int nSamples = 20;
        int LSBPRadius = 16;
        float Tlower = 2.0f;
        float Tupper = 32.0f;
        float Tinc = 1.0f;
        float Tdec = 0.05f;
        float Rscale = 10.0f;
        float Rincdec = 0.005f;
        float noiseRemovalThresholdFacBG = 0.0004f;
        float noiseRemovalThresholdFacFG = 0.0008f;
        int LSBPthreshold = 8;
        int minCount = 2;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "MotionCompensation")
                mc = MotionCompensationsMap[rhs[i+1].toString()];
            else if (key == "NSamples")
                nSamples = rhs[i+1].toInt();
            else if (key == "LSBPRadius")
                LSBPRadius = rhs[i+1].toInt();
            else if (key == "TLower")
                Tlower = rhs[i+1].toFloat();
            else if (key == "TUpper")
                Tupper = rhs[i+1].toFloat();
            else if (key == "TInc")
                Tinc = rhs[i+1].toFloat();
            else if (key == "TDec")
                Tdec = rhs[i+1].toFloat();
            else if (key == "RScale")
                Rscale = rhs[i+1].toFloat();
            else if (key == "RIncDec")
                Rincdec = rhs[i+1].toFloat();
            else if (key == "NoiseRemovalThresholdFacBG")
                noiseRemovalThresholdFacBG = rhs[i+1].toFloat();
            else if (key == "NoiseRemovalThresholdFacFG")
                noiseRemovalThresholdFacFG = rhs[i+1].toFloat();
            else if (key == "LSBPThreshold")
                LSBPthreshold = rhs[i+1].toInt();
            else if (key == "MinCount")
                minCount = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        obj_[++last_id] = createBackgroundSubtractorLSBP(mc, nSamples,
            LSBPRadius, Tlower, Tupper, Tinc, Tdec, Rscale, Rincdec,
            noiseRemovalThresholdFacBG, noiseRemovalThresholdFacFG,
            LSBPthreshold, minCount);
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }
    // static method call
    else if (method == "computeLSBPDesc") {
        nargchk(nrhs==4 && nlhs<=1);
        Mat frame(rhs[2].toMat(CV_32F)),
            desc;
        vector<Point2i> LSBPSamplePoints(rhs[3].toVector<Point2i>());
        if (LSBPSamplePoints.size() != 32)
            mexErrMsgIdAndTxt("mexopencv:error", "32 points required");
        BackgroundSubtractorLSBPDesc::compute(desc, frame, &LSBPSamplePoints[0]);
        plhs[0] = MxArray(desc);
        return;
    }

    // Big operation switch
    Ptr<BackgroundSubtractorLSBP> obj = obj_[id];
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
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs==0);
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
        /*
        obj_[id] = (loadFromString ?
            Algorithm::loadFromString<BackgroundSubtractorLSBP>(rhs[2].toString(), objname) :
            Algorithm::load<BackgroundSubtractorLSBP>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing BackgroundSubtractorLSBP::create()
        FileStorage fs(rhs[2].toString(), FileStorage::READ +
            (loadFromString ? FileStorage::MEMORY : 0));
        if (!fs.isOpened())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to open file");
        FileNode fn(objname.empty() ? fs.getFirstTopLevelNode() : fs[objname]);
        if (fn.empty())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to get node");
        obj->read(fn);
        //*/
    }
    else if (method == "empty") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->empty());
    }
    else if (method == "getDefaultName") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getDefaultName());
    }
    else if (method == "apply") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        double learningRate = -1;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "LearningRate")
                learningRate = rhs[i+1].toDouble();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat image(rhs[2].toMat(rhs[2].isFloat() ? CV_32F : CV_8U)),
            fgmask;
        obj->apply(image, fgmask, learningRate);
        plhs[0] = MxArray(fgmask);
    }
    else if (method == "getBackgroundImage") {
        nargchk(nrhs==2 && nlhs<=1);
        Mat backgroundImage;
        obj->getBackgroundImage(backgroundImage);
        plhs[0] = MxArray(backgroundImage);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
