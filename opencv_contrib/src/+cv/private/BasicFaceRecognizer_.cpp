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
        p = EigenFaceRecognizer::create(num_components, threshold);
    else if (type == "Fisherfaces")
        p = FisherFaceRecognizer::create(num_components, threshold);
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized face recognizer %s", type.c_str());
    if (p.empty())
        mexErrMsgIdAndTxt("mexopencv:error",
            "Failed to create BasicFaceRecognizer");
    return p;
}

/** Convert results to struct array
 * @param results vector of pairs of label/distance
 * @return struct-array MxArray object
 */
MxArray toStruct(const vector<pair<int,double> >& results)
{
    const char *fields[] = {"label", "distance"};
    MxArray s = MxArray::Struct(fields, 2, 1, results.size());
    for (mwIndex i = 0; i < results.size(); ++i) {
        s.set("label",  results[i].first,  i);
        s.set("distance", results[i].second, i);
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

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        nargchk(nrhs>=3 && nlhs<=1);
        obj_[++last_id] = create_BasicFaceRecognizer(
            rhs[2].toString(), rhs.begin() + 3, rhs.end());
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<BasicFaceRecognizer> obj = obj_[id];
    if (obj.empty())
        mexErrMsgIdAndTxt("mexopencv:error", "Object not found id=%d", id);
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
        mexUnlock();
    }
    else if (method == "typeid") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(string(typeid(*obj).name()));
    }
    else if (method == "clear") {
        nargchk(nrhs==2 && nlhs==0);
        obj->clear();
    }
    else if (method == "read") {
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
            obj->read(fs.getFirstTopLevelNode());
        }
        else
            obj->read(fname);
    }
    else if (method == "write") {
        nargchk(nrhs==3 && nlhs<=1);
        string fname(rhs[2].toString());
        if (nlhs > 0) {
            // write to memory, and return string
            FileStorage fs(fname, FileStorage::WRITE + FileStorage::MEMORY);
            if (!fs.isOpened())
                mexErrMsgIdAndTxt("mexopencv:error", "Failed to open file");
            fs << obj->getDefaultName() << "{";
            obj->write(fs);
            fs << "}";
            plhs[0] = MxArray(fs.releaseAndGetString());
        }
        else
            // write to disk
            obj->write(fname);
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
        if (nlhs > 1) {
            double confidence = 0;
            obj->predict(src, label, confidence);
            plhs[1] = MxArray(confidence);
        }
        else
            label = obj->predict(src);
        plhs[0] = MxArray(label);
    }
    else if (method == "predict_collect") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        bool sorted = false;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Sorted")
                sorted = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat src(rhs[2].toMat(CV_64F));
        Ptr<StandardCollector> collector =
            StandardCollector::create(obj->getThreshold());
        obj->predict(src, collector);
        plhs[0] = toStruct(collector->getResults(sorted));
    }
    else if (method == "setLabelInfo") {
        nargchk(nrhs==4 && nlhs==0);
        int label = rhs[2].toInt();
        string strInfo(rhs[3].toString());
        obj->setLabelInfo(label, strInfo);
    }
    else if (method == "getLabelInfo") {
        nargchk(nrhs==3 && nlhs<=1);
        int label = rhs[2].toInt();
        string strInfo(obj->getLabelInfo(label));
        plhs[0] = MxArray(strInfo);
    }
    else if (method == "getLabelsByString") {
        nargchk(nrhs==3 && nlhs<=1);
        string str(rhs[2].toString());
        vector<int> labels(obj->getLabelsByString(str));
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
