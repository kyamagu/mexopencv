/**
 * @file HOGDescriptor_.cpp
 * @brief mex interface for cv::HOGDescriptor
 * @ingroup objdetect
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<HOGDescriptor> > obj_;

/// HistogramNormType map
const ConstMap<string,int> HistogramNormType = ConstMap<string,int>
    ("L2Hys", HOGDescriptor::L2Hys);
/// HistogramNormType inverse map
const ConstMap<int,string> InvHistogramNormType = ConstMap<int,string>
    (HOGDescriptor::L2Hys, "L2Hys");

/** Convert MxArray to cv::DetectionROI
 * @param arr struct-array MxArray object
 * @param idx linear index of the struct array element
 * @return detection region of interest object
 */
DetectionROI MxArrayToDetectionROI(const MxArray &arr, mwIndex idx = 0)
{
    DetectionROI roi;
    roi.scale = arr.at("scale", idx).toDouble();
    roi.locations = arr.at("locations", idx).toVector<Point>();
    if (arr.isField("confidences"))
        roi.confidences = arr.at("confidences", idx).toVector<double>();
    //else
    //    roi.confidences = vector<double>();
    return roi;
}

/** Convert MxArray to std::vector<cv::DetectionROI>
 * @param arr struct-array MxArray object
 * @return vector of detection region of interest objects
 */
vector<DetectionROI> MxArrayToVectorDetectionROI(const MxArray &arr)
{
    const mwSize n = arr.numel();
    vector<DetectionROI> v;
    v.reserve(n);
    if (arr.isCell())
        for (mwIndex i = 0; i < n; ++i)
            v.push_back(MxArrayToDetectionROI(arr.at<MxArray>(i)));
    else if (arr.isStruct())
        for (mwIndex i = 0; i < n; ++i)
            v.push_back(MxArrayToDetectionROI(arr, i));
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "MxArray unable to convert to std::vector<cv::DetectionROI>");
    return v;
}

/** Convert vector of detection region of interest to struct array
 * @param rois vector of DetectionROI instances
 * @return struct-array MxArray object
 */
MxArray toStruct(const vector<DetectionROI> &rois)
{
    const char *fields[] = {"scale", "locations", "confidences"};
    MxArray s = MxArray::Struct(fields, 3, 1, rois.size());
    for (mwIndex i = 0; i < rois.size(); ++i) {
        s.set("scale",       rois[i].scale,       i);
        s.set("locations",   rois[i].locations,   i);
        s.set("confidences", rois[i].confidences, i);
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
    nargchk(nrhs>=2 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor call
    if (method == "new") {
        nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);
        Size winSize(64,128);
        Size blockSize(16,16);
        Size blockStride(8,8);
        Size cellSize(8,8);
        int nbins = 9;
        int derivAperture = 1;
        double winSigma = -1;
        int histogramNormType = cv::HOGDescriptor::L2Hys;
        double L2HysThreshold = 0.2;
        bool gammaCorrection = false;  //TODO: true
        int nlevels = cv::HOGDescriptor::DEFAULT_NLEVELS;
        bool signedGradient = false;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "WinSize")
                winSize = rhs[i+1].toSize();
            else if (key == "BlockSize")
                blockSize = rhs[i+1].toSize();
            else if (key == "BlockStride")
                blockStride = rhs[i+1].toSize();
            else if (key == "CellSize")
                cellSize = rhs[i+1].toSize();
            else if (key == "NBins")
                nbins = rhs[i+1].toInt();
            else if (key == "DerivAperture")
                derivAperture = rhs[i+1].toInt();
            else if (key == "WinSigma")
                winSigma = rhs[i+1].toDouble();
            else if (key == "HistogramNormType")
                histogramNormType = HistogramNormType[rhs[i+1].toString()];
            else if (key == "L2HysThreshold")
                L2HysThreshold = rhs[i+1].toDouble();
            else if (key == "GammaCorrection")
                gammaCorrection = rhs[i+1].toBool();
            else if (key == "NLevels")
                nlevels = rhs[i+1].toInt();
            else if (key == "SignedGradient")
                signedGradient = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unknown option %s",key.c_str());
        }
        // makePtr<T>() only takes upto 10 arguments
        obj_[++last_id] = Ptr<HOGDescriptor>(new HOGDescriptor(
            winSize, blockSize, blockStride, cellSize, nbins, derivAperture,
            winSigma, histogramNormType, L2HysThreshold, gammaCorrection,
            nlevels, signedGradient));
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<HOGDescriptor> obj = obj_[id];
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
    }
    else if (method == "getDescriptorSize") {
        nargchk(nrhs==2 && nlhs<=1);
        size_t sz = obj->getDescriptorSize();
        plhs[0] = MxArray(static_cast<int>(sz));
    }
    else if (method == "checkDetectorSize") {
        nargchk(nrhs==2 && nlhs<=1);
        bool b = obj->checkDetectorSize();
        plhs[0] = MxArray(b);
    }
    else if (method == "getWinSigma") {
        nargchk(nrhs==2 && nlhs<=1);
        double ws = obj->getWinSigma();
        plhs[0] = MxArray(ws);
    }
    else if (method == "readALTModel") {
        nargchk(nrhs==3 && nlhs==0);
        string modelfile = rhs[2].toString();
        obj->readALTModel(modelfile);
    }
    else if (method == "load") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        string objname;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "ObjName")
                objname = rhs[i+1].toString();
            else
                mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized option");
        }
        string filename = rhs[2].toString();
        bool success = obj->load(filename, objname);
        plhs[0] = MxArray(success);
    }
    else if (method == "save") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs==0);
        string objname;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "ObjName")
                objname = rhs[i+1].toString();
            else
                mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized option");
        }
        string filename = rhs[2].toString();
        obj->save(filename, objname);
    }
    else if (method == "compute") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        Size winStride;
        Size padding;
        vector<Point> locations;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="WinStride")
                winStride = rhs[i+1].toSize();
            else if (key=="Padding")
                padding = rhs[i+1].toSize();
            else if (key=="Locations")
                locations = rhs[i+1].toVector<Point>();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat img(rhs[2].toMat(CV_8U));
        vector<float> descriptors;
        obj->compute(img, descriptors, winStride, padding, locations);
        // reshape as one row per descriptor vector
        plhs[0] = MxArray(Mat(descriptors, false).reshape(0,
            descriptors.size() / obj->getDescriptorSize()));
    }
    else if (method == "computeGradient") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=2);
        Size paddingTL;
        Size paddingBR;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="PaddingTL")
                paddingTL = rhs[i+1].toSize();
            else if (key=="PaddingBR")
                paddingBR = rhs[i+1].toSize();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat img(rhs[2].toMat(CV_8U)),
            grad, angleOfs;
        obj->computeGradient(img, grad, angleOfs, paddingTL, paddingBR);
        plhs[0] = MxArray(grad);
        if (nlhs>1)
            plhs[1] = MxArray(angleOfs);
    }
    else if (method == "detect") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=2);
        double hitThreshold = 0;
        Size winStride;
        Size padding;
        vector<Point> searchLocations;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="HitThreshold")
                hitThreshold = rhs[i+1].toDouble();
            else if (key=="WinStride")
                winStride = rhs[i+1].toSize();
            else if (key=="Padding")
                padding = rhs[i+1].toSize();
            else if (key=="Locations")
                searchLocations = rhs[i+1].toVector<Point>();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat img(rhs[2].toMat(CV_8U));
        vector<Point> foundLocations;
        vector<double> weights;
        obj->detect(img, foundLocations, weights, hitThreshold,
            winStride, padding, searchLocations);
        plhs[0] = MxArray(foundLocations);
        if (nlhs>1)
            plhs[1] = MxArray(weights);
    }
    else if (method == "detectMultiScale") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=2);
        double hitThreshold = 0;
        Size winStride;
        Size padding;
        double scale = 1.05;
        double finalThreshold = 2.0;
        bool useMeanshiftGrouping = false;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="HitThreshold")
                hitThreshold = rhs[i+1].toDouble();
            else if (key=="WinStride")
                winStride = rhs[i+1].toSize();
            else if (key=="Padding")
                padding = rhs[i+1].toSize();
            else if (key=="Scale")
                scale = rhs[i+1].toDouble();
            else if (key=="FinalThreshold")
                finalThreshold = rhs[i+1].toDouble();
            else if (key=="UseMeanshiftGrouping")
                useMeanshiftGrouping = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat img(rhs[2].toMat(CV_8U));
        vector<Rect> foundLocations;
        vector<double> weights;
        obj->detectMultiScale(img, foundLocations, weights, hitThreshold,
            winStride, padding, scale, finalThreshold, useMeanshiftGrouping);
        plhs[0] = MxArray(foundLocations);
        if (nlhs>1)
            plhs[1] = MxArray(weights);
    }
    else if (method == "detectROI") {
        nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=2);
        double hitThreshold = 0;
        Size winStride;
        Size padding;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="HitThreshold")
                hitThreshold = rhs[i+1].toDouble();
            else if (key=="WinStride")
                winStride = rhs[i+1].toSize();
            else if (key=="Padding")
                padding = rhs[i+1].toSize();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat img(rhs[2].toMat(CV_8U));
        vector<Point> locations(rhs[3].toVector<Point>()),
                      foundLocations;
        vector<double> confidences;
        obj->detectROI(img, locations, foundLocations, confidences,
            hitThreshold, winStride, padding);
        plhs[0] = MxArray(foundLocations);
        if (nlhs > 1)
            plhs[1] = MxArray(confidences);
    }
    else if (method == "detectMultiScaleROI") {
        nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=2);
        double hitThreshold = 0;
        int groupThreshold = 0;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="HitThreshold")
                hitThreshold = rhs[i+1].toDouble();
            else if (key=="GroupThreshold")
                groupThreshold = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat img(rhs[2].toMat(CV_8U));
        vector<DetectionROI> locations(MxArrayToVectorDetectionROI(rhs[3]));
        vector<Rect> foundLocations;
        obj->detectMultiScaleROI(img, foundLocations, locations,
            hitThreshold, groupThreshold);
        plhs[0] = MxArray(foundLocations);
        if (nlhs > 1)
            plhs[1] = toStruct(locations);
    }
    else if (method == "groupRectangles") {
        nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=2);
        double eps = 0.2;
        int groupThreshold = 1;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "EPS")
                eps = rhs[i+1].toDouble();
            else if (key == "GroupThreshold")
                groupThreshold = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        vector<Rect> rectList(rhs[2].toVector<Rect>());
        vector<double> weights(rhs[3].toVector<double>());
        obj->groupRectangles(rectList, weights, groupThreshold, eps);
        plhs[0] = MxArray(rectList);
        if (nlhs > 1)
            plhs[1] = MxArray(weights);
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "WinSize")
            plhs[0] = MxArray(obj->winSize);
        else if (prop == "BlockSize")
            plhs[0] = MxArray(obj->blockSize);
        else if (prop == "BlockStride")
            plhs[0] = MxArray(obj->blockStride);
        else if (prop == "CellSize")
            plhs[0] = MxArray(obj->cellSize);
        else if (prop == "NBins")
            plhs[0] = MxArray(obj->nbins);
        else if (prop == "DerivAperture")
            plhs[0] = MxArray(obj->derivAperture);
        else if (prop == "WinSigma")
            plhs[0] = MxArray(obj->winSigma);
        else if (prop == "HistogramNormType")
            plhs[0] = MxArray(InvHistogramNormType[obj->histogramNormType]);
        else if (prop == "L2HysThreshold")
            plhs[0] = MxArray(obj->L2HysThreshold);
        else if (prop == "GammaCorrection")
            plhs[0] = MxArray(obj->gammaCorrection);
        else if (prop == "NLevels")
            plhs[0] = MxArray(obj->nlevels);
        else if (prop == "SignedGradient")
            plhs[0] = MxArray(obj->signedGradient);
        else if (prop == "SvmDetector")
            plhs[0] = MxArray(obj->svmDetector);
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized option");
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "WinSize")
            obj->winSize = rhs[3].toSize();
        else if (prop == "BlockSize")
            obj->blockSize = rhs[3].toSize();
        else if (prop == "BlockStride")
            obj->blockStride = rhs[3].toSize();
        else if (prop == "CellSize")
            obj->cellSize = rhs[3].toSize();
        else if (prop == "NBins")
            obj->nbins = rhs[3].toInt();
        else if (prop == "DerivAperture")
            obj->derivAperture = rhs[3].toInt();
        else if (prop == "WinSigma")
            obj->winSigma = rhs[3].toDouble();
        else if (prop == "HistogramNormType")
            obj->histogramNormType = HistogramNormType[rhs[3].toString()];
        else if (prop == "L2HysThreshold")
            obj->L2HysThreshold = rhs[3].toDouble();
        else if (prop == "GammaCorrection")
            obj->gammaCorrection = rhs[3].toBool();
        else if (prop == "NLevels")
            obj->nlevels = rhs[3].toInt();
        else if (prop == "SignedGradient")
            obj->signedGradient = rhs[3].toBool();
        else if (prop == "SvmDetector") {
            vector<float> detector;
            if (rhs[3].isChar()) {
                string type(rhs[3].toString());
                if (type == "DefaultPeopleDetector")
                    detector = HOGDescriptor::getDefaultPeopleDetector();
                else if (type == "DaimlerPeopleDetector")
                    detector = HOGDescriptor::getDaimlerPeopleDetector();
                else
                    mexErrMsgIdAndTxt("mexopencv:error",
                        "Unrecognized people detector %s", type.c_str());
            }
            else
                detector = rhs[3].toVector<float>();
            obj->setSVMDetector(detector);
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized option");
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
