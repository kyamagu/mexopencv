/** Implementation of mexopencv_stitching.
 * @file mexopencv_stitching.cpp
 * @ingroup stitching
 * @author Amro
 * @date 2016
 */

#include "mexopencv_stitching.hpp"
#include <typeinfo>
using std::vector;
using std::string;
using namespace cv;
using namespace cv::detail;


// ==================== XXX ====================

/// KAZE Diffusivity type
const ConstMap<string, int> KAZEDiffusivityType = ConstMap<string, int>
    ("PM_G1",       cv::KAZE::DIFF_PM_G1)
    ("PM_G2",       cv::KAZE::DIFF_PM_G2)
    ("WEICKERT",    cv::KAZE::DIFF_WEICKERT)
    ("CHARBONNIER", cv::KAZE::DIFF_CHARBONNIER);

/// AKAZE descriptor type
const ConstMap<string, int> AKAZEDescriptorType = ConstMap<string, int>
    ("KAZEUpright", cv::AKAZE::DESCRIPTOR_KAZE_UPRIGHT)
    ("KAZE",        cv::AKAZE::DESCRIPTOR_KAZE)
    ("MLDBUpright", cv::AKAZE::DESCRIPTOR_MLDB_UPRIGHT)
    ("MLDB",        cv::AKAZE::DESCRIPTOR_MLDB);


// ==================== XXX ====================

ImageFeatures MxArrayToImageFeatures(const MxArray &arr, mwIndex idx)
{
    ImageFeatures feat;
    feat.img_idx   = arr.at("img_idx", idx).toInt();
    feat.img_size  = arr.at("img_size", idx).toSize();
    feat.keypoints = arr.at("keypoints", idx).toVector<KeyPoint>();
    if (arr.isField("descriptors")) {
        arr.at("descriptors", idx).toMat().copyTo(feat.descriptors);
    }
    return feat;
}

MatchesInfo MxArrayToMatchesInfo(const MxArray &arr, mwIndex idx)
{
    MatchesInfo matches_info;
    matches_info.src_img_idx  = arr.at("src_img_idx", idx).toInt();
    matches_info.dst_img_idx  = arr.at("dst_img_idx", idx).toInt();
    matches_info.matches      = arr.at("matches", idx).toVector<DMatch>();
    matches_info.inliers_mask = arr.at("inliers_mask", idx).toVector<uchar>();
    matches_info.num_inliers  = arr.at("num_inliers", idx).toInt();
    matches_info.H            = arr.at("H", idx).toMat();
    matches_info.confidence   = arr.at("confidence", idx).toDouble();
    return matches_info;
}

CameraParams MxArrayToCameraParams(const MxArray &arr, mwIndex idx)
{
    CameraParams params;
    params.aspect = arr.at("aspect", idx).toDouble();
    params.focal  = arr.at("focal", idx).toDouble();
    params.ppx    = arr.at("ppx", idx).toDouble();
    params.ppy    = arr.at("ppy", idx).toDouble();
    params.R      = arr.at("R", idx).toMat();  // CV_64F, CV_32F
    params.t      = arr.at("t", idx).toMat();  // CV_64F, CV_32F
    return params;
}

vector<ImageFeatures> MxArrayToVectorImageFeatures(const MxArray &arr)
{
    const mwSize n = arr.numel();
    vector<ImageFeatures> v;
    v.reserve(n);
    if (arr.isCell())
        for (mwIndex i = 0; i < n; ++i)
            v.push_back(MxArrayToImageFeatures(arr.at<MxArray>(i)));
    else if (arr.isStruct())
        for (mwIndex i = 0; i < n; ++i)
            v.push_back(MxArrayToImageFeatures(arr, i));
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "MxArray unable to convert to vector<cv::detail::ImageFeatures>");
    return v;
}

vector<MatchesInfo> MxArrayToVectorMatchesInfo(const MxArray &arr)
{
    const mwSize n = arr.numel();
    vector<MatchesInfo> v;
    v.reserve(n);
    if (arr.isCell())
        for (mwIndex i = 0; i < n; ++i)
            v.push_back(MxArrayToMatchesInfo(arr.at<MxArray>(i)));
    else if (arr.isStruct())
        for (mwIndex i = 0; i < n; ++i)
            v.push_back(MxArrayToMatchesInfo(arr, i));
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "MxArray unable to convert to vector<cv::detail::MatchesInfo>");
    return v;
}

vector<CameraParams> MxArrayToVectorCameraParams(const MxArray &arr)
{
    const mwSize n = arr.numel();
    vector<CameraParams> v;
    v.reserve(n);
    if (arr.isCell())
        for (mwIndex i = 0; i < n; ++i)
            v.push_back(MxArrayToCameraParams(arr.at<MxArray>(i)));
    else if (arr.isStruct())
        for (mwIndex i = 0; i < n; ++i)
            v.push_back(MxArrayToCameraParams(arr, i));
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "MxArray unable to convert to vector<cv::detail::CameraParams>");
    return v;
}

MxArray toStruct(const ImageFeatures &feat)
{
    const char *fields[] = {"img_idx", "img_size", "keypoints", "descriptors"};
    MxArray s = MxArray::Struct(fields, 4);
    s.set("img_idx",     feat.img_idx);
    s.set("img_size",    feat.img_size);
    s.set("keypoints",   feat.keypoints);
    s.set("descriptors", feat.descriptors.getMat(ACCESS_READ));
    return s;
}

MxArray toStruct(const vector<ImageFeatures> &features)
{
    const char *fields[] = {"img_idx", "img_size", "keypoints", "descriptors"};
    MxArray s = MxArray::Struct(fields, 4, 1, features.size());
    for (mwIndex i = 0; i < features.size(); ++i) {
        s.set("img_idx",     features[i].img_idx,                         i);
        s.set("img_size",    features[i].img_size,                        i);
        s.set("keypoints",   features[i].keypoints,                       i);
        s.set("descriptors", features[i].descriptors.getMat(ACCESS_READ), i);
    }
    return s;
}

MxArray toStruct(const MatchesInfo &matches_info)
{
    const char *fields[] = {"src_img_idx", "dst_img_idx", "matches",
        "inliers_mask", "num_inliers", "H", "confidence"};
    MxArray s = MxArray::Struct(fields, 7);
    s.set("src_img_idx",  matches_info.src_img_idx);
    s.set("dst_img_idx",  matches_info.dst_img_idx);
    s.set("matches",      matches_info.matches);
    s.set("inliers_mask", matches_info.inliers_mask);
    s.set("num_inliers",  matches_info.num_inliers);
    s.set("H",            matches_info.H);
    s.set("confidence",   matches_info.confidence);
    return s;
}

MxArray toStruct(const vector<MatchesInfo> &pairwise_matches)
{
    const char *fields[] = {"src_img_idx", "dst_img_idx", "matches",
        "inliers_mask", "num_inliers", "H", "confidence"};
    MxArray s = MxArray::Struct(fields, 7, 1, pairwise_matches.size());
    for (mwIndex i = 0; i < pairwise_matches.size(); ++i) {
        s.set("src_img_idx",  pairwise_matches[i].src_img_idx,  i);
        s.set("dst_img_idx",  pairwise_matches[i].dst_img_idx,  i);
        s.set("matches",      pairwise_matches[i].matches,      i);
        s.set("inliers_mask", pairwise_matches[i].inliers_mask, i);
        s.set("num_inliers",  pairwise_matches[i].num_inliers,  i);
        s.set("H",            pairwise_matches[i].H,            i);
        s.set("confidence",   pairwise_matches[i].confidence,   i);
    }
    return s;
}

MxArray toStruct(const CameraParams &params)
{
    const char *fields[] = {"aspect", "focal", "ppx", "ppy", "R", "t", "K"};
    MxArray s = MxArray::Struct(fields, 7);
    s.set("aspect", params.aspect);
    s.set("focal",  params.focal);
    s.set("ppx",    params.ppx);
    s.set("ppy",    params.ppy);
    s.set("R",      params.R);
    s.set("t",      params.t);
    s.set("K",      params.K());
    return s;
}

MxArray toStruct(const vector<CameraParams> &cameras)
{
    const char *fields[] = {"aspect", "focal", "ppx", "ppy", "R", "t", "K"};
    MxArray s = MxArray::Struct(fields, 7, 1, cameras.size());
    for (mwIndex i = 0; i < cameras.size(); ++i) {
        s.set("aspect", cameras[i].aspect, i);
        s.set("focal",  cameras[i].focal,  i);
        s.set("ppx",    cameras[i].ppx,    i);
        s.set("ppy",    cameras[i].ppy,    i);
        s.set("R",      cameras[i].R,      i);
        s.set("t",      cameras[i].t,      i);
        s.set("K",      cameras[i].K(),    i);
    }
    return s;
}


// ==================== XXX ====================

MxArray toStruct(Ptr<FeaturesFinder> p)
{
    MxArray s(MxArray::Struct());
    if (!p.empty()) {
        s.set("TypeId", string(typeid(*p).name()));
        //s.set("isThreadSafe", p->isThreadSafe());
    }
    return s;
}

MxArray toStruct(Ptr<FeaturesMatcher> p)
{
    MxArray s(MxArray::Struct());
    if (!p.empty()) {
        s.set("TypeId",       string(typeid(*p).name()));
        s.set("isThreadSafe", p->isThreadSafe());
    }
    return s;
}

MxArray toStruct(Ptr<Estimator> p)
{
    MxArray s(MxArray::Struct());
    if (!p.empty()) {
        s.set("TypeId", string(typeid(*p).name()));
    }
    return s;
}

MxArray toStruct(Ptr<BundleAdjusterBase> p)
{
    MxArray s(MxArray::Struct());
    if (!p.empty()) {
        s.set("TypeId",         string(typeid(*p).name()));
        s.set("ConfThresh",     p->confThresh());
        s.set("RefinementMask", p->refinementMask());
        s.set("TermCriteria",   p->termCriteria());
    }
    return s;
}

MxArray toStruct(Ptr<WarperCreator> p)
{
    MxArray s(MxArray::Struct());
    if (!p.empty()) {
        s.set("TypeId", string(typeid(*p).name()));
    }
    return s;
}

MxArray toStruct(Ptr<ExposureCompensator> p)
{
    MxArray s(MxArray::Struct());
    if (!p.empty()) {
        s.set("TypeId", string(typeid(*p).name()));
    }
    return s;
}

MxArray toStruct(Ptr<SeamFinder> p)
{
    MxArray s(MxArray::Struct());
    if (!p.empty()) {
        s.set("TypeId", string(typeid(*p).name()));
        {
            Ptr<DpSeamFinder> pp = p.dynamicCast<DpSeamFinder>();
            if (!pp.empty())
                s.set("CostFunction", pp->costFunction());
        }
    }
    return s;
}

MxArray toStruct(Ptr<Blender> p)
{
    MxArray s(MxArray::Struct());
    if (!p.empty()) {
        s.set("TypeId", string(typeid(*p).name()));
        {
            Ptr<FeatherBlender> pp = p.dynamicCast<FeatherBlender>();
            if (!pp.empty())
                s.set("Sharpness", pp->sharpness());
        }
        {
            Ptr<MultiBandBlender> pp = p.dynamicCast<MultiBandBlender>();
            if (!pp.empty())
                s.set("NumBands", pp->numBands());
        }
    }
    return s;
}


// ==================== XXX ====================

Ptr<OrbFeaturesFinder> createOrbFeaturesFinder(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    Size grid_size(3,1);
    int nfeatures = 1500;
    float scaleFactor = 1.3f;
    int nlevels = 5;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "GridSize")
            grid_size = val.toSize();
        else if (key == "NFeatures")
            nfeatures = val.toInt();
        else if (key == "ScaleFactor")
            scaleFactor = val.toFloat();
        else if (key == "NLevels")
            nlevels = val.toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return makePtr<OrbFeaturesFinder>(grid_size, nfeatures, scaleFactor, nlevels);
}

Ptr<AKAZEFeaturesFinder> createAKAZEFeaturesFinder(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    int descriptor_type = cv::AKAZE::DESCRIPTOR_MLDB;
    int descriptor_size = 0;
    int descriptor_channels = 3;
    float threshold = 0.001f;
    int nOctaves = 4;
    int nOctaveLayers = 4;
    int diffusivity = cv::KAZE::DIFF_PM_G2;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "DescriptorType")
            descriptor_type = AKAZEDescriptorType[val.toString()];
        else if (key == "DescriptorSize")
            descriptor_size = val.toInt();
        else if (key == "DescriptorChannels")
            descriptor_channels = val.toInt();
        else if (key == "Threshold")
            threshold = val.toFloat();
        else if (key == "NOctaves")
            nOctaves = val.toInt();
        else if (key == "NOctaveLayers")
            nOctaveLayers = val.toInt();
        else if (key == "Diffusivity")
            diffusivity = KAZEDiffusivityType[val.toString()];

        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return makePtr<AKAZEFeaturesFinder>(descriptor_type, descriptor_size,
        descriptor_channels, threshold, nOctaves, nOctaveLayers, diffusivity);
}

#ifdef HAVE_OPENCV_XFEATURES2D
Ptr<SurfFeaturesFinder> createSurfFeaturesFinder(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    double hess_thresh = 300.0;
    int num_octaves = 3;
    int num_layers = 4;
    int num_octaves_descr = 3;
    int num_layers_descr = 4;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "HessThresh")
            hess_thresh = val.toDouble();
        else if (key == "NumOctaves")
            num_octaves = val.toInt();
        else if (key == "NumLayers")
            num_layers = val.toInt();
        else if (key == "NumOctaveDescr")
            num_octaves_descr = val.toInt();
        else if (key == "NumLayersDesc")
            num_layers_descr = val.toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return makePtr<SurfFeaturesFinder>(hess_thresh, num_octaves, num_layers,
        num_octaves_descr, num_layers_descr);
}
#endif

Ptr<FeaturesFinder> createFeaturesFinder(
    const string& type,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    Ptr<FeaturesFinder> p;
    if (type == "OrbFeaturesFinder")
        p = createOrbFeaturesFinder(first, last);
    else if (type == "AKAZEFeaturesFinder")
        p = createAKAZEFeaturesFinder(first, last);
#ifdef HAVE_OPENCV_XFEATURES2D
    else if (type == "SurfFeaturesFinder")
        p = createSurfFeaturesFinder(first, last);
#if 0
    //TODO: CUDA
    else if (type == "SurfFeaturesFinderGpu")
        p = createSurfFeaturesFinderGpu(first, last);
#endif
#endif
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized features finder %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create FeaturesFinder");
    return p;
}

Ptr<BestOf2NearestMatcher> createBestOf2NearestMatcher(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    bool try_use_gpu = false;
    float match_conf = 0.3f;
    int num_matches_thresh1 = 6;
    int num_matches_thresh2 = 6;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "TryUseGPU")
            try_use_gpu = val.toBool();
        else if (key == "MatchConf")
            match_conf = val.toFloat();
        else if (key == "NumMatchesThresh1")
            num_matches_thresh1 = val.toInt();
        else if (key == "NumMatchesThresh2")
            num_matches_thresh2 = val.toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return makePtr<BestOf2NearestMatcher>(try_use_gpu,
        match_conf, num_matches_thresh1, num_matches_thresh2);
}

Ptr<BestOf2NearestRangeMatcher> createBestOf2NearestRangeMatcher(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    int range_width = 5;
    bool try_use_gpu = false;
    float match_conf = 0.3f;
    int num_matches_thresh1 = 6;
    int num_matches_thresh2 = 6;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "RangeWidth")
            range_width = val.toInt();
        else if (key == "TryUseGPU")
            try_use_gpu = val.toBool();
        else if (key == "MatchConf")
            match_conf = val.toFloat();
        else if (key == "NumMatchesThresh1")
            num_matches_thresh1 = val.toInt();
        else if (key == "NumMatchesThresh2")
            num_matches_thresh2 = val.toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return makePtr<BestOf2NearestRangeMatcher>(range_width, try_use_gpu,
        match_conf, num_matches_thresh1, num_matches_thresh2);
}

Ptr<AffineBestOf2NearestMatcher> createAffineBestOf2NearestMatcher(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    bool full_affine = false;
    bool try_use_gpu = false;
    float match_conf = 0.3f;
    int num_matches_thresh1 = 6;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "FullAffine")
            full_affine = val.toBool();
        else if (key == "TryUseGPU")
            try_use_gpu = val.toBool();
        else if (key == "MatchConf")
            match_conf = val.toFloat();
        else if (key == "NumMatchesThresh1")
            num_matches_thresh1 = val.toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return makePtr<AffineBestOf2NearestMatcher>(full_affine, try_use_gpu,
        match_conf, num_matches_thresh1);
}

Ptr<FeaturesMatcher> createFeaturesMatcher(
    const string& type,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    Ptr<FeaturesMatcher> p;
    if (type == "BestOf2NearestMatcher")
        p = createBestOf2NearestMatcher(first, last);
    else if (type == "BestOf2NearestRangeMatcher")
        p = createBestOf2NearestRangeMatcher(first, last);
    else if (type == "AffineBestOf2NearestMatcher")
        p = createAffineBestOf2NearestMatcher(first, last);
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized features matcher %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create FeaturesMatcher");
    return p;
}

Ptr<HomographyBasedEstimator> createHomographyBasedEstimator(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    bool is_focals_estimated = false;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "IsFocalsEstimated")
            is_focals_estimated = val.toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return makePtr<HomographyBasedEstimator>(is_focals_estimated);
}

Ptr<Estimator> createEstimator(
    const string& type,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    Ptr<Estimator> p;
    if (type == "HomographyBasedEstimator")
        p = createHomographyBasedEstimator(first, last);
    else if (type == "AffineBasedEstimator") {
        nargchk(len==0);
        p = makePtr<AffineBasedEstimator>();
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized estimator %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error", "Failed to create Estimator");
    return p;
}

Ptr<BundleAdjusterBase> createBundleAdjusterBase(
    const string& type,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    Ptr<BundleAdjusterBase> p;
    if (type == "NoBundleAdjuster")
        p = makePtr<NoBundleAdjuster>();
    else if (type == "BundleAdjusterRay")
        p = makePtr<BundleAdjusterRay>();
    else if (type == "BundleAdjusterReproj")
        p = makePtr<BundleAdjusterReproj>();
    else if (type == "BundleAdjusterAffine")
        p = makePtr<BundleAdjusterAffine>();
    else if (type == "BundleAdjusterAffinePartial")
        p = makePtr<BundleAdjusterAffinePartial>();
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized bundle adjuster %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create BundleAdjusterBase");
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "ConfThresh")
            p->setConfThresh(val.toDouble());
        else if (key == "RefinementMask")
            p->setRefinementMask(val.toMat(CV_8U));
        else if (key == "TermCriteria")
            p->setTermCriteria(val.toTermCriteria());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return p;
}

Ptr<cv::CompressedRectilinearWarper> createCompressedRectilinearWarper(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    float A = 1;
    float B = 1;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "A")
            A = val.toFloat();
        else if (key == "B")
            B = val.toFloat();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return makePtr<cv::CompressedRectilinearWarper>(A, B);
}

Ptr<cv::CompressedRectilinearPortraitWarper> createCompressedRectilinearPortraitWarper(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    float A = 1;
    float B = 1;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "A")
            A = val.toFloat();
        else if (key == "B")
            B = val.toFloat();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return makePtr<cv::CompressedRectilinearPortraitWarper>(A, B);
}

Ptr<cv::PaniniWarper> createPaniniWarper(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    float A = 1;
    float B = 1;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "A")
            A = val.toFloat();
        else if (key == "B")
            B = val.toFloat();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return makePtr<cv::PaniniWarper>(A, B);
}

Ptr<cv::PaniniPortraitWarper> createPaniniPortraitWarper(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    float A = 1;
    float B = 1;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "A")
            A = val.toFloat();
        else if (key == "B")
            B = val.toFloat();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return makePtr<cv::PaniniPortraitWarper>(A, B);
}

Ptr<WarperCreator> createWarperCreator(
    const string& type,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    Ptr<WarperCreator> p;
    if (type == "PlaneWarper") {
        nargchk(len==0);
        p = makePtr<cv::PlaneWarper>();
    }
    else if (type == "AffineWarper") {
        nargchk(len==0);
        p = makePtr<cv::AffineWarper>();
    }
    else if (type == "CylindricalWarper") {
        nargchk(len==0);
        p = makePtr<cv::CylindricalWarper>();
    }
    else if (type == "SphericalWarper") {
        nargchk(len==0);
        p = makePtr<cv::SphericalWarper>();
    }
#if 0
    //TODO: CUDA
    else if (type == "PlaneWarperGpu")
        p = makePtr<PlaneWarperGpu>();
    else if (type == "CylindricalWarperGpu")
        p = makePtr<CylindricalWarperGpu>();
    else if (type == "SphericalWarperGpu")
        p = makePtr<SphericalWarperGpu>();
#endif
    else if (type == "FisheyeWarper") {
        nargchk(len==0);
        p = makePtr<cv::FisheyeWarper>();
    }
    else if (type == "StereographicWarper") {
        nargchk(len==0);
        p = makePtr<cv::StereographicWarper>();
    }
    else if (type == "CompressedRectilinearWarper")
        p = createCompressedRectilinearWarper(first, last);
    else if (type == "CompressedRectilinearPortraitWarper")
        p = createCompressedRectilinearPortraitWarper(first, last);
    else if (type == "PaniniWarper")
        p = createPaniniWarper(first, last);
    else if (type == "PaniniPortraitWarper")
        p = createPaniniPortraitWarper(first, last);
    else if (type == "MercatorWarper") {
        nargchk(len==0);
        p = makePtr<cv::MercatorWarper>();
    }
    else if (type == "TransverseMercatorWarper") {
        nargchk(len==0);
        p = makePtr<cv::TransverseMercatorWarper>();
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized warper creator %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error", "Failed to create WarperCreator");
    return p;
}

Ptr<RotationWarper> createRotationWarper(
    const string& type,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last,
    float scale)
{
    Ptr<WarperCreator> p = createWarperCreator(type, first, last);
    return p->create(scale);
}

Ptr<BlocksGainCompensator> createBlocksGainCompensator(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    int bl_width = 32;
    int bl_height = 32;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "Width")
            bl_width = val.toInt();
        else if (key == "Heigth")
            bl_height = val.toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return makePtr<BlocksGainCompensator>(bl_width, bl_height);
}

Ptr<ExposureCompensator> createExposureCompensator(
    const string& type,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    //return ExposureCompensator::createDefault(ExposureCompensatorTypes[type]);
    ptrdiff_t len = std::distance(first, last);
    Ptr<ExposureCompensator> p;
    if (type == "NoExposureCompensator") {
        nargchk(len==0);
        p = makePtr<NoExposureCompensator>();
    }
    else if (type == "GainCompensator") {
        nargchk(len==0);
        p = makePtr<GainCompensator>();
    }
    else if (type == "BlocksGainCompensator")
        p = createBlocksGainCompensator(first, last);
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized exposure compensator %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create ExposureCompensator");
    return p;
}

Ptr<DpSeamFinder> createDpSeamFinder(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    DpSeamFinder::CostFunction costFunc = cv::detail::DpSeamFinder::COLOR;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "CostFunction")
            costFunc = DpCostFunctionMap[val.toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return makePtr<DpSeamFinder>(costFunc);
}

Ptr<GraphCutSeamFinder> createGraphCutSeamFinder(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    int cost_type = cv::detail::GraphCutSeamFinderBase::COST_COLOR_GRAD;
    float terminal_cost = 10000.0f;
    float bad_region_penalty = 1000.0f;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "CostType")
            cost_type = GraphCutCostTypeMap[val.toString()];
        else if (key == "TerminalCost")
            terminal_cost = val.toFloat();
        else if (key == "BadRegionPenaly")
            bad_region_penalty = val.toFloat();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return makePtr<GraphCutSeamFinder>(cost_type, terminal_cost, bad_region_penalty);
}

Ptr<SeamFinder> createSeamFinder(
    const string& type,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    Ptr<SeamFinder> p;
    if (type == "NoSeamFinder") {
        nargchk(len==0);
        p = makePtr<NoSeamFinder>();
    }
    else if (type == "VoronoiSeamFinder") {
        nargchk(len==0);
        p = makePtr<VoronoiSeamFinder>();
    }
    else if (type == "DpSeamFinder")
        p = createDpSeamFinder(first, last);
    else if (type == "GraphCutSeamFinder")
        p = createGraphCutSeamFinder(first, last);
#if 0
    //TODO: CUDA
    else if (type == "GraphCutSeamFinderGpu")
        p = createGraphCutSeamFinderGpu(first, last);
#endif
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized seam finder %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error", "Failed to create SeamFinder");
    return p;
}

Ptr<FeatherBlender> createFeatherBlender(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    float sharpness = 0.02f;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "Sharpness")
            sharpness = val.toFloat();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return makePtr<FeatherBlender>(sharpness);
}

Ptr<MultiBandBlender> createMultiBandBlender(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    int try_gpu = false;
    int num_bands = 5;
    int weight_type = CV_32F;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "TryGPU")
            try_gpu = val.toBool();
        else if (key == "NumBands")
            num_bands = val.toInt();
        else if (key == "WeightType")
            weight_type = (val.isChar()) ?
                ClassNameMap[val.toString()] : val.toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return makePtr<MultiBandBlender>(try_gpu, num_bands, weight_type);
}

Ptr<Blender> createBlender(
    const string& type,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    //return Blender::createDefault(BlenderTypesMap[type]);
    ptrdiff_t len = std::distance(first, last);
    Ptr<Blender> p;
    if (type == "NoBlender") {
        nargchk(len==0);
        p = makePtr<Blender>();
    }
    else if (type == "FeatherBlender")
        p = createFeatherBlender(first, last);
    else if (type == "MultiBandBlender")
        p = createMultiBandBlender(first, last);
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized blender %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error", "Failed to create Blender");
    return p;
}
