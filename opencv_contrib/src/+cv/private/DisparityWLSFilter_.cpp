/**
 * @file DisparityWLSFilter_.cpp
 * @brief mex interface for cv::ximgproc::DisparityWLSFilter
 * @ingroup ximgproc
 * @author Amro
 * @date 2016
 */
#include "mexopencv.hpp"
#include "opencv2/ximgproc.hpp"
#include <typeinfo>
using namespace std;
using namespace cv;
using namespace cv::ximgproc;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<DisparityWLSFilter> > obj_;

/// Option values for StereoBM PreFilterType
const ConstMap<string, int> PreFilerTypeMap = ConstMap<string, int>
    ("NormalizedResponse", cv::StereoBM::PREFILTER_NORMALIZED_RESPONSE)
    ("XSobel",             cv::StereoBM::PREFILTER_XSOBEL);

/// Option values for StereoSGBM mode
const ConstMap<string, int> SGBMModeMap = ConstMap<string, int>
    ("SGBM",     cv::StereoSGBM::MODE_SGBM)
    ("HH",       cv::StereoSGBM::MODE_HH)
    ("SGBM3Way", cv::StereoSGBM::MODE_SGBM_3WAY)
    ("HH4",      cv::StereoSGBM::MODE_HH4);

/** Convert a StereoMatcher to MxArray
 * @param p smart poitner to an instance of cv::StereoMatcher
 * @return output MxArray structure
 */
MxArray toStruct(Ptr<StereoMatcher> p)
{
    MxArray s(MxArray::Struct());
    if (!p.empty()) {
        s.set("TypeId",            string(typeid(*p).name()));
        s.set("MinDisparity",      p->getMinDisparity());
        s.set("NumDisparities",    p->getNumDisparities());
        s.set("BlockSize",         p->getBlockSize());
        s.set("SpeckleWindowSize", p->getSpeckleWindowSize());
        s.set("SpeckleRange",      p->getSpeckleRange());
        s.set("Disp12MaxDiff",     p->getDisp12MaxDiff());
        {
            Ptr<StereoBM> pp = p.dynamicCast<StereoBM>();
            if (!pp.empty()) {
                s.set("PreFilterType",    pp->getPreFilterType());
                s.set("PreFilterSize",    pp->getPreFilterSize());
                s.set("PreFilterCap",     pp->getPreFilterCap());
                s.set("TextureThreshold", pp->getTextureThreshold());
                s.set("UniquenessRatio",  pp->getUniquenessRatio());
                s.set("SmallerBlockSize", pp->getSmallerBlockSize());
                s.set("ROI1",             pp->getROI1());
                s.set("ROI2",             pp->getROI2());
            }
        }
        {
            Ptr<StereoSGBM> pp = p.dynamicCast<StereoSGBM>();
            if (!pp.empty()) {
                s.set("PreFilterCap",    pp->getPreFilterCap());
                s.set("UniquenessRatio", pp->getUniquenessRatio());
                s.set("P1",              pp->getP1());
                s.set("P2",              pp->getP2());
                s.set("Mode",            pp->getMode());
            }
        }
    }
    return s;
}

/** Create an instance of StereoBM using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created StereoBM
 */
Ptr<StereoBM> create_StereoBM(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    int numDisparities = 0;
    int blockSize = 21;
    int minDisparity = 0;
    int speckleWindowSize = 0;
    int speckleRange = 0;
    int disp12MaxDiff = -1;
    int preFilterType = cv::StereoBM::PREFILTER_XSOBEL;
    int preFilterSize = 9;
    int preFilterCap = 31;
    int textureThreshold = 10;
    int uniquenessRatio = 15;
    int smallerBlockSize = 0;
    Rect roi1;
    Rect roi2;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "NumDisparities")
            numDisparities = val.toInt();
        else if (key == "BlockSize")
            blockSize = val.toInt();
        else if (key == "MinDisparity")
            minDisparity = val.toInt();
        else if (key == "SpeckleWindowSize")
            speckleWindowSize = val.toInt();
        else if (key == "SpeckleRange")
            speckleRange = val.toInt();
        else if (key == "Disp12MaxDiff")
            disp12MaxDiff = val.toInt();
        else if (key == "PreFilterType")
            preFilterType = (val.isChar() ?
                PreFilerTypeMap[val.toString()] : val.toInt());
        else if (key == "PreFilterSize")
            preFilterSize = val.toInt();
        else if (key == "PreFilterCap")
            preFilterCap = val.toInt();
        else if (key == "TextureThreshold")
            textureThreshold = val.toInt();
        else if (key == "UniquenessRatio")
            uniquenessRatio = val.toInt();
        else if (key == "SmallerBlockSize")
            smallerBlockSize = val.toInt();
        else if (key == "ROI1")
            roi1 = val.toRect();
        else if (key == "ROI2")
            roi2 = val.toRect();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    Ptr<StereoBM> p = StereoBM::create(numDisparities, blockSize);
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error", "Failed to create StereoBM");
    p->setMinDisparity(minDisparity);
    p->setSpeckleWindowSize(speckleWindowSize);
    p->setSpeckleRange(speckleRange);
    p->setDisp12MaxDiff(disp12MaxDiff);
    p->setPreFilterType(preFilterType);
    p->setPreFilterSize(preFilterSize);
    p->setPreFilterCap(preFilterCap);
    p->setTextureThreshold(textureThreshold);
    p->setUniquenessRatio(uniquenessRatio);
    p->setSmallerBlockSize(smallerBlockSize);
    p->setROI1(roi1);
    p->setROI2(roi2);
    return p;
}

/** Create an instance of StereoSGBM using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created StereoSGBM
 */
Ptr<StereoSGBM> create_StereoSGBM(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    int minDisparity = 0;
    int numDisparities = 16;
    int blockSize = 3;
    int P1 = 0;
    int P2 = 0;
    int disp12MaxDiff = 0;
    int preFilterCap = 0;
    int uniquenessRatio = 0;
    int speckleWindowSize = 0;
    int speckleRange = 0;
    int mode = cv::StereoSGBM::MODE_SGBM;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "MinDisparity")
            minDisparity = val.toInt();
        else if (key == "NumDisparities")
            numDisparities = val.toInt();
        else if (key == "BlockSize")
            blockSize = val.toInt();
        else if (key == "P1")
            P1 = val.toInt();
        else if (key == "P2")
            P2 = val.toInt();
        else if (key == "Disp12MaxDiff")
            disp12MaxDiff = val.toInt();
        else if (key == "PreFilterCap")
            preFilterCap = val.toInt();
        else if (key == "UniquenessRatio")
            uniquenessRatio = val.toInt();
        else if (key == "SpeckleWindowSize")
            speckleWindowSize = val.toInt();
        else if (key == "SpeckleRange")
            speckleRange = val.toInt();
        else if (key == "Mode")
            mode = (val.isChar() ?
                SGBMModeMap[val.toString()] : val.toInt());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return StereoSGBM::create(minDisparity, numDisparities,
        blockSize, P1, P2, disp12MaxDiff, preFilterCap, uniquenessRatio,
        speckleWindowSize, speckleRange, mode);
}

/** Create an instance of StereoMatcher using options in arguments
 * @param type stereo matcher type, one of:
 *    - "StereoBM"
 *    - "StereoSGBM"
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created StereoMatcher
 */
Ptr<StereoMatcher> create_StereoMatcher(
    const string& type,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    Ptr<StereoMatcher> p;
    if (type == "StereoBM")
        p = create_StereoBM(first, last);
    else if (type == "StereoSGBM")
        p = create_StereoSGBM(first, last);
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized stereo matcher %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create StereoMatcher");
    return p;
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

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        nargchk(nrhs==3 && nlhs<=1);
        if (rhs[2].isLogicalScalar()) {
            bool use_confidence = rhs[2].toBool();
            obj_[++last_id] = createDisparityWLSFilterGeneric(use_confidence);
        }
        else {
            vector<MxArray> args(rhs[2].toVector<MxArray>());
            nargchk(args.size() >= 1);
            Ptr<StereoMatcher> matcher_left = create_StereoMatcher(
                args[0].toString(), args.begin() + 1, args.end());
            obj_[++last_id] = createDisparityWLSFilter(matcher_left);
        }
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }
    // static methods calls
    else if (method == "createRightMatcher") {
        nargchk(nrhs==3 && nlhs<=1);
        vector<MxArray> args(rhs[2].toVector<MxArray>());
        nargchk(args.size() >= 1);
        Ptr<StereoMatcher> matcher_left = create_StereoMatcher(
            args[0].toString(), args.begin() + 1, args.end());
        Ptr<StereoMatcher> matcher_right = createRightMatcher(matcher_left);
        plhs[0] = toStruct(matcher_right);
        return;
    }
    else if (method == "readGT") {
        nargchk(nrhs==3 && nlhs<=1);
        Mat dst;
        int code = readGT(rhs[2].toString(), dst);
        if (code != 0)
            mexErrMsgIdAndTxt("mexopencv:error",
                "Failed to read ground-truth disparity map");
        plhs[0] = MxArray(dst);
        return;
    }
    else if (method == "computeMSE") {
        nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=1);
        Rect ROI;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "ROI")
                ROI = rhs[i+1].toRect();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat GT(rhs[2].toMat(rhs[2].isInt16() ? CV_16S : CV_32F)),
            src(rhs[3].toMat(rhs[3].isInt16() ? CV_16S : CV_32F));
        if (ROI.area() == 0)
            ROI = Rect(0, 0, src.cols, src.rows);
        double mse = computeMSE(GT, src, ROI);
        plhs[0] = MxArray(mse);
        return;
    }
    else if (method == "computeBadPixelPercent") {
        nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=1);
        Rect ROI;
        int thresh = 24;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "ROI")
                ROI = rhs[i+1].toRect();
            else if (key == "Thresh")
                thresh = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat GT(rhs[2].toMat(rhs[2].isInt16() ? CV_16S : CV_32F)),
            src(rhs[3].toMat(rhs[3].isInt16() ? CV_16S : CV_32F));
        if (ROI.area() == 0)
            ROI = Rect(0, 0, src.cols, src.rows);
        double prcnt = computeBadPixelPercent(GT, src, ROI, thresh);
        plhs[0] = MxArray(prcnt);
        return;
    }
    else if (method == "getDisparityVis") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        double scale = 1.0;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Scale")
                scale = rhs[i+1].toDouble();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat src(rhs[2].toMat(rhs[2].isInt16() ? CV_16S : CV_32F)),
            dst;
        getDisparityVis(src, dst, scale);
        plhs[0] = MxArray(dst);
        return;
    }

    // Big operation switch
    Ptr<DisparityWLSFilter> obj = obj_[id];
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
            Algorithm::loadFromString<DisparityWLSFilter>(rhs[2].toString(), objname) :
            Algorithm::load<DisparityWLSFilter>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing DisparityWLSFilter::create()
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
    else if (method == "filter") {
        nargchk(nrhs>=5 && (nrhs%2)==1 && nlhs<=1);
        Rect ROI;
        Mat right_view;
        for (int i=5; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "ROI")
                ROI = rhs[i+1].toRect();
            else if (key == "RightView")
                right_view = rhs[i+1].toMat(CV_8U);
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat disparity_map_left(rhs[2].toMat(rhs[2].isInt16() ? CV_16S : CV_32F)),
            disparity_map_right(rhs[3].toMat(rhs[3].isInt16() ? CV_16S : CV_32F)),
            left_view(rhs[4].toMat(CV_8U)),
            filtered_disparity_map;
        obj->filter(disparity_map_left, left_view, filtered_disparity_map,
            disparity_map_right, ROI, right_view);
        plhs[0] = MxArray(filtered_disparity_map);
    }
    else if (method == "getConfidenceMap") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getConfidenceMap());
    }
    else if (method == "getROI") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getROI());
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "Lambda")
            plhs[0] = MxArray(obj->getLambda());
        else if (prop == "SigmaColor")
            plhs[0] = MxArray(obj->getSigmaColor());
        else if (prop == "LRCthresh")
            plhs[0] = MxArray(obj->getLRCthresh());
        else if (prop == "DepthDiscontinuityRadius")
            plhs[0] = MxArray(obj->getDepthDiscontinuityRadius());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "Lambda")
            obj->setLambda(rhs[3].toDouble());
        else if (prop == "SigmaColor")
            obj->setSigmaColor(rhs[3].toDouble());
        else if (prop == "LRCthresh")
            obj->setLRCthresh(rhs[3].toInt());
        else if (prop == "DepthDiscontinuityRadius")
            obj->setDepthDiscontinuityRadius(rhs[3].toInt());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
