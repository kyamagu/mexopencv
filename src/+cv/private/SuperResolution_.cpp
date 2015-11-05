/**
 * @file SuperResolution_.cpp
 * @brief mex interface for cv::superres::SuperResolution
 * @ingroup superres
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
#include "opencv2/superres.hpp"
#include <typeinfo>
using namespace std;
using namespace cv;
using namespace cv::superres;
// note ambiguity between: cv::DualTVL1OpticalFlow and cv::superres::DualTVL1OpticalFlow

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<SuperResolution> > obj_;

/** Create an instance of FrameSource using options in arguments
 * @param type frame source type, one of:
 *    - "Camera"
 *    - "Video"
 *    - "VideoCUDA" (requires CUDA)
 *    - "Empty"
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created FrameSource
 */
Ptr<FrameSource> createFrameSource(
    const string& type,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk(len==0 || len==1);
    Ptr<FrameSource> p;
    if (type == "Camera") {
        int deviceId = (len==1) ? first->toInt() : 0;
        p = createFrameSource_Camera(deviceId);
    }
    else if (type == "Video") {
        nargchk(len==1);
        string fileName(first->toString());
        p = createFrameSource_Video(fileName);
    }
    //TODO: CUDA
    //else if (type == "VideoCUDA") {
    //    nargchk(len==1);
    //    string fileName(first->toString());
    //    p = createFrameSource_Video_CUDA(fileName);
    //}
    //TODO: causes access violation
    //else if (type == "Empty") {
    //    nargchk(len==0);
    //    p = createFrameSource_Empty();
    //}
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized frame source %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create FrameSource of type %s", type.c_str());
    return p;
}

/** Create an instance of FarnebackOpticalFlow using options in arguments
 * @param use_gpu specify whether to use CPU or GPU implementation
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created cv::superres::FarnebackOpticalFlow
 */
Ptr<FarnebackOpticalFlow> createFarnebackOpticalFlow(
    bool use_gpu,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    Ptr<FarnebackOpticalFlow> p = (use_gpu) ?
        createOptFlow_Farneback_CUDA() :
        createOptFlow_Farneback();
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create FarnebackOpticalFlow");
    for (; first != last; first += 2) {
        string key((*first).toString());
        const MxArray& val = *(first + 1);
        if (key == "PyrScale")
            p->setPyrScale(val.toDouble());
        else if (key == "LevelsNumber")
            p->setLevelsNumber(val.toInt());
        else if (key == "WindowSize")
            p->setWindowSize(val.toInt());
        else if (key == "Iterations")
            p->setIterations(val.toInt());
        else if (key == "PolyN")
            p->setPolyN(val.toInt());
        else if (key == "PolySigma")
            p->setPolySigma(val.toDouble());
        else if (key == "Flags")
            p->setFlags(val.toInt());  //TODO: cv::OPTFLOW_FARNEBACK_GAUSSIAN
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return p;
}

/** Create an instance of DualTVL1OpticalFlow using options in arguments
 * @param use_gpu specify whether to use CPU or GPU implementation
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created cv::superres::DualTVL1OpticalFlow
 */
Ptr<superres::DualTVL1OpticalFlow> createDualTVL1OpticalFlow(
    bool use_gpu,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    Ptr<superres::DualTVL1OpticalFlow> p = (use_gpu) ?
        superres::createOptFlow_DualTVL1_CUDA() :
        superres::createOptFlow_DualTVL1();
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create DualTVL1OpticalFlow");
    for (; first != last; first += 2) {
        string key((*first).toString());
        const MxArray& val = *(first + 1);
        if (key == "Tau")
            p->setTau(val.toDouble());
        else if (key == "Lambda")
            p->setLambda(val.toDouble());
        else if (key == "Theta")
            p->setTheta(val.toDouble());
        else if (key == "ScalesNumber")
            p->setScalesNumber(val.toInt());
        else if (key == "WarpingsNumber")
            p->setWarpingsNumber(val.toInt());
        else if (key == "Epsilon")
            p->setEpsilon(val.toDouble());
        else if (key == "Iterations")
            p->setIterations(val.toInt());
        else if (key == "UseInitialFlow")
            p->setUseInitialFlow(val.toBool());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return p;
}

/** Create an instance of BroxOpticalFlow using options in arguments
 * @param use_gpu specify whether to use CPU or GPU implementation
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created cv::superres::BroxOpticalFlow
 */
Ptr<BroxOpticalFlow> createBroxOpticalFlow(
    bool /*use_gpu*/,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    Ptr<BroxOpticalFlow> p = superres::createOptFlow_Brox_CUDA();
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create BroxOpticalFlow");
    for (; first != last; first += 2) {
        string key((*first).toString());
        const MxArray& val = *(first + 1);
        if (key == "Alpha")
            p->setAlpha(val.toDouble());
        else if (key == "Gamma")
            p->setGamma(val.toDouble());
        else if (key == "ScaleFactor")
            p->setScaleFactor(val.toDouble());
        else if (key == "InnerIterations")
            p->setInnerIterations(val.toInt());
        else if (key == "OuterIterations")
            p->setOuterIterations(val.toInt());
        else if (key == "SolverIterations")
            p->setSolverIterations(val.toInt());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return p;
}

/** Create an instance of PyrLKOpticalFlow using options in arguments
 * @param use_gpu specify whether to use CPU or GPU implementation
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created cv::superres::PyrLKOpticalFlow
 */
Ptr<PyrLKOpticalFlow> createPyrLKOpticalFlow(
    bool /*use_gpu*/,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    Ptr<PyrLKOpticalFlow> p = superres::createOptFlow_PyrLK_CUDA();
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create PyrLKOpticalFlow");
    for (; first != last; first += 2) {
        string key((*first).toString());
        const MxArray& val = *(first + 1);
        if (key == "WindowSize")
            p->setWindowSize(val.toInt());
        else if (key == "MaxLevel")
            p->setMaxLevel(val.toInt());
        else if (key == "Iterations")
            p->setIterations(val.toInt());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return p;
}

/** Create an instance of DenseOpticalFlowExt using options in arguments
 * @param type dense optical flow type, one of:
 *    - "FarnebackOpticalFlow"
 *    - "DualTVL1OpticalFlow"
 *    - "FarnebackOpticalFlowCUDA" (requires CUDA)
 *    - "DualTVL1OpticalFlowCUDA" (requires CUDA)
 *    - "BroxOpticalFlowCUDA" (requires CUDA)
 *    - "PyrLKOpticalFlowCUDA" (requires CUDA)
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created DenseOpticalFlowExt
 */
Ptr<DenseOpticalFlowExt> createDenseOpticalFlowExt(
    const string& type,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    Ptr<DenseOpticalFlowExt> p;
    if (type == "FarnebackOpticalFlow")
        p = createFarnebackOpticalFlow(false, first, last);
    else if (type == "DualTVL1OpticalFlow")
        p = createDualTVL1OpticalFlow(false, first, last);
    else if (type == "FarnebackOpticalFlowCUDA")
        p = createFarnebackOpticalFlow(true, first, last);
    else if (type == "DualTVL1OpticalFlowCUDA")
        p = createDualTVL1OpticalFlow(true, first, last);
    else if (type == "BroxOpticalFlowCUDA")
        p = createBroxOpticalFlow(true, first, last);
    else if (type == "PyrLKOpticalFlowCUDA")
        p = createPyrLKOpticalFlow(true, first, last);
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized optical flow %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create DenseOpticalFlowExt of type %s", type.c_str());
    return p;
}

/** Create an instance of SuperResolution using options in arguments
 * @param type super resolution algorithm type, one of:
 *    - "BTVL1"
 *    - "BTVL1_CUDA" (requires CUDA)
 * @return smart pointer to created SuperResolution
 */
Ptr<SuperResolution> createSuperResolution(const string& type)
{
    Ptr<SuperResolution> p;
    if (type == "BTVL1")
        p = createSuperResolution_BTVL1();
    else if (type == "BTVL1_CUDA")
        p = createSuperResolution_BTVL1_CUDA();
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized super resolution %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create SuperResolution of type %s", type.c_str());
    return p;
}

/** Convert a DenseOpticalFlowExt to MxArray
 * @param p smart poitner to an instance of DenseOpticalFlowExt
 * @return output MxArray structure
 */
MxArray toStruct(Ptr<DenseOpticalFlowExt> p)
{
    MxArray s(MxArray::Struct());
    if (!p.empty()) {
        s.set("TypeId",                   string(typeid(*p).name()));
        {
            Ptr<FarnebackOpticalFlow> pp = p.dynamicCast<FarnebackOpticalFlow>();
            if (!pp.empty()) {
                s.set("PyrScale",         pp->getPyrScale());
                s.set("LevelsNumber",     pp->getLevelsNumber());
                s.set("WindowSize",       pp->getWindowSize());
                s.set("Iterations",       pp->getIterations());
                s.set("PolyN",            pp->getPolyN());
                s.set("PolySigma",        pp->getPolySigma());
                s.set("Flags",            pp->getFlags());
            }
        }
        {
            Ptr<superres::DualTVL1OpticalFlow> pp = p.dynamicCast<superres::DualTVL1OpticalFlow>();
            if (!pp.empty()) {
                s.set("Tau",              pp->getTau());
                s.set("Lambda",           pp->getLambda());
                s.set("Theta",            pp->getTheta());
                s.set("ScalesNumber",     pp->getScalesNumber());
                s.set("WarpingsNumber",   pp->getWarpingsNumber());
                s.set("Epsilon",          pp->getEpsilon());
                s.set("Iterations",       pp->getIterations());
                s.set("UseInitialFlow",   pp->getUseInitialFlow());
            }
        }
        {
            Ptr<BroxOpticalFlow> pp = p.dynamicCast<BroxOpticalFlow>();
            if (!pp.empty()) {
                s.set("Alpha",            pp->getAlpha());
                s.set("Gamma",            pp->getGamma());
                s.set("ScaleFactor",      pp->getScaleFactor());
                s.set("InnerIterations",  pp->getInnerIterations());
                s.set("OuterIterations",  pp->getOuterIterations());
                s.set("SolverIterations", pp->getSolverIterations());
            }
        }
        {
            Ptr<PyrLKOpticalFlow> pp = p.dynamicCast<PyrLKOpticalFlow>();
            if (!pp.empty()) {
                s.set("WindowSize",       pp->getWindowSize());
                s.set("MaxLevel",         pp->getMaxLevel());
                s.set("Iterations",       pp->getIterations());
            }
        }
    }
    return s;
}
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
        nargchk(nrhs==3 && nlhs<=1);
        obj_[++last_id] = createSuperResolution(rhs[2].toString());
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<SuperResolution> obj = obj_[id];
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
    }
    else if (method == "clear") {
        nargchk(nrhs==2 && nlhs==0);
        obj->clear();
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
            Algorithm::loadFromString<SuperResolution>(rhs[2].toString(), objname) :
            Algorithm::load<SuperResolution>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing SuperResolution::create()
        FileStorage fs(rhs[2].toString(), FileStorage::READ +
            (loadFromString ? FileStorage::MEMORY : 0));
        obj->read(objname.empty() ? fs.getFirstTopLevelNode() : fs[objname]);
        if (obj.empty())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to load algorithm");
        //*/
    }
    else if (method == "save") {
        nargchk(nrhs==3 && nlhs==0);
        obj->save(rhs[2].toString());
    }
    else if (method == "empty") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->empty());
    }
    else if (method == "getDefaultName") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getDefaultName());
    }
    else if (method == "collectGarbage") {
        nargchk(nrhs==2 && nlhs==0);
        obj->collectGarbage();
    }
    else if (method == "nextFrame") {
        nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);
        bool flip = true;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "FlipChannels")
                flip = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        Mat frame;
        obj->nextFrame(frame);
        if (flip && (frame.channels() == 3 || frame.channels() == 4)) {
            // OpenCV's default is BGR/BGRA while MATLAB's is RGB/RGBA
            cvtColor(frame, frame, (frame.channels()==3 ?
                cv::COLOR_BGR2RGB : cv::COLOR_BGRA2RGBA));
        }
        plhs[0] = MxArray(frame);
    }
    else if (method == "reset") {
        nargchk(nrhs==2 && nlhs==0);
        obj->reset();
    }
    else if (method == "setInput") {
        nargchk(nrhs>=3 && nlhs==0);
        Ptr<FrameSource> p = createFrameSource(
            rhs[2].toString(), rhs.begin() + 3, rhs.end());
        obj->setInput(p);
    }
    else if (method == "setOpticalFlow") {
        nargchk(nrhs>=3 && nlhs==0);
        Ptr<DenseOpticalFlowExt> p = createDenseOpticalFlowExt(
            rhs[2].toString(), rhs.begin() + 3, rhs.end());
        obj->setOpticalFlow(p);
    }
    else if (method == "getOpticalFlow") {
        nargchk(nrhs==2 && nlhs<=1);
        Ptr<DenseOpticalFlowExt> p = obj->getOpticalFlow();
        plhs[0] = toStruct(p);
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "Alpha")
            plhs[0] = MxArray(obj->getAlpha());
        else if (prop == "BlurKernelSize")
            plhs[0] = MxArray(obj->getBlurKernelSize());
        else if (prop == "BlurSigma")
            plhs[0] = MxArray(obj->getBlurSigma());
        else if (prop == "Iterations")
            plhs[0] = MxArray(obj->getIterations());
        else if (prop == "KernelSize")
            plhs[0] = MxArray(obj->getKernelSize());
        else if (prop == "Labmda")
            plhs[0] = MxArray(obj->getLabmda());
        else if (prop == "Scale")
            plhs[0] = MxArray(obj->getScale());
        else if (prop == "Tau")
            plhs[0] = MxArray(obj->getTau());
        else if (prop == "TemporalAreaRadius")
            plhs[0] = MxArray(obj->getTemporalAreaRadius());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "Alpha")
            obj->setAlpha(rhs[3].toDouble());
        else if (prop == "BlurKernelSize")
            obj->setBlurKernelSize(rhs[3].toInt());
        else if (prop == "BlurSigma")
            obj->setBlurSigma(rhs[3].toDouble());
        else if (prop == "Iterations")
            obj->setIterations(rhs[3].toInt());
        else if (prop == "KernelSize")
            obj->setKernelSize(rhs[3].toInt());
        else if (prop == "Labmda")
            obj->setLabmda(rhs[3].toDouble());
        else if (prop == "Scale")
            obj->setScale(rhs[3].toInt());
        else if (prop == "Tau")
            obj->setTau(rhs[3].toDouble());
        else if (prop == "TemporalAreaRadius")
            obj->setTemporalAreaRadius(rhs[3].toInt());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
