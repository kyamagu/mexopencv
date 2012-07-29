/**
 * @file LatentSvmDetector_.cpp
 * @brief mex interface for LatentSvmDetector
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

#if (CV_MINOR_VERSION >= 2 && (CV_MINOR_VERSION <= 3 && CV_SUBMINOR_VERSION <= 1))
namespace cv {
// The following code taken from OpenCV 2.3.2 for pre-2.3.2 releases
/*
 * This is a class wrapping up the structure CvLatentSvmDetector and functions working with it.
 * The class goals are:
 * 1) provide c++ interface;
 * 2) make it possible to load and detect more than one class (model) unlike CvLatentSvmDetector.
 */
class CV_EXPORTS LatentSvmDetector
{
public:
    struct CV_EXPORTS ObjectDetection
    {
        ObjectDetection();
        ObjectDetection( const Rect& rect, float score, int classID=-1 );
        Rect rect;
        float score;
        int classID;
    };

    LatentSvmDetector();
    LatentSvmDetector( const vector<string>& filenames, const vector<string>& classNames=vector<string>() );
    virtual ~LatentSvmDetector();

    virtual void clear();
    virtual bool empty() const;
    bool load( const vector<string>& filenames, const vector<string>& classNames=vector<string>() );

    virtual void detect( const Mat& image,
                         vector<ObjectDetection>& objectDetections,
                         float overlapThreshold=0.5f,
                         int numThreads=-1 );

    const vector<string>& getClassNames() const;
    size_t getClassCount() const;

private:
    vector<CvLatentSvmDetector*> detectors;
    vector<string> classNames;
};
} // namespace cv
#endif

#if CV_MINOR_VERSION >= 2
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,LatentSvmDetector> obj_;

/// Alias for argument number check
inline void nargchk(bool cond)
{
    if (!cond)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
}

/** Convert object detections to struct array
 * @param vo vector of detections
 */
mxArray* ObjectDetection2Struct(
    const vector<LatentSvmDetector::ObjectDetection> vo,
    const vector<string>& classNames)
{
    const char* fields[] = {"rect","score","class"};
    MxArray m(fields,3,1,vo.size());
    for (int i=0; i<vo.size(); ++i) {
        m.set("rect", vo[i].rect, i);
        m.set("score", vo[i].score, i);
        m.set("class", classNames[vo[i].classID], i);
    }
    return m;
}
} // local scope
#endif

/**
 * Main entry called from Matlab
 * @param nlhs number of left-hand-side arguments
 * @param plhs pointers to mxArrays in the left-hand-side
 * @param nrhs number of right-hand-side arguments
 * @param prhs pointers to mxArrays in the right-hand-side
 */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
#if CV_MINOR_VERSION >= 2
    nargchk(nrhs>=2 && nlhs<=2);
    vector<MxArray> rhs(prhs,prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());
    
    // Constructor call
    if (method == "new") {
        nargchk(nlhs<=1 && nrhs<=4);
        obj_[++last_id] = LatentSvmDetector();
        // Due to the buggy implementation of LatentSvmDetector in OpenCV
        // we cannot use the constructor syntax other than empty args.
        plhs[0] = MxArray(last_id);
        return;
    }
    
    // Big operation switch
    LatentSvmDetector& obj = obj_[id];
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
    }
    else if (method == "clear") {
        nargchk(nrhs==2 && nlhs==0);
        obj.clear();
    }
    else if (method == "empty") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj.empty());
    }
    else if (method == "load") {
        nargchk(nrhs<=4 && nlhs<=1);
        plhs[0] = (nrhs==3) ? MxArray(obj.load(rhs[2].toVector<string>())) :
            MxArray(obj.load(rhs[2].toVector<string>(), rhs[3].toVector<string>()));
    }
    else if (method == "detect") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        Mat image((rhs[2].isUint8()) ? rhs[2].toMat() : rhs[2].toMat(CV_32F));
        vector<LatentSvmDetector::ObjectDetection> objectDetections;
        float overlapThreshold=0.5f;
        int numThreads=-1;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="OverlapThreshold")
                overlapThreshold = rhs[i+1].toDouble();
            else if (key=="NumThreads")
                numThreads = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option %s", key.c_str());
        }
        obj.detect(image,objectDetections,overlapThreshold,numThreads);
        plhs[0] = ObjectDetection2Struct(objectDetections, obj.getClassNames());
    }
    else if (method == "getClassNames") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj.getClassNames());
    }
    else if (method == "getClassCount") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(static_cast<int>(obj.getClassCount()));
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation %s", method.c_str());
#else
    mexErrMsgIdAndTxt("mexopencv:error","LatentSvmDetector not supported");
#endif
}

#if (CV_MINOR_VERSION >= 2 && (CV_MINOR_VERSION <= 3 && CV_SUBMINOR_VERSION <= 1))
// The following code taken from OpenCV 2.3.2
namespace cv
{
LatentSvmDetector::ObjectDetection::ObjectDetection() : score(0.f), classID(-1)
{}

LatentSvmDetector::ObjectDetection::ObjectDetection( const Rect& _rect, float _score, int _classID ) :
    rect(_rect), score(_score), classID(_classID)
{}

LatentSvmDetector::LatentSvmDetector()
{}

LatentSvmDetector::LatentSvmDetector( const vector<string>& filenames, const vector<string>& _classNames )
{
    load( filenames, _classNames );
}

LatentSvmDetector::~LatentSvmDetector()
{
    clear(); // THIS GIVES SEGFAULT WHEN OBJECT IS COPIED! NEED REFCOUNT!
}

void LatentSvmDetector::clear()
{
    for( size_t i = 0; i < detectors.size(); i++ )
        cvReleaseLatentSvmDetector( &detectors[i] );
    detectors.clear();
    
    classNames.clear();
}

bool LatentSvmDetector::empty() const
{
    return detectors.empty();
}

const vector<string>& LatentSvmDetector::getClassNames() const
{
    return classNames;
}

size_t LatentSvmDetector::getClassCount() const
{
    return classNames.size();
}

string extractModelName( const string& filename )
{
    size_t startPos = filename.rfind('/');
    if( startPos == string::npos )
        startPos = filename.rfind('\\');

    if( startPos == string::npos )
        startPos = 0;
    else
        startPos++;

    const int extentionSize = 4; //.xml

    int substrLength = filename.size() - startPos - extentionSize;

    return filename.substr(startPos, substrLength);
}

bool LatentSvmDetector::load( const vector<string>& filenames, const vector<string>& _classNames )
{
    clear();

    CV_Assert( _classNames.empty() || _classNames.size() == filenames.size() );

    for( size_t i = 0; i < filenames.size(); i++ )
    {
        const string filename = filenames[i];
        if( filename.length() < 5 || filename.substr(filename.length()-4, 4) != ".xml" )
            continue;

        CvLatentSvmDetector* detector = cvLoadLatentSvmDetector( filename.c_str() );
        if( detector )
        {
            detectors.push_back( detector );
            if( _classNames.empty() )
            {
                classNames.push_back( extractModelName(filenames[i]) );
            }
            else
                classNames.push_back( _classNames[i] );
        }
    }

    return !empty();
}

void LatentSvmDetector::detect( const Mat& image,
                                vector<ObjectDetection>& objectDetections,
                                float overlapThreshold,
                                int numThreads )
{
    objectDetections.clear();
    if( numThreads <= 0 )
        numThreads = 1;

    for( size_t classID = 0; classID < detectors.size(); classID++ )
    {
        IplImage image_ipl = image;
        CvMemStorage* storage = cvCreateMemStorage(0);
        CvSeq* detections = cvLatentSvmDetectObjects( &image_ipl, detectors[classID], storage, overlapThreshold, numThreads );
        
        // convert results
        objectDetections.reserve( objectDetections.size() + detections->total );
        for( int detectionIdx = 0; detectionIdx < detections->total; detectionIdx++ )
        {
            CvObjectDetection detection = *(CvObjectDetection*)cvGetSeqElem( detections, detectionIdx );
            objectDetections.push_back( ObjectDetection(Rect(detection.rect), detection.score, (int)classID) );
        }

        cvReleaseMemStorage( &storage );
    }
}

} // namespace cv
#endif
