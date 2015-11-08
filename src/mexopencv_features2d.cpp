/** Implementation of mexopencv_features2d.
 * @file mexopencv_features2d.cpp
 * @author Amro
 * @date 2015
*/

#include "mexopencv_features2d.hpp"
using std::vector;
using std::string;
using namespace cv;

#ifdef HAVE_OPENCV_XFEATURES2D
using namespace cv::xfeatures2d;
#endif


/**************************************************************\
*              Feature Detection and Description               *
\**************************************************************/

Ptr<BRISK> createBRISK(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    if (((last-first) % 2) != 0)
        mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
    // second variant for custom patterns
    if ((last-first) >= 2 && !first->isChar()) {
        vector<float> radiusList(first->toVector<float>()); ++first;
        vector<int> numberList(first->toVector<int>()); ++first;
        float dMax = 5.85f, dMin = 8.2f;
        vector<int> indexChange;
        for (; first != last; first += 2) {
            string key((*first).toString());
            const MxArray& val = *(first + 1);
            if (key == "DMax")
                dMax = val.toFloat();
            else if (key == "DMin")
                dMin = val.toFloat();
            else if (key == "IndexChange")
                indexChange = val.toVector<int>();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        return BRISK::create(radiusList, numberList, dMax, dMin, indexChange);
    }
    // first variant
    else {
        int thresh = 30;
        int octaves = 3;
        float patternScale = 1.0f;
        for (; first != last; first += 2) {
            string key((*first).toString());
            const MxArray& val = *(first + 1);
            if (key == "Threshold")
                thresh = val.toInt();
            else if (key == "Octaves")
                octaves = val.toInt();
            else if (key == "PatternScale")
                patternScale = val.toFloat();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        return BRISK::create(thresh, octaves, patternScale);
    }
}

Ptr<ORB> createORB(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    if (((last-first) % 2) != 0)
        mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
    int nfeatures = 500;
    float scaleFactor = 1.2f;
    int nlevels = 8;
    int edgeThreshold = 31;
    int firstLevel = 0;
    int WTA_K = 2;
    int scoreType = ORB::HARRIS_SCORE;
    int patchSize = 31;
    int fastThreshold = 20;
    for (; first != last; first += 2) {
        string key((*first).toString());
        const MxArray& val = *(first + 1);
        if (key == "MaxFeatures")
            nfeatures = val.toInt();
        else if (key == "ScaleFactor")
            scaleFactor = val.toFloat();
        else if (key == "NLevels")
            nlevels = val.toInt();
        else if (key == "EdgeThreshold")
            edgeThreshold = val.toInt();
        else if (key == "FirstLevel")
            firstLevel = val.toInt();
        else if (key == "WTA_K")
            WTA_K = val.toInt();
        else if (key == "ScoreType")
            scoreType = ORBScoreType[val.toString()];
        else if (key == "PatchSize")
            patchSize = val.toInt();
        else if (key == "FastThreshold")
            fastThreshold = val.toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return ORB::create(nfeatures, scaleFactor, nlevels, edgeThreshold,
        firstLevel, WTA_K, scoreType, patchSize, fastThreshold);
}

Ptr<MSER> createMSER(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    if (((last-first) % 2) != 0)
        mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
    int delta = 5;
    int min_area = 60;
    int max_area = 14400;
    double max_variation = 0.25;
    double min_diversity = 0.2;
    int max_evolution = 200;
    double area_threshold = 1.01;
    double min_margin = 0.003;
    int edge_blur_size = 5;
    for (; first != last; first += 2) {
        string key((*first).toString());
        const MxArray& val = *(first + 1);
        if (key == "Delta")
            delta = val.toInt();
        else if (key == "MinArea")
            min_area = val.toInt();
        else if (key == "MaxArea")
            max_area = val.toInt();
        else if (key == "MaxVariation")
            max_variation = val.toDouble();
        else if (key == "MinDiversity")
            min_diversity = val.toDouble();
        else if (key == "MaxEvolution")
            max_evolution = val.toInt();
        else if (key == "AreaThreshold")
            area_threshold = val.toDouble();
        else if (key == "MinMargin")
            min_margin = val.toDouble();
        else if (key == "EdgeBlurSize")
            edge_blur_size = val.toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return MSER::create(delta, min_area, max_area, max_variation,
        min_diversity, max_evolution, area_threshold, min_margin,
        edge_blur_size);
}

Ptr<FastFeatureDetector> createFastFeatureDetector(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    if (((last-first) % 2) != 0)
        mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
    int threshold = 10;
    bool nonmaxSuppression = true;
    int type = FastFeatureDetector::TYPE_9_16;
    for (; first != last; first += 2) {
        string key((*first).toString());
        const MxArray& val = *(first + 1);
        if (key == "Threshold")
            threshold = val.toInt();
        else if (key == "NonmaxSuppression")
            nonmaxSuppression = val.toBool();
        else if (key == "Type")
            type = FASTTypeMap[val.toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return FastFeatureDetector::create(threshold, nonmaxSuppression, type);
}

Ptr<GFTTDetector> createGFTTDetector(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    if (((last-first) % 2) != 0)
        mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
    int maxCorners = 1000;
    double qualityLevel = 0.01;
    double minDistance = 1;
    int blockSize = 3;
    bool useHarrisDetector = false;
    double k = 0.04;
    for (; first != last; first += 2) {
        string key((*first).toString());
        const MxArray& val = *(first + 1);
        if (key == "MaxFeatures")
            maxCorners = val.toInt();
        else if (key == "QualityLevel")
            qualityLevel = val.toDouble();
        else if (key == "MinDistance")
            minDistance = val.toDouble();
        else if (key == "BlockSize")
            blockSize = val.toInt();
        else if (key == "HarrisDetector")
            useHarrisDetector = val.toBool();
        else if(key == "K")
            k = val.toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return GFTTDetector::create(maxCorners, qualityLevel, minDistance,
        blockSize, useHarrisDetector, k);
}

Ptr<SimpleBlobDetector> createSimpleBlobDetector(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    if (((last-first) % 2) != 0)
        mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
    SimpleBlobDetector::Params parameters;
    for (; first != last; first += 2) {
        string key((*first).toString());
        const MxArray& val = *(first + 1);
        if (key == "ThresholdStep")
            parameters.thresholdStep = val.toFloat();
        else if (key == "MinThreshold")
            parameters.minThreshold = val.toFloat();
        else if (key == "MaxThreshold")
            parameters.maxThreshold = val.toFloat();
        else if (key == "MinRepeatability")
            parameters.minRepeatability = val.toInt();
        else if (key == "MinDistBetweenBlobs")
            parameters.minDistBetweenBlobs = val.toFloat();
        else if (key == "FilterByColor")
            parameters.filterByColor = val.toBool();
        else if (key == "BlobColor")
            parameters.blobColor = static_cast<uchar>(val.toInt());
        else if (key == "FilterByArea")
            parameters.filterByArea = val.toBool();
        else if (key == "MinArea")
            parameters.minArea = val.toFloat();
        else if (key == "MaxArea")
            parameters.maxArea = val.toFloat();
        else if (key == "FilterByCircularity")
            parameters.filterByCircularity = val.toBool();
        else if (key == "MinCircularity")
            parameters.minCircularity = val.toFloat();
        else if (key == "MaxCircularity")
            parameters.maxCircularity = val.toFloat();
        else if (key == "FilterByInertia")
            parameters.filterByInertia = val.toBool();
        else if (key == "MinInertiaRatio")
            parameters.minInertiaRatio = val.toFloat();
        else if (key == "MaxInertiaRatio")
            parameters.maxInertiaRatio = val.toFloat();
        else if (key == "FilterByConvexity")
            parameters.filterByConvexity = val.toBool();
        else if (key == "MinConvexity")
            parameters.minConvexity = val.toFloat();
        else if (key == "MaxConvexity")
            parameters.maxConvexity = val.toFloat();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return SimpleBlobDetector::create(parameters);
}

Ptr<KAZE> createKAZE(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    if (((last-first) % 2) != 0)
        mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
    bool extended = false;
    bool upright = false;
    float threshold = 0.001f;
    int nOctaves = 4;
    int nOctaveLayers = 4;
    int diffusivity = KAZE::DIFF_PM_G2;
    for (; first != last; first += 2) {
        string key((*first).toString());
        const MxArray& val = *(first + 1);
        if (key == "Extended")
            extended = val.toBool();
        else if (key == "Upright")
            upright = val.toBool();
        else if (key == "Threshold")
            threshold = val.toFloat();
        else if (key == "NOctaves")
            nOctaves = val.toInt();
        else if (key == "NOctaveLayers")
            nOctaveLayers = val.toInt();
        else if(key == "Diffusivity")
            diffusivity = KAZEDiffusivityType[val.toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return KAZE::create(extended, upright, threshold,
        nOctaves, nOctaveLayers, diffusivity);
}

Ptr<AKAZE> createAKAZE(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    if (((last-first) % 2) != 0)
        mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
    int descriptor_type = AKAZE::DESCRIPTOR_MLDB;
    int descriptor_size = 0;
    int descriptor_channels = 3;
    float threshold = 0.001f;
    int nOctaves = 4;
    int nOctaveLayers = 4;
    int diffusivity = KAZE::DIFF_PM_G2;
    for (; first != last; first += 2) {
        string key((*first).toString());
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
    return AKAZE::create(descriptor_type, descriptor_size, descriptor_channels,
        threshold, nOctaves, nOctaveLayers, diffusivity);
}

Ptr<AgastFeatureDetector> createAgastFeatureDetector(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    if (((last-first) % 2) != 0)
        mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
    int threshold = 10;
    bool nonmaxSuppression = true;
    int type = AgastFeatureDetector::OAST_9_16;
    for (; first != last; first += 2) {
        string key((*first).toString());
        const MxArray& val = *(first + 1);
        if (key == "Threshold")
            threshold = val.toInt();
        else if (key == "NonmaxSuppression")
            nonmaxSuppression = val.toBool();
        else if (key == "Type")
            type = AgastTypeMap[val.toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return AgastFeatureDetector::create(threshold, nonmaxSuppression, type);
}

#ifdef HAVE_OPENCV_XFEATURES2D
Ptr<SIFT> createSIFT(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    if (((last-first) % 2) != 0)
        mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
    int nfeatures = 0;
    int nOctaveLayers = 3;
    double contrastThreshold = 0.04;
    double edgeThreshold = 10;
    double sigma = 1.6;
    for (; first != last; first += 2) {
        string key((*first).toString());
        const MxArray& val = *(first + 1);
        if (key == "NFeatures")
            nfeatures = val.toInt();
        else if (key == "NOctaveLayers")
            nOctaveLayers = val.toInt();
        else if (key == "ConstrastThreshold")
            contrastThreshold = val.toDouble();
        else if (key == "EdgeThreshold")
            edgeThreshold = val.toDouble();
        else if (key == "Sigma")
            sigma = val.toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return SIFT::create(nfeatures, nOctaveLayers, contrastThreshold,
        edgeThreshold, sigma);
}

Ptr<SURF> createSURF(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    if (((last-first) % 2) != 0)
        mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
    double hessianThreshold = 100;
    int nOctaves = 4;
    int nOctaveLayers = 3;
    bool extended = false;
    bool upright = false;
    for (; first != last; first += 2) {
        string key((*first).toString());
        const MxArray& val = *(first + 1);
        if (key == "HessianThreshold")
            hessianThreshold = val.toDouble();
        else if (key == "NOctaves")
            nOctaves = val.toInt();
        else if (key == "NOctaveLayers")
            nOctaveLayers = val.toInt();
        else if (key == "Extended")
            extended = val.toBool();
        else if (key == "Upright")
            upright = val.toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return SURF::create(hessianThreshold, nOctaves, nOctaveLayers,
        extended, upright);
}

Ptr<FREAK> createFREAK(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    if (((last-first) % 2) != 0)
        mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
    bool orientationNormalized = true;
    bool scaleNormalized = true;
    float patternScale = 22.0f;
    int nOctaves = 4;
    vector<int> selectedPairs;
    for (; first != last; first += 2) {
        string key((*first).toString());
        const MxArray& val = *(first + 1);
        if (key == "OrientationNormalized")
            orientationNormalized = val.toBool();
        else if (key == "ScaleNormalized")
            scaleNormalized = val.toBool();
        else if (key == "PatternScale")
            patternScale = val.toFloat();
        else if (key == "NOctaves")
            nOctaves = val.toInt();
        else if (key == "SelectedPairs")
            selectedPairs = val.toVector<int>();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return FREAK::create(orientationNormalized, scaleNormalized, patternScale,
        nOctaves, selectedPairs);
}

Ptr<StarDetector> createStarDetector(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    if (((last-first) % 2) != 0)
        mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
    int maxSize = 45;
    int responseThreshold = 30;
    int lineThresholdProjected = 10;
    int lineThresholdBinarized = 8;
    int suppressNonmaxSize = 5;
    for (; first != last; first += 2) {
        string key((*first).toString());
        const MxArray& val = *(first + 1);
        if (key == "MaxSize")
            maxSize = val.toInt();
        else if (key == "ResponseThreshold")
            responseThreshold = val.toInt();
        else if (key == "LineThresholdProjected")
            lineThresholdProjected = val.toInt();
        else if (key == "LineThresholdBinarized")
            lineThresholdBinarized = val.toInt();
        else if (key == "SuppressNonmaxSize")
            suppressNonmaxSize = val.toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return StarDetector::create(maxSize, responseThreshold,
        lineThresholdProjected, lineThresholdBinarized, suppressNonmaxSize);
}

Ptr<BriefDescriptorExtractor> createBriefDescriptorExtractor(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    if (((last-first) % 2) != 0)
        mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
    int bytes = 32;
    bool use_orientation = false;
    for (; first != last; first += 2) {
        string key((*first).toString());
        const MxArray& val = *(first + 1);
        if (key == "Bytes")
            bytes = val.toInt();
        else if (key == "UseOrientation")
            use_orientation = val.toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return BriefDescriptorExtractor::create(bytes, use_orientation);
}

Ptr<LUCID> createLUCID(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    if (((last-first) % 2) != 0)
        mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
    int lucid_kernel = 1;
    int blur_kernel = 2;
    for (; first != last; first += 2) {
        string key((*first).toString());
        const MxArray& val = *(first + 1);
        if (key == "LucidKernel")
            lucid_kernel = val.toInt();
        else if (key == "BlurKernel")
            blur_kernel = val.toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return LUCID::create(lucid_kernel, blur_kernel);
}

Ptr<LATCH> createLATCH(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    if (((last-first) % 2) != 0)
        mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
    int bytes = 32;
    bool rotationInvariance = true;
    int half_ssd_size = 3;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "Bytes")
            bytes = val.toInt();
        else if (key == "RotationInvariance")
            rotationInvariance = val.toBool();
        else if (key == "HalfSize")
            half_ssd_size = val.toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return LATCH::create(bytes, rotationInvariance, half_ssd_size);
}

Ptr<DAISY> createDAISY(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    if (((last-first) % 2) != 0)
        mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
    float radius = 15;
    int q_radius = 3;
    int q_theta = 8;
    int q_hist = 8;
    int norm = DAISY::NRM_NONE;
    Mat H;
    bool interpolation = true;
    bool use_orientation = false;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "Radius")
            radius = val.toFloat();
        else if (key == "RadiusQuant")
            q_radius = val.toInt();
        else if (key == "AngleQuant")
            q_theta = val.toInt();
        else if (key == "GradOrientationsQuant")
            q_hist = val.toInt();
        else if (key == "Normalization")
            norm = DAISYNormType[val.toString()];
        else if (key == "H")
            H = val.toMat();
        else if (key == "Interpolation")
            interpolation = val.toBool();
        else if (key == "UseOrientation")
            use_orientation = val.toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return DAISY::create(radius, q_radius, q_theta, q_hist,
        norm, H, interpolation, use_orientation);
}
#endif

Ptr<FeatureDetector> createFeatureDetector(
    const string& type,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    Ptr<FeatureDetector> p;
    if (type == "BRISK")
        p = createBRISK(first, last);
    else if (type == "ORB")
        p = createORB(first, last);
    else if (type == "MSER")
        p = createMSER(first, last);
    else if (type == "FastFeatureDetector")
        p = createFastFeatureDetector(first, last);
    else if (type == "GFTTDetector")
        p = createGFTTDetector(first, last);
    else if (type == "SimpleBlobDetector")
        p = createSimpleBlobDetector(first, last);
    else if (type == "KAZE")
        p = createKAZE(first, last);
    else if (type == "AKAZE")
        p = createAKAZE(first, last);
    else if (type == "AgastFeatureDetector")
        p = createAgastFeatureDetector(first, last);
#ifdef HAVE_OPENCV_XFEATURES2D
    else if (type == "SIFT")
        p = createSIFT(first, last);
    else if (type == "SURF")
        p = createSURF(first, last);
    else if (type == "StarDetector")
        p = createStarDetector(first, last);
#endif
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized detector %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create FeatureDetector of type %s", type.c_str());
    return p;
}

Ptr<DescriptorExtractor> createDescriptorExtractor(
    const string& type,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    Ptr<DescriptorExtractor> p;
    if (type == "BRISK")
        p = createBRISK(first, last);
    else if (type == "ORB")
        p = createORB(first, last);
    else if (type == "KAZE")
        p = createKAZE(first, last);
    else if (type == "AKAZE")
        p = createAKAZE(first, last);
#ifdef HAVE_OPENCV_XFEATURES2D
    else if (type == "SIFT")
        p = createSIFT(first, last);
    else if (type == "SURF")
        p = createSURF(first, last);
    else if (type == "FREAK")
        p = createFREAK(first, last);
    else if (type == "BriefDescriptorExtractor")
        p = createBriefDescriptorExtractor(first, last);
    else if (type == "LUCID")
        p = createLUCID(first, last);
    else if (type == "LATCH")
        p = createLATCH(first, last);
    else if (type == "DAISY")
        p = createDAISY(first, last);
#endif
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized extractor %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create DescriptorExtractor of type %s", type.c_str());
    return p;
}


/**************************************************************\
*                     Descriptor Matching                      *
\**************************************************************/

/// IndexParams centers initialization methods
const ConstMap<string, cvflann::flann_centers_init_t> CentersInit =
    ConstMap<string, cvflann::flann_centers_init_t>
    ("Random",    cvflann::FLANN_CENTERS_RANDOM)
    ("Gonzales",  cvflann::FLANN_CENTERS_GONZALES)
    ("KMeansPP",  cvflann::FLANN_CENTERS_KMEANSPP)
    ("Groupwise", cvflann::FLANN_CENTERS_GROUPWISE);

/** Convert MxArray to FLANN index parameters
 * @param m MxArray object of a cell array of the form
 *    {'type', 'OptionName', optionValue, ...}
 * @return smart pointer to an instance of cv::flann::IndexParams.
 */
Ptr<flann::IndexParams> toIndexParams(const MxArray& m)
{
    Ptr<flann::IndexParams> p;
    vector<MxArray> rhs(m.toVector<MxArray>());
    if (rhs.empty())
        mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
    string type(rhs[0].toString());
    if (type == "Linear") {
        if (rhs.size() != 1)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        p = makePtr<flann::LinearIndexParams>();
    }
    else if (type == "KDTree") {
        if ((rhs.size() % 2) == 0)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        int trees = 4;
        for (size_t i = 1; i<rhs.size(); i += 2) {
            string key(rhs[i].toString());
            if (key == "Trees")
                trees = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        p = makePtr<flann::KDTreeIndexParams>(trees);
    }
    else if (type == "KMeans") {
        if ((rhs.size() % 2) == 0)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        int branching = 32;
        int iterations = 11;
        cvflann::flann_centers_init_t centers_init = cvflann::FLANN_CENTERS_RANDOM;
        float cb_index = 0.2f;
        for (size_t i = 1; i<rhs.size(); i += 2) {
            string key(rhs[i].toString());
            if (key == "Branching")
                branching = rhs[i+1].toInt();
            else if (key == "Iterations")
                iterations = rhs[i+1].toInt();
            else if (key == "CentersInit")
                centers_init = CentersInit[rhs[i+1].toString()];
            else if (key == "CBIndex")
                cb_index = rhs[i+1].toFloat();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        p = makePtr<flann::KMeansIndexParams>(
            branching, iterations, centers_init, cb_index);
    }
    else if (type == "Composite") {
        if ((rhs.size() % 2) == 0)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        int trees = 4;
        int branching = 32;
        int iterations = 11;
        cvflann::flann_centers_init_t centers_init = cvflann::FLANN_CENTERS_RANDOM;
        float cb_index = 0.2f;
        for (size_t i = 1; i<rhs.size(); i += 2) {
            string key(rhs[i].toString());
            if (key == "Trees")
                trees = rhs[i+1].toInt();
            else if (key == "Branching")
                branching = rhs[i+1].toInt();
            else if (key == "Iterations")
                iterations = rhs[i+1].toInt();
            else if (key == "CentersInit")
                centers_init = CentersInit[rhs[i+1].toString()];
            else if (key == "CBIndex")
                cb_index = rhs[i+1].toFloat();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        p = makePtr<flann::CompositeIndexParams>(
            trees, branching, iterations, centers_init, cb_index);
    }
    else if (type == "LSH") {
        if ((rhs.size() % 2) == 0)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        int table_number = 20;
        int key_size = 15;
        int multi_probe_level = 0;
        for (size_t i = 1; i<rhs.size(); i += 2) {
            string key(rhs[i].toString());
            if (key == "TableNumber")
                table_number = rhs[i+1].toInt();
            else if (key == "KeySize")
                key_size = rhs[i+1].toInt();
            else if (key == "MultiProbeLevel")
                multi_probe_level = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        p = makePtr<flann::LshIndexParams>(
            table_number, key_size, multi_probe_level);
    }
    else if (type == "Autotuned") {
        if ((rhs.size() % 2) == 0)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        float target_precision = 0.8f;
        float build_weight = 0.01f;
        float memory_weight = 0;
        float sample_fraction = 0.1f;
        for (size_t i = 1; i<rhs.size(); i += 2) {
            string key(rhs[i].toString());
            if (key == "TargetPrecision")
                target_precision = rhs[i+1].toFloat();
            else if (key == "BuildWeight")
                build_weight = rhs[i+1].toFloat();
            else if (key == "MemoryWeight")
                memory_weight = rhs[i+1].toFloat();
            else if (key == "SampleFraction")
                sample_fraction = rhs[i+1].toFloat();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        p = makePtr<flann::AutotunedIndexParams>(
            target_precision, build_weight, memory_weight, sample_fraction);
    }
    else if (type == "Saved") {
        if(rhs.size() != 2)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        string filename(rhs[1].toString());
        p = makePtr<flann::SavedIndexParams>(filename);
    }
    else if (type == "HierarchicalClustering") {
        if ((rhs.size() % 2) == 0)
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        int branching = 32;
        cvflann::flann_centers_init_t centers_init = cvflann::FLANN_CENTERS_RANDOM;
        int trees = 4;
        int leaf_size = 100;
        for (size_t i = 1; i<rhs.size(); i += 2) {
            string key(rhs[i].toString());
            if (key == "Branching")
                branching = rhs[i+1].toInt();
            else if (key == "CentersInit")
                centers_init = CentersInit[rhs[i+1].toString()];
            else if (key == "Trees")
                trees = rhs[i+1].toInt();
            else if (key == "LeafSize")
                leaf_size = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        p = makePtr<flann::HierarchicalClusteringIndexParams>(
            branching, centers_init, trees, leaf_size);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized IndexParams type: %s", type.c_str());
    return p;
}

/** Convert MxArray to FLANN search parameters
 * @param m MxArray object of a cell array of the form
 *    {'OptionName', optionValue, ...}
 * @return smart pointer to an instance of cv::flann::SearchParams.
 */
Ptr<flann::SearchParams> toSearchParams(const MxArray& m)
{
    vector<MxArray> rhs(m.toVector<MxArray>());
    if ((rhs.size() % 2) != 0)
        mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
    int checks = 32;
    float eps = 0;
    bool sorted = true;
    for (size_t i = 0; i<rhs.size(); i += 2) {
        string key(rhs[i].toString());
        if (key == "Checks")
            checks = rhs[i+1].toInt();
        else if (key == "EPS")
            eps = rhs[i+1].toFloat();
        else if (key == "Sorted")
            sorted = rhs[i+1].toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return makePtr<flann::SearchParams>(checks, eps, sorted);
}

Ptr<FlannBasedMatcher> createFlannBasedMatcher(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    if (((last-first) % 2) != 0)
        mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
    Ptr<flann::IndexParams> indexParams;
    Ptr<flann::SearchParams> searchParams;
    for (; first != last; first += 2) {
        string key((*first).toString());
        const MxArray& val = *(first + 1);
        if (key == "Index")
            indexParams = toIndexParams(val);
        else if (key == "Search")
            searchParams = toSearchParams(val);
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    if (indexParams.empty())
        indexParams = makePtr<flann::KDTreeIndexParams>();
    if (searchParams.empty())
        searchParams = makePtr<flann::SearchParams>();
    return makePtr<FlannBasedMatcher>(indexParams, searchParams);
}

Ptr<BFMatcher> createBFMatcher(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    if (((last-first) % 2) != 0)
        mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
    int normType = cv::NORM_L2;
    bool crossCheck = false;
    for (; first != last; first += 2) {
        string key((*first).toString());
        const MxArray& val = *(first + 1);
        if (key == "NormType")
            normType = NormType[val.toString()];
        else if (key == "CrossCheck")
            crossCheck = val.toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return makePtr<BFMatcher>(normType, crossCheck);
}

Ptr<DescriptorMatcher> createDescriptorMatcher(
    const string& type,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    Ptr<DescriptorMatcher> p;
    if ((last-first) > 0) {
        if (type == "FlannBasedMatcher")
            p = createFlannBasedMatcher(first, last);
        else if (type == "BFMatcher")
            p = createBFMatcher(first, last);
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized matcher %s", type.c_str());
    }
    else
        p = DescriptorMatcher::create(type);
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create DescriptorMatcher of type %s", type.c_str());
    return p;
}

