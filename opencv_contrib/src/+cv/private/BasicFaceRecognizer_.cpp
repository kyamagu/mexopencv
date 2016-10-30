/**
 * @file BasicFaceRecognizer_.cpp
 * @brief mex interface for cv::face::BasicFaceRecognizer
 * @ingroup face
 * @author Amro
 * @date 2016
 */
#include "mexopencv.hpp"
#include "opencv2/face.hpp"
#include <typeinfo>
using namespace std;
using namespace cv;
using namespace cv::face;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<BasicFaceRecognizer> > obj_;

/// A custom predict collector class used in prediction
class CustomPredictCollector : public cv::face::PredictCollector
{
public:
    /** Constructor
     * @param threshold threshold on distance
     */
    explicit CustomPredictCollector(double threshold = DBL_MAX)
    : PredictCollector(threshold)
    {}

    /** Initialization called once at start of recognition
     * @param size total size of prediction evaluation that recognizer could perform
     * @param state user defined optional value to allow multi-session or aggregation scenarios
     */
    void init(const int size, const int state = 0)
    {
        PredictCollector::init(size, state);
        m_labels.reserve(size);
        m_dists.reserve(size);
    }

    /** Emit called with every recognition result
     * @param label current prediction label
     * @param dist current prediction distance (confidence)
     * @param state user defined optional value to allow multi-session or aggregation scenarios
     * @return true if recognizer should proceed prediction,
     *         false if recognizer should terminate prediction.
     */
    bool emit(const int label, const double dist, const int state = 0)
    {
        // only track its own session
        if (_state != state)
            return false;

        // store label/dist pair
        m_labels.push_back(label);
        m_dists.push_back(dist);

        // always keep going, we want to collect all predictions
        return true;
    }

    /// retrieve stored vector of all prediction labels
    vector<int> getLabels() const
    {
        return m_labels;
    }

    /// retrieve stored vector of all prediction distances
    vector<double> getDists() const
    {
        return m_dists;
    }

    /** Factory function
     * @param threshold threshold on distance
     * @return smart pointer to newly created instance
     */
    static Ptr<CustomPredictCollector> create(double threshold = DBL_MAX)
    {
        return makePtr<CustomPredictCollector>(threshold);
    }

private:
    vector<int> m_labels;    ///<! labels
    vector<double> m_dists;  ///<! distances
};

/** Create an instance of BasicFaceRecognizer using options in arguments
 * @param type face recognizer type, one of:
 *    - "Eigenfaces"
 *    - "Fisherfaces"
 * @param first iterator at the beginning of the vector range
 * @param last iterator at the end of the vector range
 * @return smart pointer to created BasicFaceRecognizer
 */
Ptr<BasicFaceRecognizer> create_BasicFaceRecognizer(
    const string& type,
    vector<MxArray>::const_iterator first,
    vector<MxArray>::const_iterator last)
{
    ptrdiff_t len = std::distance(first, last);
    nargchk((len%2)==0);
    int num_components = 0;
    double threshold = DBL_MAX;
    for (; first != last; first += 2) {
        string key(first->toString());
        const MxArray& val = *(first + 1);
        if (key == "NumComponents")
            num_components = val.toInt();
        else if (key == "Threshold")
            threshold = val.toDouble();
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized option %s", key.c_str());
    }
    Ptr<BasicFaceRecognizer> p;
    if (type == "Eigenfaces")
        p = createEigenFaceRecognizer(num_components, threshold);
    else if (type == "Fisherfaces")
        p = createFisherFaceRecognizer(num_components, threshold);
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized face recognizer %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create BasicFaceRecognizer");
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
    nargchk(nrhs>=2 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        nargchk(nrhs>=3 && nlhs<=1);
        obj_[++last_id] = create_BasicFaceRecognizer(
            rhs[2].toString(), rhs.begin() + 3, rhs.end());
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<BasicFaceRecognizer> obj = obj_[id];
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
    }
    else if (method == "typeid") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(string(typeid(*obj).name()));
    }
    else if (method == "clear") {
        nargchk(nrhs==2 && nlhs==0);
        obj->clear();
    }
    else if (method == "load") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs==0);
        bool loadFromString = false;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "FromString")
                loadFromString = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        string fname(rhs[2].toString());
        if (loadFromString) {
            FileStorage fs(fname, FileStorage::READ + FileStorage::MEMORY);
            if (!fs.isOpened())
                mexErrMsgIdAndTxt("mexopencv:error", "Failed to open file");
            obj->load(fs);
        }
        else
            obj->load(fname);
    }
    else if (method == "save") {
        nargchk(nrhs==3 && nlhs<=1);
        string fname(rhs[2].toString());
        if (nlhs > 0) {
            // write to memory, and return string
            FileStorage fs(fname, FileStorage::WRITE + FileStorage::MEMORY);
            if (!fs.isOpened())
                mexErrMsgIdAndTxt("mexopencv:error", "Failed to open file");
            obj->save(fs);
            plhs[0] = MxArray(fs.releaseAndGetString());
        }
        else
            // write to disk
            obj->save(fname);
    }
    else if (method == "empty") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->empty());
    }
    else if (method == "getDefaultName") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getDefaultName());
    }
    else if (method == "train") {
        nargchk(nrhs==4 && nlhs==0);
        //vector<Mat> src(rhs[2].toVector<Mat>());
        vector<Mat> src;
        {
            vector<MxArray> arr(rhs[2].toVector<MxArray>());
            src.reserve(arr.size());
            for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
                src.push_back(it->toMat(CV_64F));
        }
        Mat labels(rhs[3].toMat(CV_32S));
        obj->train(src, labels);
    }
    else if (method == "update") {
        nargchk(nrhs==4 && nlhs==0);
        //vector<Mat> src(rhs[2].toVector<Mat>());
        vector<Mat> src;
        {
            vector<MxArray> arr(rhs[2].toVector<MxArray>());
            src.reserve(arr.size());
            for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
                src.push_back(it->toMat(CV_64F));
        }
        Mat labels(rhs[3].toMat(CV_32S));
        obj->update(src, labels);
    }
    else if (method == "predict") {
        nargchk(nrhs==3 && nlhs<=2);
        Mat src(rhs[2].toMat(CV_64F));
        int label = -1;
        double confidence = 0;
        if (nlhs > 1) {
            obj->predict(src, label, confidence);
            plhs[1] = MxArray(confidence);
        }
        else
            label = obj->predict(src);
        plhs[0] = MxArray(label);
    }
    else if (method == "predict_collect") {
        nargchk(nrhs==3 && nlhs<=2);
        Mat src(rhs[2].toMat(CV_64F));
        Ptr<CustomPredictCollector> collector =
            CustomPredictCollector::create(obj->getThreshold());
        obj->predict(src, collector, 0);
        plhs[0] = MxArray(collector->getLabels());
        if (nlhs > 1)
            plhs[1] = MxArray(collector->getDists());
    }
    else if (method == "setLabelInfo") {
        nargchk(nrhs==4 && nlhs==0);
        int label = rhs[2].toInt();
        string strInfo = rhs[3].toString();
        obj->setLabelInfo(label, strInfo);
    }
    else if (method == "getLabelInfo") {
        nargchk(nrhs==3 && nlhs<=1);
        int label = rhs[2].toInt();
        string strInfo = obj->getLabelInfo(label);
        plhs[0] = MxArray(strInfo);
    }
    else if (method == "getLabelsByString") {
        nargchk(nrhs==3 && nlhs<=1);
        string str = rhs[2].toString();
        vector<int> labels = obj->getLabelsByString(str);
        plhs[0] = MxArray(labels);
    }
    else if (method == "getProjections") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getProjections());
    }
    else if (method == "getLabels") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getLabels());
    }
    else if (method == "getEigenValues") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getEigenValues());
    }
    else if (method == "getEigenVectors") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getEigenVectors());
    }
    else if (method == "getMean") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getMean());
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "NumComponents")
            plhs[0] = MxArray(obj->getNumComponents());
        else if (prop == "Threshold")
            plhs[0] = MxArray(obj->getThreshold());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "NumComponents")
            obj->setNumComponents(rhs[3].toInt());
        else if (prop == "Threshold")
            obj->setThreshold(rhs[3].toDouble());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
