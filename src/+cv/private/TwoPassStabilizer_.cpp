/**
 * @file TwoPassStabilizer_.cpp
 * @brief mex interface for cv::videostab::TwoPassStabilizer
 * @ingroup videostab
 * @author Amro
 * @date 2016
 */
#include "mexopencv.hpp"
#include "mexopencv_videostab.hpp"
#include "opencv2/videostab.hpp"
using namespace std;
using namespace cv;
using namespace cv::videostab;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<TwoPassStabilizer> > obj_;
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

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        nargchk(nrhs==2 && nlhs<=1);
        obj_[++last_id] = makePtr<TwoPassStabilizer>();
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }
    // static methods
    else if (method == "RansacParamsDefault2dMotion") {
        nargchk(nrhs==3 && nlhs<=1);
        MotionModel model = MotionModelMap[rhs[2].toString()];
        RansacParams ransacParams = RansacParams::default2dMotion(model);
        plhs[0] = toStruct(ransacParams);
        return;
    }

    // Big operation switch
    Ptr<TwoPassStabilizer> obj = obj_[id];
    if (obj.empty())
        mexErrMsgIdAndTxt("mexopencv:error", "Object not found id=%d", id);
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
        mexUnlock();
    }
    else if (method == "reset") {
        nargchk(nrhs==2 && nlhs==0);
        obj->reset();
    }
    else if (method == "nextFrame") {
        nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);
        bool flip = false;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "FlipChannels")
                flip = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat frame(obj->nextFrame());
        if (flip && (frame.channels() == 3 || frame.channels() == 4)) {
            // OpenCV's default is BGR/BGRA while MATLAB's is RGB/RGBA
            cvtColor(frame, frame, (frame.channels()==3 ?
                cv::COLOR_BGR2RGB : cv::COLOR_BGRA2RGBA));
        }
        plhs[0] = MxArray(frame);
    }
    else if (method == "setLog") {
        nargchk(nrhs==3 && nlhs==0);
        Ptr<ILog> p = createILog(rhs[2].toString());
        obj->setLog(p);
    }
    else if (method == "setFrameSource") {
        nargchk(nrhs>=3 && nlhs==0);
        Ptr<IFrameSource> p = createIFrameSource(
            rhs[2].toString(), rhs.begin() + 3, rhs.end());
        obj->setFrameSource(p);
    }
    else if (method == "setDeblurer") {
        nargchk(nrhs>=3 && nlhs==0);
        Ptr<DeblurerBase> p = createDeblurerBase(
            rhs[2].toString(), rhs.begin() + 3, rhs.end());
        obj->setDeblurer(p);
    }
    else if (method == "setMotionEstimator") {
        nargchk(nrhs>=3 && nlhs==0);
        Ptr<ImageMotionEstimatorBase> p = createImageMotionEstimator(
            rhs[2].toString(), rhs.begin() + 3, rhs.end());
        obj->setMotionEstimator(p);
    }
    else if (method == "setInpainter") {
        nargchk(nrhs>=3 && nlhs==0);
        Ptr<InpainterBase> p = createInpainterBase(
            rhs[2].toString(), rhs.begin() + 3, rhs.end());
        obj->setInpainter(p);
    }
    else if (method == "setMotionStabilizer") {
        nargchk(nrhs>=3 && nlhs==0);
        Ptr<IMotionStabilizer> p = createIMotionStabilizer(
            rhs[2].toString(), rhs.begin() + 3, rhs.end());
        obj->setMotionStabilizer(p);
    }
    else if (method == "setWobbleSuppressor") {
        nargchk(nrhs>=3 && nlhs==0);
        Ptr<WobbleSuppressorBase> p = createWobbleSuppressorBase(
            rhs[2].toString(), rhs.begin() + 3, rhs.end());
        obj->setWobbleSuppressor(p);
    }
    else if (method == "getLog") {
        nargchk(nrhs==2 && nlhs<=1);
        Ptr<ILog> p = obj->log();
        plhs[0] = toStruct(p);
    }
    else if (method == "getFrameSource") {
        nargchk(nrhs==2 && nlhs<=1);
        Ptr<IFrameSource> p = obj->frameSource();
        plhs[0] = toStruct(p);
    }
    else if (method == "getDeblurer") {
        nargchk(nrhs==2 && nlhs<=1);
        Ptr<DeblurerBase> p = obj->deblurrer();
        plhs[0] = toStruct(p);
    }
    else if (method == "getMotionEstimator") {
        nargchk(nrhs==2 && nlhs<=1);
        Ptr<ImageMotionEstimatorBase> p = obj->motionEstimator();
        plhs[0] = toStruct(p);
    }
    else if (method == "getInpainter") {
        nargchk(nrhs==2 && nlhs<=1);
        Ptr<InpainterBase> p = obj->inpainter();
        plhs[0] = toStruct(p);
    }
    else if (method == "getMotionStabilizer") {
        nargchk(nrhs==2 && nlhs<=1);
        Ptr<IMotionStabilizer> p = obj->motionStabilizer();
        plhs[0] = toStruct(p);
    }
    else if (method == "getWobbleSuppressor") {
        nargchk(nrhs==2 && nlhs<=1);
        Ptr<WobbleSuppressorBase> p = obj->wobbleSuppressor();
        plhs[0] = toStruct(p);
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "BorderMode")
            plhs[0] = MxArray(BorderTypeInv[obj->borderMode()]);
        else if (prop == "CorrectionForInclusion")
            plhs[0] = MxArray(obj->doCorrectionForInclusion());
        else if (prop == "Radius")
            plhs[0] = MxArray(obj->radius());
        else if (prop == "TrimRatio")
            plhs[0] = MxArray(obj->trimRatio());
        else if (prop == "EstimateTrimRatio")
            plhs[0] = MxArray(obj->mustEstimateTrimaRatio());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "BorderMode")
            obj->setBorderMode(BorderType[rhs[3].toString()]);
        else if (prop == "CorrectionForInclusion")
            obj->setCorrectionForInclusion(rhs[3].toBool());
        else if (prop == "Radius")
            obj->setRadius(rhs[3].toInt());
        else if (prop == "TrimRatio")
            obj->setTrimRatio(rhs[3].toFloat());
        else if (prop == "EstimateTrimRatio")
            obj->setEstimateTrimRatio(rhs[3].toBool());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
