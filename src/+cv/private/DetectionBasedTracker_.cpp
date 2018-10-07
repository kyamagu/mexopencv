/**
 * @file DetectionBasedTracker_.cpp
 * @brief mex interface for cv::DetectionBasedTracker
 * @ingroup objdetect
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
#include "opencv2/objdetect.hpp"
using namespace std;
using namespace cv;

//HACK: detection_based_tracker.cpp requires C++11 threads or Unix pthreads
//  to compile. On Windows, it means we need >= VS2013 (VS2010 doesnt work).
//HACK: I'm excluding MinGW since not all builds have std::thread support,
//  plus the detection code in opencv doesn't handle MinGW correctly.
#if defined(__linux__) || defined(__APPLE__) || \
    (defined(CV_CXX11) && !defined(__MINGW32__))

namespace {
// Persistent objects
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<DetectionBasedTracker> > obj_;

/// extended object status inverse map for option processing
const ConstMap<int,string> ObjectStatusInvMap = ConstMap<int,string>
    (cv::DetectionBasedTracker::DETECTED_NOT_SHOWN_YET,  "DetectedNotShownYet")
    (cv::DetectionBasedTracker::DETECTED,                "Detected")
    (cv::DetectionBasedTracker::DETECTED_TEMPORARY_LOST, "DetectedTemporaryLost")
    (cv::DetectionBasedTracker::WRONG_OBJECT,            "WrongObject");

/** Create an instance of Parameters using options in arguments
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created DetectionBasedTracker::Parameters
 */
DetectionBasedTracker::Parameters createParameters(
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    DetectionBasedTracker::Parameters params;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "MaxTrackLifetime")
            params.maxTrackLifetime = val.toInt();
        else if (key == "MinDetectionPeriod")
            params.minDetectionPeriod = val.toInt();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    return params;
}

/** Convert a Parameters instance to MxArray struct
 * @param params instance of DetectionBasedTracker::Parameters
 * @return output MxArray scalar structure
 */
MxArray toStruct(const DetectionBasedTracker::Parameters &params)
{
    const char *fields[] = {"maxTrackLifetime", "minDetectionPeriod"};
    MxArray s = MxArray::Struct(fields, 2);
    s.set("maxTrackLifetime",   params.maxTrackLifetime);
    s.set("minDetectionPeriod", params.minDetectionPeriod);
    return s;
}

/** Convert vector of detected objects to MxArray
 * @param objects vector of ExtObject instances
 * @return struct-array MxArray object
 */
MxArray toStruct(const vector<DetectionBasedTracker::ExtObject> &objects)
{
    const char *fields[] = {"id", "location", "status"};
    MxArray s = MxArray::Struct(fields, 3, 1, objects.size());
    for (mwIndex i = 0; i < objects.size(); ++i) {
        s.set("id",       objects[i].id,                         i);
        s.set("location", objects[i].location,                   i);
        s.set("status",   ObjectStatusInvMap[objects[i].status], i);
    }
    return s;
}

/// Custom detector class for DetectionBasedTracker, based on CascadeClassifier
class CascadeDetectorAdapter : public DetectionBasedTracker::IDetector
{
public:
    /** Constructor
     * @param p smart pointer to an instance of CascadeClassifier
     */
    CascadeDetectorAdapter(Ptr<CascadeClassifier> p)
        : IDetector(), detector(p)
    {
        CV_Assert(!p.empty());
    }

    /** Detect objects
     * @param image 8-bit single-channel gray image.
     * @param[out] objects vector of detected objects locations.
     */
    void detect(const Mat& image, vector<Rect>& objects)
    {
        detector->detectMultiScale(image, objects,
            scaleFactor, minNeighbours, 0, minObjSize, maxObjSize);
    }

    /** Factory function
     * @param cascadeFile Name of file from which the classifier is loaded.
     * @param first iterator at the beginning of the vector range
     * @param last iterator at the end of the vector range
     * @return smart pointer to newly created instance
     */
    static Ptr<CascadeDetectorAdapter> create(string cascadeFile,
        vector<MxArray>::const_iterator first,
        vector<MxArray>::const_iterator last)
    {
        ptrdiff_t len = std::distance(first, last);
        nargchk((len%2)==0);
        Ptr<CascadeClassifier> detector = makePtr<CascadeClassifier>();
        if (detector.empty() || !detector->load(cascadeFile))
            mexErrMsgIdAndTxt("mexopencv:error",
                "Failed to create CascadeClassifier");
        Ptr<CascadeDetectorAdapter> p = makePtr<CascadeDetectorAdapter>(detector);
        if (p.empty())
            mexErrMsgIdAndTxt("mexopencv:error",
                "Failed to create CascadeDetectorAdapter");
        for (; first != last; first += 2) {
            string key(first->toString());
            const MxArray& val = *(first + 1);
            if (key == "ScaleFactor")
                p->setScaleFactor(val.toFloat());
            else if (key == "MinNeighbors")
                p->setMinNeighbours(val.toInt());
            else if (key == "MinSize")
                p->setMinObjectSize(val.toSize());
            else if (key == "MaxSize")
                p->setMaxObjectSize(val.toSize());
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        return p;
    }

private:
    Ptr<CascadeClassifier> detector;  ///<! cascade classifier detector
};
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

    // Constructor call
    if (method == "new") {
        nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=1);
        Ptr<DetectionBasedTracker::IDetector> mainDetector;
        {
            vector<MxArray> args(rhs[2].toVector<MxArray>());
            nargchk(args.size() >= 1);
            mainDetector = CascadeDetectorAdapter::create(
                args[0].toString(), args.begin() + 1, args.end());
        }
        Ptr<DetectionBasedTracker::IDetector> trackingDetector;
        {
            vector<MxArray> args(rhs[3].toVector<MxArray>());
            nargchk(args.size() >= 1);
            trackingDetector = CascadeDetectorAdapter::create(
                args[0].toString(), args.begin() + 1, args.end());
        }
        //TODO: mainDetector may be empty ?
        if (mainDetector.empty() || trackingDetector.empty())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to create IDetector");
        DetectionBasedTracker::Parameters params = createParameters(
            rhs.begin() + 4, rhs.end());
        obj_[++last_id] = makePtr<DetectionBasedTracker>(
            mainDetector, trackingDetector, params);
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<DetectionBasedTracker> obj = obj_[id];
    if (obj.empty())
        mexErrMsgIdAndTxt("mexopencv:error", "Object not found id=%d", id);
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
        mexUnlock();
    }
    else if (method == "run") {
        nargchk(nrhs==2 && nlhs<=1);
        bool success = obj->run();
        plhs[0] = MxArray(success);
    }
    else if (method == "stop") {
        nargchk(nrhs==2 && nlhs==0);
        obj->stop();
    }
    else if (method == "resetTracking") {
        nargchk(nrhs==2 && nlhs==0);
        obj->resetTracking();
    }
    else if (method == "getParameters") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = toStruct(obj->getParameters());
    }
    else if (method == "setParameters") {
        nargchk(nrhs>=2 && nlhs<=1);
        bool success = obj->setParameters(createParameters(
            rhs.begin() + 2, rhs.end()));
        plhs[0] = MxArray(success);
    }
    else if (method == "process") {
        nargchk(nrhs==3 && nlhs==0);
        Mat imageGray(rhs[2].toMat(CV_8U));
        obj->process(imageGray);
    }
    else if (method == "getObjects") {
        nargchk(nrhs==2 && nlhs<=2);
        if (nlhs > 1) {
            vector<DetectionBasedTracker::Object> result;
            obj->getObjects(result);  // rectangle + id
            // separate std::pair<cv::Rect, int>
            vector<Rect> locations;
            vector<int> ids;
            locations.reserve(result.size());
            ids.reserve(result.size());
            for (vector<DetectionBasedTracker::Object>::const_iterator it = result.begin(); it != result.end(); ++it) {
                locations.push_back(it->first);
                ids.push_back(it->second);
            }
            plhs[0] = MxArray(locations);
            plhs[1] = MxArray(ids);
        }
        else {
            vector<Rect> result;
            obj->getObjects(result);  // rectangle
            plhs[0] = MxArray(result);
        }
    }
    else if (method == "getObjectsExtended") {
        nargchk(nrhs==2 && nlhs<=1);
        vector<DetectionBasedTracker::ExtObject> result;
        obj->getObjects(result);  // rectangle + id + status
        plhs[0] = toStruct(result);
    }
    else if (method == "addObject") {
        nargchk(nrhs==3 && nlhs<=1);
        Rect location(rhs[2].toRect());
        int id = obj->addObject(location);
        plhs[0] = MxArray(id);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized method %s", method.c_str());
}

#else

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    mexErrMsgIdAndTxt("mexopencv:error",
        "DetectionBasedTracker is not supported");
}

#endif
