/** Implementation of mexopencv_shape.
 * @file mexopencv_shape.cpp
 * @ingroup shape
 * @author Amro
 * @date 2015
 */

#include "mexopencv_shape.hpp"
#include <typeinfo>
using std::vector;
using std::string;
using namespace cv;


// ==================== XXX ====================

MxArray toStruct(Ptr<HistogramCostExtractor> p)
{
    MxArray s(MxArray::Struct());
    if (!p.empty()) {
        s.set("TypeId",      string(typeid(*p).name()));
        s.set("NDummies",    p->getNDummies());
        s.set("DefaultCost", p->getDefaultCost());
        {
            Ptr<NormHistogramCostExtractor> pp =
                p.dynamicCast<NormHistogramCostExtractor>();
            if (!pp.empty())
                s.set("NormFlag", DistTypeInv[pp->getNormFlag()]);
        }
        {
            Ptr<EMDHistogramCostExtractor> pp =
                p.dynamicCast<EMDHistogramCostExtractor>();
            if (!pp.empty())
                s.set("NormFlag", DistTypeInv[pp->getNormFlag()]);
        }
    }
    return s;
}

MxArray toStruct(Ptr<ShapeTransformer> p)
{
    MxArray s(MxArray::Struct());
    if (!p.empty()) {
        s.set("TypeId", string(typeid(*p).name()));
        {
            Ptr<ThinPlateSplineShapeTransformer> pp =
                p.dynamicCast<ThinPlateSplineShapeTransformer>();
            if (!pp.empty())
                s.set("RegularizationParameter", pp->getRegularizationParameter());
        }
        {
            Ptr<AffineTransformer> pp = p.dynamicCast<AffineTransformer>();
            if (!pp.empty())
                s.set("FullAffine", pp->getFullAffine());
        }
    }
    return s;
}


// ==================== XXX ====================

Ptr<HistogramCostExtractor> create_NormHistogramCostExtractor(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    int flag = cv::DIST_L2;
    int nDummies = 25;
    float defaultCost = 0.2f;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "NDummies")
            nDummies = val.toInt();
        else if (key == "DefaultCost")
            defaultCost = val.toFloat();
        else if (key == "NormFlag")
            flag = DistType[val.toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return createNormHistogramCostExtractor(flag, nDummies, defaultCost);
}

Ptr<HistogramCostExtractor> create_EMDHistogramCostExtractor(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    int flag = cv::DIST_L2;
    int nDummies = 25;
    float defaultCost = 0.2f;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "NDummies")
            nDummies = val.toInt();
        else if (key == "DefaultCost")
            defaultCost = val.toFloat();
        else if (key == "NormFlag")
            flag = DistType[val.toString()];
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return createEMDHistogramCostExtractor(flag, nDummies, defaultCost);
}

Ptr<HistogramCostExtractor> create_ChiHistogramCostExtractor(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    int nDummies = 25;
    float defaultCost = 0.2f;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "NDummies")
            nDummies = val.toInt();
        else if (key == "DefaultCost")
            defaultCost = val.toFloat();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return createChiHistogramCostExtractor(nDummies, defaultCost);
}

Ptr<HistogramCostExtractor> create_EMDL1HistogramCostExtractor(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    int nDummies = 25;
    float defaultCost = 0.2f;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "NDummies")
            nDummies = val.toInt();
        else if (key == "DefaultCost")
            defaultCost = val.toFloat();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return createEMDL1HistogramCostExtractor(nDummies, defaultCost);
}

Ptr<HistogramCostExtractor> create_HistogramCostExtractor(
    const string& type,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    Ptr<HistogramCostExtractor> p;
    if (type == "NormHistogramCostExtractor")
        p = create_NormHistogramCostExtractor(first, last);
    else if (type == "EMDHistogramCostExtractor")
        p = create_EMDHistogramCostExtractor(first, last);
    else if (type == "ChiHistogramCostExtractor")
        p = create_ChiHistogramCostExtractor(first, last);
    else if (type == "EMDL1HistogramCostExtractor")
        p = create_EMDL1HistogramCostExtractor(first, last);
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized histogram cost extractor %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create HistogramCostExtractor");
    return p;
}

Ptr<ThinPlateSplineShapeTransformer> create_ThinPlateSplineShapeTransformer(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    double regularizationParameter = 0;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "RegularizationParameter")
            regularizationParameter = val.toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return createThinPlateSplineShapeTransformer(regularizationParameter);
}

Ptr<AffineTransformer> create_AffineTransformer(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    bool fullAffine = true;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "FullAffine")
            fullAffine = val.toBool();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return createAffineTransformer(fullAffine);
}

Ptr<ShapeTransformer> create_ShapeTransformer(
    const string& type,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    Ptr<ShapeTransformer> p;
    if (type == "ThinPlateSplineShapeTransformer")
        p = create_ThinPlateSplineShapeTransformer(first, last);
    else if (type == "AffineTransformer")
        p = create_AffineTransformer(first, last);
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized shape transformer %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create ShapeTransformer");
    return p;
}

Ptr<ShapeContextDistanceExtractor> create_ShapeContextDistanceExtractor(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    int nAngularBins = 12;
    int nRadialBins = 4;
    float innerRadius = 0.2f;
    float outerRadius = 2;
    int iterations = 3;
    Ptr<HistogramCostExtractor> comparer;
    Ptr<ShapeTransformer> transformer;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "AngularBins")
            nAngularBins = val.toInt();
        else if (key == "RadialBins")
            nRadialBins = val.toInt();
        else if (key == "InnerRadius")
            innerRadius = val.toFloat();
        else if (key == "OuterRadius")
            outerRadius = val.toFloat();
        else if (key == "Iterations")
            iterations = val.toInt();
        else if (key == "CostExtractor") {
            vector<MxArray> args(val.toVector<MxArray>());
            nargchk(args.size() >= 1);
            comparer = create_HistogramCostExtractor(
                args[0].toString(), args.begin() + 1, args.end());
        }
        else if (key == "TransformAlgorithm") {
            vector<MxArray> args(val.toVector<MxArray>());
            nargchk(args.size() >= 1);
            transformer = create_ShapeTransformer(
                args[0].toString(), args.begin() + 1, args.end());
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    if (comparer.empty())
        comparer = createChiHistogramCostExtractor();
    if (transformer.empty())
        transformer = createThinPlateSplineShapeTransformer();
    return createShapeContextDistanceExtractor(nAngularBins, nRadialBins,
        innerRadius, outerRadius, iterations, comparer, transformer);
}

Ptr<HausdorffDistanceExtractor> create_HausdorffDistanceExtractor(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    int distanceFlag = cv::NORM_L2;
    float rankProp = 0.6f;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "DistanceFlag")
            distanceFlag = NormType[val.toString()];
        else if (key == "RankProportion")
            rankProp = val.toFloat();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return createHausdorffDistanceExtractor(distanceFlag, rankProp);
}
