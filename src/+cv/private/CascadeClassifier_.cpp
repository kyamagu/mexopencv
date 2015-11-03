/**
 * @file CascadeClassifier_.cpp
 * @brief mex interface for cv::CascadeClassifier
 * @ingroup objdetect
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

namespace {
// Persistent objects
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<CascadeClassifier> > obj_;

/// feature types for option processing
const ConstMap<int,string> FeatureTypeMap = ConstMap<int,string>
    (-1, "?")
    (0,  "Haar")  // cv::FeatureEvaluator::HAAR
    (1,  "LBP")   // cv::FeatureEvaluator::LBP
    (2,  "HOG");  // cv::FeatureEvaluator::HOG

/// Represents a custom mask generator implemented as a MATLAB function.
class MatlabMaskGenerator : public cv::BaseCascadeClassifier::MaskGenerator
{
public:
    /** Constructor
     * @param func name of an M-file that generates the mask
     */
    explicit MatlabMaskGenerator(const string &func)
    : fun_name(func)
    {}

    /** Initialization method (unused)
     */
    void initializeMask(const Mat& /*src*/)
    {}

    /** Evaluates MATLAB generator function
     * @param src input image.
     * @return generated mask from input image.
     */
    Mat generateMask(const Mat& src)
    {
        // create input to evaluate mask generator function
        mxArray *lhs, *rhs[2];
        rhs[0] = MxArray(fun_name);
        rhs[1] = MxArray(src);

        // evaluate specified function in MATLAB as:
        // mask = feval("fun_name", src)
        Mat mask;
        if (mexCallMATLAB(1, &lhs, 2, rhs, "feval") == 0) {
            MxArray res(lhs);
            CV_Assert(res.isNumeric());
            mask = res.toMat(CV_8U);
        }
        else {
            //TODO: error
            mask = Mat(src.size(), CV_8U, Scalar::all(255));
        }

        // cleanup
        mxDestroyArray(lhs);
        mxDestroyArray(rhs[0]);
        mxDestroyArray(rhs[1]);

        // return mask
        return mask;
    }

    /** Convert object to MxArray
     * @return output MxArray structure
     */
    MxArray toStruct() const
    {
        MxArray s(MxArray::Struct());
        s.set("fun", fun_name);
        return s;
    }

    /** Factory function
     * @param func MATLAB function name.
     * @return smart pointer to newly created instance
     */
    static Ptr<MatlabMaskGenerator> create(const string &func)
    {
        return makePtr<MatlabMaskGenerator>(func);
    }

private:
    string fun_name;    ///<! name of M-file (generator function)
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
    nargchk(nrhs>=2 && nlhs<=3);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor call and static methods
    if (method == "new") {
        nargchk(nrhs==2 && nlhs<=1);
        obj_[++last_id] = makePtr<CascadeClassifier>();
        plhs[0] = MxArray(last_id);
        return;
    }
    else if (method == "convert") {
        nargchk(nrhs==4 && nlhs<=1);
        string oldcascade(rhs[2].toString()),
               newcascade(rhs[3].toString());
        bool success = CascadeClassifier::convert(oldcascade, newcascade);
        if (nlhs > 0)
            plhs[0] = MxArray(success);
        else if (!success)
            mexErrMsgIdAndTxt("mexopencv:error", "Conversion failed");
        return;
    }

    // Big operation switch
    Ptr<CascadeClassifier> obj = obj_[id];
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
    }
    else if (method == "empty") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->empty());
    }
    else if (method == "load") {
        nargchk(nrhs==3 && nlhs<=1);
        string filename(rhs[2].toString());
        bool success = obj->load(filename);
        if (nlhs > 0)
            plhs[0] = MxArray(success);
        else if (!success)
            mexErrMsgIdAndTxt("mexopencv:error",
                "Invalid path or file specified");
    }
    else if (method == "isOldFormatCascade") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->isOldFormatCascade());
    }
    else if (method == "getFeatureType") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(FeatureTypeMap[obj->getFeatureType()]);
    }
    else if (method == "getOriginalWindowSize") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getOriginalWindowSize());
    }
    else if (method == "getMaskGenerator") {
        nargchk(nrhs==2 && nlhs<=1);
        Ptr<BaseCascadeClassifier::MaskGenerator> p = obj->getMaskGenerator();
        if (!p.empty()) {
            Ptr<MatlabMaskGenerator> pp = p.dynamicCast<MatlabMaskGenerator>();
            if (!pp.empty()) {
                plhs[0] = pp->toStruct();
                return;
            }
        }
        plhs[0] = MxArray::Struct();
    }
    else if (method == "setMaskGenerator") {
        nargchk(nrhs==3 && nlhs==0);
        string str(rhs[2].toString());
        Ptr<BaseCascadeClassifier::MaskGenerator> p;
        if (str == "FaceDetectionMaskGenerator")
            p = createFaceDetectionMaskGenerator();
        else
            p = MatlabMaskGenerator::create(str);
        obj->setMaskGenerator(p);
    }
    else if (method == "detectMultiScale") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=3);
        double scaleFactor = 1.1;
        int minNeighbors = 3;
        int flags = 0;
        Size minSize, maxSize;
        bool outputRejectLevels = false;
        for (int i=3; i<rhs.size(); i+=2) {
            string key(rhs[i].toString());
            if (key=="ScaleFactor")
                scaleFactor = rhs[i+1].toDouble();
            else if (key=="MinNeighbors")
                minNeighbors = rhs[i+1].toInt();
            else if (key=="DoCannyPruning")
                UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CASCADE_DO_CANNY_PRUNING);
            else if (key=="ScaleImage")
                UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CASCADE_SCALE_IMAGE);
            else if (key=="FindBiggestObject")
                UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CASCADE_FIND_BIGGEST_OBJECT);
            else if (key=="DoRoughSearch")
                UPDATE_FLAG(flags, rhs[i+1].toBool(), cv::CASCADE_DO_ROUGH_SEARCH);
            else if (key=="Flags")
                flags = rhs[i+1].toInt();
            else if (key=="MinSize")
                minSize = rhs[i+1].toSize();
            else if (key=="MaxSize")
                maxSize = rhs[i+1].toSize();
            else if (key=="OutputRejectLevels")
                outputRejectLevels = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s",key.c_str());
        }
        // choose from one of the 3 variants based on nargout
        Mat image(rhs[2].toMat(CV_8U));
        vector<Rect> objects;
        if (nlhs > 2 || outputRejectLevels) {
            outputRejectLevels = true;
            vector<int> rejectLevels;
            vector<double> levelWeights;
            obj->detectMultiScale(image, objects, rejectLevels, levelWeights,
                scaleFactor, minNeighbors, flags, minSize, maxSize,
                outputRejectLevels);
            if (nlhs > 1)
                plhs[1] = MxArray(rejectLevels);
            if (nlhs > 2)
                plhs[2] = MxArray(levelWeights);
        }
        else if (nlhs > 1) {
            vector<int> numDetections;
            obj->detectMultiScale(image, objects, numDetections,
                scaleFactor, minNeighbors, flags, minSize, maxSize);
            plhs[1] = MxArray(numDetections);
        }
        else
            obj->detectMultiScale(image, objects,
                scaleFactor, minNeighbors, flags, minSize, maxSize);
        plhs[0] = MxArray(objects);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
