/** Implementation of mexopencv_videostab.
 * @file mexopencv_videostab.cpp
 * @ingroup videostab
 * @author Amro
 * @date 2016
 */

#include "mexopencv_videostab.hpp"
#include <typeinfo>
#include <cstdio>
#include <cstdarg>
using std::vector;
using std::string;
using std::const_mem_fun_ref_t;
using namespace cv;
using namespace cv::videostab;


// ==================== XXX ====================

/// inpainting algorithm types for option processing
const ConstMap<string, int> InpaintingAlgMap = ConstMap<string, int>
    ("NS",    cv::INPAINT_NS)
    ("Telea", cv::INPAINT_TELEA);

// HACK: mexPrintf doesn't correctly handle "%s" formatted messages when
// directly passing variadic to it. So we use vsnprintf first with a buffer,
// then pass the buffer to mexPrintf.
void LogToMATLAB::print(const char *format, ...)
{
    // buffer
    const int BUFSIZE = 255;
    char buffer[BUFSIZE+1];

    // print formatted message to buffer
    va_list args;
    va_start(args, format);
    vsnprintf(buffer, BUFSIZE, format, args);
    va_end(args);

    // print buffered message in MATLAB
    buffer[BUFSIZE] = '\0';
    mexPrintf(buffer);

    //TODO: flush
}

RansacParams toRansacParams(const MxArray &arr)
{
    return RansacParams(
        arr.at("Size").toInt(),
        arr.at("Thresh").toFloat(),
        arr.at("Eps").toFloat(),
        arr.at("Prob").toFloat());
}

MxArray toStruct(const RansacParams &params)
{
    MxArray s(MxArray::Struct());
    s.set("Size",   params.size);
    s.set("Thresh", params.thresh);
    s.set("Eps",    params.eps);
    s.set("Prob",   params.prob);
    return s;
}


// ==================== XXX ====================

MxArray toStruct(Ptr<ILog> p)
{
    MxArray s(MxArray::Struct());
    if (!p.empty())
        s.set("TypeId", string(typeid(*p).name()));
    return s;
}

MxArray toStruct(Ptr<IFrameSource> p)
{
    MxArray s(MxArray::Struct());
    if (!p.empty()) {
        s.set("TypeId", string(typeid(*p).name()));
        Ptr<VideoFileSource> pp = p.dynamicCast<VideoFileSource>();
        if (!pp.empty()) {
            s.set("Width",  pp->width());
            s.set("Height", pp->height());
            s.set("FPS",    pp->fps());
            s.set("Count",  pp->count());
        }
    }
    return s;
}

MxArray toStruct(Ptr<DeblurerBase> p)
{
    MxArray s(MxArray::Struct());
    if (!p.empty()) {
        s.set("TypeId", string(typeid(*p).name()));
        s.set("Radius", p->radius());
        // Frames, Motions, BlurrinessRates: data from stabilizer
        Ptr<WeightingDeblurer> pp = p.dynamicCast<WeightingDeblurer>();
        if (!pp.empty()) {
            s.set("Sensitivity", pp->sensitivity());
        }
    }
    return s;
}

MxArray toStruct(Ptr<MotionEstimatorBase> p)
{
    MxArray s(MxArray::Struct());
    if (!p.empty()) {
        s.set("TypeId",      string(typeid(*p).name()));
        s.set("MotionModel", MotionModelInvMap[p->motionModel()]);
        {
            Ptr<MotionEstimatorRansacL2> pp =
                p.dynamicCast<MotionEstimatorRansacL2>();
            if (!pp.empty()) {
                s.set("RansacParams",   toStruct(pp->ransacParams()));
                s.set("MinInlierRatio", pp->minInlierRatio());
            }
        }
    }
    return s;
}

MxArray toStruct(Ptr<FeatureDetector> p)
{
    MxArray s(MxArray::Struct());
    if (!p.empty()) {
        s.set("TypeId", string(typeid(*p).name()));
        //TODO: check each derived FeatureDetector, and return its props
    }
    return s;
}

MxArray toStruct(Ptr<ISparseOptFlowEstimator> p)
{
    MxArray s(MxArray::Struct());
    if (!p.empty()) {
        s.set("TypeId", string(typeid(*p).name()));
        Ptr<SparsePyrLkOptFlowEstimator> pp =
            p.dynamicCast<SparsePyrLkOptFlowEstimator>();
        if (!pp.empty()) {
            s.set("WinSize",  pp->winSize());
            s.set("MaxLevel", pp->maxLevel());
        }
    }
    return s;
}

MxArray toStruct(Ptr<IDenseOptFlowEstimator> p)
{
    MxArray s(MxArray::Struct());
    if (!p.empty()) {
        s.set("TypeId", string(typeid(*p).name()));
        //TODO: no CPU version, only CUDA
        /*
        Ptr<DensePyrLkOptFlowEstimatorGpu> pp =
            p.dynamicCast<DensePyrLkOptFlowEstimatorGpu>();
        if (!pp.empty()) {
            s.set("WinSize",  pp->winSize());
            s.set("MaxLevel", pp->maxLevel());
        }
        */
    }
    return s;
}

MxArray toStruct(Ptr<IOutlierRejector> p)
{
    MxArray s(MxArray::Struct());
    if (!p.empty()) {
        s.set("TypeId", string(typeid(*p).name()));
        Ptr<TranslationBasedLocalOutlierRejector> pp =
            p.dynamicCast<TranslationBasedLocalOutlierRejector>();
        if (!pp.empty()) {
            s.set("CellSize",     pp->cellSize());
            s.set("RansacParams", toStruct(pp->ransacParams()));
        }
    }
    return s;
}

MxArray toStruct(Ptr<ImageMotionEstimatorBase> p)
{
    MxArray s(MxArray::Struct());
    if (!p.empty()) {
        s.set("TypeId",      string(typeid(*p).name()));
        s.set("MotionModel", MotionModelInvMap[p->motionModel()]);
        Ptr<KeypointBasedMotionEstimator> pp =
            p.dynamicCast<KeypointBasedMotionEstimator>();
        if (!pp.empty()) {
            s.set("Detector",             toStruct(pp->detector()));             // Ptr<FeatureDetector>
            s.set("OpticalFlowEstimator", toStruct(pp->opticalFlowEstimator())); // Ptr<ISparseOptFlowEstimator>
            s.set("OutlierRejector",      toStruct(pp->outlierRejector()));      // Ptr<IOutlierRejector>
        }
    }
    return s;
}

MxArray toStruct(Ptr<InpainterBase> p)
{
    MxArray s(MxArray::Struct());
    if (!p.empty()) {
        s.set("TypeId",      string(typeid(*p).name()));
        s.set("MotionModel", MotionModelInvMap[p->motionModel()]);
        s.set("Radius",      p->radius());
        // Frames, Motions, StabilizedFrames, StabilizationMotions: data from stabilizer
        {
            Ptr<ConsistentMosaicInpainter> pp =
                p.dynamicCast<ConsistentMosaicInpainter>();
            if (!pp.empty())
                s.set("StdevThresh", pp->stdevThresh());
        }
        {
            Ptr<MotionInpainter> pp = p.dynamicCast<MotionInpainter>();
            if (!pp.empty()) {
                s.set("FlowErrorThreshold", pp->flowErrorThreshold());
                s.set("DistThresh",         pp->distThresh());
                s.set("BorderMode",         BorderTypeInv[pp->borderMode()]);
                s.set("OptFlowEstimator",   toStruct(pp->optFlowEstimator())); // Ptr<IDenseOptFlowEstimator>
            }
        }
        {
            Ptr<InpaintingPipeline> pp = p.dynamicCast<InpaintingPipeline>();
            if (!pp.empty())
                s.set("Empty", pp->empty());
        }
    }
    return s;
}

MxArray toStruct(Ptr<MotionFilterBase> p)
{
    MxArray s(MxArray::Struct());
    if (!p.empty()) {
        s.set("TypeId", string(typeid(*p).name()));
        Ptr<GaussianMotionFilter> pp = p.dynamicCast<GaussianMotionFilter>();
        if (!pp.empty()) {
            s.set("Radius", pp->radius());
            s.set("Stdev",  pp->stdev());
        }
    }
    return s;
}

MxArray toStruct(Ptr<IMotionStabilizer> p)
{
    MxArray s(MxArray::Struct());
    if (!p.empty()) {
        s.set("TypeId", string(typeid(*p).name()));
        {
            Ptr<LpMotionStabilizer> pp = p.dynamicCast<LpMotionStabilizer>();
            if (!pp.empty()) {
                s.set("MotionModel", MotionModelInvMap[pp->motionModel()]);
                s.set("FrameSize",   pp->frameSize());
                s.set("TrimRatio",   pp->trimRatio());
                s.set("Weight1",     pp->weight1());
                s.set("Weight2",     pp->weight2());
                s.set("Weight3",     pp->weight3());
                s.set("Weight4",     pp->weight4());
            }
        }
        {
            Ptr<GaussianMotionFilter> pp = p.dynamicCast<GaussianMotionFilter>();
            if (!pp.empty()) {
                s.set("Radius", pp->radius());
                s.set("Stdev",  pp->stdev());
            }
        }
        {
            Ptr<MotionStabilizationPipeline> pp =
                p.dynamicCast<MotionStabilizationPipeline>();
            if (!pp.empty())
                s.set("Empty", pp->empty());
        }
    }
    return s;
}

MxArray toStruct(Ptr<WobbleSuppressorBase> p)
{
    MxArray s(MxArray::Struct());
    if (!p.empty()) {
        s.set("TypeId",          string(typeid(*p).name()));
        s.set("MotionEstimator", toStruct(p->motionEstimator())); // Ptr<ImageMotionEstimatorBase>
        // FrameCount, Motions, Motions2, StabilizationMotions: data from stabilizer
        Ptr<MoreAccurateMotionWobbleSuppressorBase> pp =
            p.dynamicCast<MoreAccurateMotionWobbleSuppressorBase>();
        if (!pp.empty())
            s.set("Period", pp->period());
    }
    return s;
}


// ==================== XXX ====================

Ptr<ILog> createILog(const string& type)
{
    Ptr<ILog> p;
    if (type == "LogToMATLAB")
        p = makePtr<LogToMATLAB>();
    else if (type == "LogToStdout")
        p = makePtr<LogToStdout>();
    else if (type == "NullLog")
        p = makePtr<NullLog>();
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized logger type %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create ILog");
    return p;
}

Ptr<VideoFileSource> createVideoFileSource(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk(len>=1 && (len%2)==1);
    string path(first->toString()); ++first;
    bool volatileFrame = false;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "VolatileFrame")
            volatileFrame = val.toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return makePtr<VideoFileSource>(path, volatileFrame);
}

Ptr<IFrameSource> createIFrameSource(
    const string& type,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    Ptr<IFrameSource> p;
    if (type == "VideoFileSource")
        p = createVideoFileSource(first, last);
    else if (type == "NullFrameSource") {
        nargchk(len==0);
        p = makePtr<NullFrameSource>();
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized frame source %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create IFrameSource");
    return p;
}

Ptr<WeightingDeblurer> createWeightingDeblurer(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    Ptr<WeightingDeblurer> p = makePtr<WeightingDeblurer>();
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create WeightingDeblurer");
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        // Frames, Motions, BlurrinessRates: data from stabilizer
        if (key == "Radius")
            p->setRadius(val.toInt());
        else if (key == "Sensitivity")
            p->setSensitivity(val.toFloat());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return p;
}

Ptr<DeblurerBase> createDeblurerBase(
    const string& type,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    Ptr<DeblurerBase> p;
    if (type == "WeightingDeblurer")
        p = createWeightingDeblurer(first, last);
    else if (type == "NullDeblurer") {
        nargchk(len==3);
        p = makePtr<NullDeblurer>();
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized deblurer %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create DeblurerBase");
    return p;
}

Ptr<MotionEstimatorL1> createMotionEstimatorL1(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    MotionModel model = cv::videostab::MM_AFFINE;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "MotionModel")
            model = MotionModelMap[val.toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return makePtr<MotionEstimatorL1>(model);
}

Ptr<MotionEstimatorRansacL2> createMotionEstimatorRansacL2(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    MotionModel model = cv::videostab::MM_AFFINE;
    RansacParams ransacParams = RansacParams::default2dMotion(model);
    float minInlierRatio = 0.1f;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "MotionModel")
            model = MotionModelMap[val.toString()];
        else if (key == "RansacParams")
            ransacParams = (val.isStruct() ? toRansacParams(val) :
                RansacParams::default2dMotion(MotionModelMap[val.toString()]));
        else if (key == "MinInlierRatio")
            minInlierRatio = val.toFloat();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    Ptr<MotionEstimatorRansacL2> p = makePtr<MotionEstimatorRansacL2>(model);
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create MotionEstimatorRansacL2");
    p->setRansacParams(ransacParams);
    p->setMinInlierRatio(minInlierRatio);
    return p;
}

Ptr<MotionEstimatorBase> createMotionEstimatorBase(
    const string& type,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    Ptr<MotionEstimatorBase> p;
    if (type == "MotionEstimatorL1")
        p = createMotionEstimatorL1(first, last);
    else if (type == "MotionEstimatorRansacL2")
        p = createMotionEstimatorRansacL2(first, last);
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized motion estimator %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create MotionEstimatorBase");
    return p;
}

Ptr<SparsePyrLkOptFlowEstimator> createSparsePyrLkOptFlowEstimator(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    Ptr<SparsePyrLkOptFlowEstimator> p = makePtr<SparsePyrLkOptFlowEstimator>();
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create SparsePyrLkOptFlowEstimator");
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "WinSize")
            p->setWinSize(val.toSize());
        else if (key == "MaxLevel")
            p->setMaxLevel(val.toInt());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return p;
}

Ptr<ISparseOptFlowEstimator> createISparseOptFlowEstimator(
    const string& type,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    Ptr<ISparseOptFlowEstimator> p;
    if (type == "SparsePyrLkOptFlowEstimator")
        p = createSparsePyrLkOptFlowEstimator(first, last);
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized sparse optical flow estimator %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create ISparseOptFlowEstimator");
    return p;
}

Ptr<IDenseOptFlowEstimator> createIDenseOptFlowEstimator(
    const string& type,
    vector<MxArray>::const_iterator /*first*/,
    vector<MxArray>::const_iterator /*last*/)
{
    Ptr<IDenseOptFlowEstimator> p;
    if (type == "DensePyrLkOptFlowEstimatorGpu")
        // TODO: no CPU version, only CUDA
        ; //p = createDensePyrLkOptFlowEstimatorGpu(first, last);
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized dense optical flow estimator %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create IDenseOptFlowEstimator");
    return p;
}

Ptr<TranslationBasedLocalOutlierRejector> createTranslationBasedLocalOutlierRejector(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    Ptr<TranslationBasedLocalOutlierRejector> p =
        makePtr<TranslationBasedLocalOutlierRejector>();
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create TranslationBasedLocalOutlierRejector");
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "CellSize")
            p->setCellSize(val.toSize());
        else if (key == "RansacParams")
            p->setRansacParams((val.isStruct()) ? toRansacParams(val) :
                RansacParams::default2dMotion(MotionModelMap[val.toString()]));
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return p;
}

Ptr<IOutlierRejector> createIOutlierRejector(
    const string& type,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    Ptr<IOutlierRejector> p;
    if (type == "TranslationBasedLocalOutlierRejector")
        p = createTranslationBasedLocalOutlierRejector(first, last);
    else if (type == "NullOutlierRejector") {
        nargchk(len==0);
        p = makePtr<NullOutlierRejector>();
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized outlier rejector %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create IOutlierRejector");
    return p;
}

Ptr<KeypointBasedMotionEstimator> createKeypointBasedMotionEstimator(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk(len>=1 && (len%2)==1);
    Ptr<KeypointBasedMotionEstimator> p;
    {
        vector<MxArray> args(first->toVector<MxArray>()); ++first;
        nargchk(args.size() >= 1);
        Ptr<MotionEstimatorBase> estimator = createMotionEstimatorBase(
            args[0].toString(), args.begin() + 1, args.end());
        p = makePtr<KeypointBasedMotionEstimator>(estimator);
    }
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create KeypointBasedMotionEstimator");
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "MotionModel")
            p->setMotionModel(MotionModelMap[val.toString()]);
        else if (key == "Detector") {
            vector<MxArray> args(val.toVector<MxArray>());
            nargchk(args.size() >= 1);
            Ptr<FeatureDetector> pp = createFeatureDetector(
                args[0].toString(), args.begin() + 1, args.end());
            p->setDetector(pp);
        }
        else if (key == "OpticalFlowEstimator") {
            vector<MxArray> args(val.toVector<MxArray>());
            nargchk(args.size() >= 1);
            Ptr<ISparseOptFlowEstimator> pp = createISparseOptFlowEstimator(
                args[0].toString(), args.begin() + 1, args.end());
            p->setOpticalFlowEstimator(pp);
        }
        else if (key == "OutlierRejector") {
            vector<MxArray> args(val.toVector<MxArray>());
            nargchk(args.size() >= 1);
            Ptr<IOutlierRejector> pp = createIOutlierRejector(
                args[0].toString(), args.begin() + 1, args.end());
            p->setOutlierRejector(pp);
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return p;
}

Ptr<FromFileMotionReader> createFromFileMotionReader(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk(len>=1 && (len%2)==1);
    string path(first->toString()); ++first;
    Ptr<FromFileMotionReader> p = makePtr<FromFileMotionReader>(path);
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create FromFileMotionReader");
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "MotionModel")
            p->setMotionModel(MotionModelMap[val.toString()]);
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return p;
}

Ptr<ToFileMotionWriter> createToFileMotionWriter(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk(len>=2 && (len%2)==0);
    Ptr<ToFileMotionWriter> p;
    {
        string path(first->toString()); ++first;
        vector<MxArray> args(first->toVector<MxArray>()); ++first;
        nargchk(args.size() >= 1);
        Ptr<ImageMotionEstimatorBase> estimator = createImageMotionEstimator(
                args[0].toString(), args.begin() + 1, args.end());
        p = makePtr<ToFileMotionWriter>(path, estimator);
    }
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create ToFileMotionWriter");
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "MotionModel")
            p->setMotionModel(MotionModelMap[val.toString()]);
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return p;
}

Ptr<ImageMotionEstimatorBase> createImageMotionEstimator(
    const string& type,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    Ptr<ImageMotionEstimatorBase> p;
    if (type == "KeypointBasedMotionEstimator")
        p = createKeypointBasedMotionEstimator(first, last);
    else if (type == "FromFileMotionReader")
        p = createFromFileMotionReader(first, last);
    else if (type == "ToFileMotionWriter")
        p = createToFileMotionWriter(first, last);
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized image motion estimator %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create ImageMotionEstimatorBase");
    return p;
}

Ptr<ColorInpainter> createColorInpainter(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    int method = cv::INPAINT_TELEA;
    double radius2 = 2.0;
    int radius = 0;
    MotionModel model = cv::videostab::MM_UNKNOWN;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        // Frames, Motions, StabilizedFrames, StabilizationMotions: data from stabilizer
        if (key == "Method")
            method = InpaintingAlgMap[val.toString()];
        else if (key == "Radius2")
            radius2 = val.toDouble();
        else if (key == "MotionModel")
            model = MotionModelMap[val.toString()];
        else if (key == "Radius")
            radius = val.toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    Ptr<ColorInpainter> p = makePtr<ColorInpainter>(method, radius2);
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create ColorInpainter");
    p->setMotionModel(model);
    p->setRadius(radius);
    return p;
}

Ptr<ColorAverageInpainter> createColorAverageInpainter(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    Ptr<ColorAverageInpainter> p = makePtr<ColorAverageInpainter>();
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create ColorAverageInpainter");
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        // Frames, Motions, StabilizedFrames, StabilizationMotions: data from stabilizer
        if (key == "MotionModel")
            p->setMotionModel(MotionModelMap[val.toString()]);
        else if (key == "Radius")
            p->setRadius(val.toInt());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return p;
}

Ptr<ConsistentMosaicInpainter> createConsistentMosaicInpainter(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    Ptr<ConsistentMosaicInpainter> p = makePtr<ConsistentMosaicInpainter>();
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create ConsistentMosaicInpainter");
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        // Frames, Motions, StabilizedFrames, StabilizationMotions: data from stabilizer
        if (key == "MotionModel")
            p->setMotionModel(MotionModelMap[val.toString()]);
        else if (key == "Radius")
            p->setRadius(val.toInt());
        else if (key == "StdevThresh")
            p->setStdevThresh(val.toFloat());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return p;
}

Ptr<MotionInpainter> createMotionInpainter(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    Ptr<MotionInpainter> p = makePtr<MotionInpainter>();
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create MotionInpainter");
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        // Frames, Motions, StabilizedFrames, StabilizationMotions: data from stabilizer
        if (key == "MotionModel")
            p->setMotionModel(MotionModelMap[val.toString()]);
        else if (key == "Radius")
            p->setRadius(val.toInt());
        else if (key == "FlowErrorThreshold")
            p->setFlowErrorThreshold(val.toFloat());
        else if (key == "DistThreshold")
            p->setDistThreshold(val.toFloat());
        else if (key == "BorderMode")
            p->setBorderMode(BorderType[val.toString()]);
        else if (key == "OptFlowEstimator") {
            vector<MxArray> args(val.toVector<MxArray>());
            nargchk(args.size() >= 1);
            Ptr<IDenseOptFlowEstimator> pp = createIDenseOptFlowEstimator(
                args[0].toString(), args.begin() + 1, args.end());
            p->setOptFlowEstimator(pp);
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return p;
}

Ptr<InpaintingPipeline> createInpaintingPipeline(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk(len>=1 && (len%2)==1);
    Ptr<InpaintingPipeline> p = makePtr<InpaintingPipeline>();
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create InpaintingPipeline");
    {
        vector<vector<MxArray> > inpainters(first->toVector(
            const_mem_fun_ref_t<vector<MxArray>, MxArray>(
            &MxArray::toVector<MxArray>))); ++first;
        for (vector<vector<MxArray> >::const_iterator it = inpainters.begin(); it != inpainters.end(); ++it) {
            nargchk(it->size() >= 1);
            Ptr<InpainterBase> inpainter = createInpainterBase(
                (*it)[0].toString(), it->begin() + 1, it->end());
            p->pushBack(inpainter);
        }
    }
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        // Frames, Motions, StabilizedFrames, StabilizationMotions: data from stabilizer
        if (key == "MotionModel")
            p->setMotionModel(MotionModelMap[val.toString()]);
        else if (key == "Radius")
            p->setRadius(val.toInt());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return p;
}

Ptr<InpainterBase> createInpainterBase(
    const string& type,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    Ptr<InpainterBase> p;
    if (type == "ColorInpainter")
        p = createColorInpainter(first, last);
    else if (type == "ColorAverageInpainter")
        p = createColorAverageInpainter(first, last);
    else if (type == "ConsistentMosaicInpainter")
        p = createConsistentMosaicInpainter(first, last);
    else if (type == "MotionInpainter")
        p = createMotionInpainter(first, last);
    else if (type == "InpaintingPipeline")
        p = createInpaintingPipeline(first, last);
    else if (type == "NullInpainter") {
        nargchk(len==0);
        p = makePtr<NullInpainter>();
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized inpainter %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create InpainterBase");
    return p;
}

Ptr<GaussianMotionFilter> createGaussianMotionFilter(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    int radius = 15;
    float stdev = -1.0f;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "Radius")
            radius = val.toInt();
        else if (key == "Stdev")
            stdev = val.toFloat();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return makePtr<GaussianMotionFilter>(radius, stdev);
}

Ptr<MotionFilterBase> createMotionFilterBase(
    const string& type,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    Ptr<MotionFilterBase> p;
    if (type == "GaussianMotionFilter")
        p = createGaussianMotionFilter(first, last);
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized motion filter %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create MotionFilterBase");
    return p;
}

Ptr<LpMotionStabilizer> createLpMotionStabilizer(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    Ptr<LpMotionStabilizer> p = makePtr<LpMotionStabilizer>();
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create LpMotionStabilizer");
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "MotionModel")
            p->setMotionModel(MotionModelMap[val.toString()]);
        else if (key == "FrameSize")
            p->setFrameSize(val.toSize());
        else if (key == "TrimRatio")
            p->setTrimRatio(val.toFloat());
        else if (key == "Weight1")
            p->setWeight1(val.toFloat());
        else if (key == "Weight2")
            p->setWeight2(val.toFloat());
        else if (key == "Weight3")
            p->setWeight3(val.toFloat());
        else if (key == "Weight4")
            p->setWeight4(val.toFloat());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return p;
}

Ptr<MotionStabilizationPipeline> createMotionStabilizationPipeline(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk(len==1);
    Ptr<MotionStabilizationPipeline> p = makePtr<MotionStabilizationPipeline>();
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create MotionStabilizationPipeline");
    {
        vector<vector<MxArray> > stabilizers(first->toVector(
            const_mem_fun_ref_t<vector<MxArray>, MxArray>(
            &MxArray::toVector<MxArray>))); ++first;
        for (vector<vector<MxArray> >::const_iterator it = stabilizers.begin(); it != stabilizers.end(); ++it) {
            nargchk(it->size() >= 1);
            Ptr<IMotionStabilizer> stabilizer = createIMotionStabilizer(
                (*it)[0].toString(), it->begin() + 1, it->end());
            p->pushBack(stabilizer);
        }
    }
    return p;
}

Ptr<IMotionStabilizer> createIMotionStabilizer(
    const string& type,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    Ptr<IMotionStabilizer> p;
    if (type == "LpMotionStabilizer")
        p = createLpMotionStabilizer(first, last);
    else if (type == "GaussianMotionFilter")
        p = createGaussianMotionFilter(first, last);
    else if (type == "MotionStabilizationPipeline")
        p = createMotionStabilizationPipeline(first, last);
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized motion stabilizer %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create IMotionStabilizer");
    return p;
}

Ptr<MoreAccurateMotionWobbleSuppressor> createMoreAccurateMotionWobbleSuppressor(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    Ptr<MoreAccurateMotionWobbleSuppressor> p =
        makePtr<MoreAccurateMotionWobbleSuppressor>();
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create MoreAccurateMotionWobbleSuppressor");
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        // FrameCount, Motions, Motions2, StabilizationMotions: data from stabilizer
        if (key == "MotionEstimator") {
            vector<MxArray> args(val.toVector<MxArray>());
            nargchk(args.size() >= 1);
            Ptr<ImageMotionEstimatorBase> pp = createImageMotionEstimator(
                args[0].toString(), args.begin() + 1, args.end());
            p->setMotionEstimator(pp);
        }
        else if (key == "Period")
            p->setPeriod(val.toInt());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return p;
}

Ptr<WobbleSuppressorBase> createWobbleSuppressorBase(
    const string& type,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    Ptr<WobbleSuppressorBase> p;
    if (type == "MoreAccurateMotionWobbleSuppressor")
        p = createMoreAccurateMotionWobbleSuppressor(first, last);
    else if (type == "NullWobbleSuppressor") {
        nargchk(len==0);
        p = makePtr<NullWobbleSuppressor>();
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized wobble suppressor %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create WobbleSuppressorBase");
    return p;
}
