/**
 * @file StructuredEdgeDetection_.cpp
 * @brief mex interface for cv::ximgproc::StructuredEdgeDetection
 * @ingroup ximgproc
 * @author Amro
 * @date 2016
 */
#include "mexopencv.hpp"
#include "opencv2/ximgproc.hpp"
using namespace std;
using namespace cv;
using namespace cv::ximgproc;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<StructuredEdgeDetection> > obj_;

/// Custom feature extractor class implemented as a MATLAB function.
class MatlabRFFeatureGetter : public cv::ximgproc::RFFeatureGetter
{
public:
    /** Constructor
     * @param func name of an M-file function that implements feature extractor
     */
    explicit MatlabRFFeatureGetter(const string &func)
    : fun_name(func)
    {}

    /** Extracts feature channels from source image.
     * StructureEdgeDetection uses this feature space to detect edges.
     *
     * @param[in] src Source RGB image.
     * @param[out] features Output n-channel floating-point feature matrix.
     * @param[in] gnrmRad Gradient Normalization Radius.
     * @param[in] gsmthRad Gradient Smoothing Radius.
     * @param[in] shrink Shrink Number.
     * @param[in] outNum Number Of Output Channels.
     * @param[in] gradNum Number Of Gradient Orientations.
     */
    virtual void getFeatures(const Mat &src, Mat &features,
        const int gnrmRad, const int gsmthRad, const int shrink,
        const int outNum, const int gradNum) const
    {
        // create input to evaluate kernel function
        MxArray opts(MxArray::Struct());
        opts.set("normRad",   gnrmRad);
        opts.set("grdSmooth", gsmthRad);
        opts.set("shrink",    shrink);
        opts.set("nChns",     outNum);
        opts.set("nOrients",  gradNum);
        mxArray *lhs, *rhs[3];
        rhs[0] = MxArray(fun_name);
        rhs[1] = MxArray(src);  // CV_32FC3
        rhs[2] = opts;

        //TODO: mexCallMATLAB is not thread-safe!
        // evaluate specified function in MATLAB as:
        // features = feval("fun_name", src, opts)
        if (mexCallMATLAB(1, &lhs, 3, rhs, "feval") == 0) {
            MxArray res(lhs);
            CV_Assert(res.isNumeric() && !res.isComplex() && res.ndims() <= 3);
            features = res.toMat(CV_32F);
            //CV_Assert(features.channels() == outNum);
        }
        else {
            //TODO: error
            /*
            // fill with zeros
            features.create(src.size()/shrink, CV_32FC(outNum));
            features.setTo(0);
            */
            // fallback using default implementation
            createRFFeatureGetter()->getFeatures(src, features,
                gnrmRad, gsmthRad, shrink, outNum, gradNum);
        }

        // cleanup
        mxDestroyArray(lhs);
        mxDestroyArray(rhs[0]);
        mxDestroyArray(rhs[1]);
        mxDestroyArray(rhs[2]);
    }

    /** Factory function
     * @param func MATLAB function name.
     * @return smart pointer to newly created instance
     */
    static Ptr<MatlabRFFeatureGetter> create(const string &func)
    {
        return makePtr<MatlabRFFeatureGetter>(func);
    }

private:
    string fun_name;  ///<! name of M-file
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

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        nargchk((nrhs==3||nrhs==4) && nlhs<=1);
        string model(rhs[2].toString());
        Ptr<RFFeatureGetter> howToGetFeatures;
        if (nrhs == 4)
            howToGetFeatures = MatlabRFFeatureGetter::create(
                rhs[3].toString());
        else
            howToGetFeatures = createRFFeatureGetter();
        obj_[++last_id] = createStructuredEdgeDetection(
            model, howToGetFeatures);
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }
    // static method call
    else if (method == "getFeatures") {
        nargchk(nrhs==4 && nlhs<=1);
        Mat src(rhs[2].toMat(CV_32F)),
            features;
        int gnrmRad = rhs[3].at("normRad").toInt(),
            gsmthRad = rhs[3].at("grdSmooth").toInt(),
            shrink = rhs[3].at("shrink").toInt(),
            outNum = rhs[3].at("nChns").toInt(),
            gradNum = rhs[3].at("nOrients").toInt();
        createRFFeatureGetter()->getFeatures(src, features,
            gnrmRad, gsmthRad, shrink, outNum, gradNum);
        plhs[0] = MxArray(features);
        return;
    }

    // Big operation switch
    Ptr<StructuredEdgeDetection> obj = obj_[id];
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
            Algorithm::loadFromString<StructuredEdgeDetection>(rhs[2].toString(), objname) :
            Algorithm::load<StructuredEdgeDetection>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing StructuredEdgeDetection::create()
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
    else if (method == "detectEdges") {
        nargchk(nrhs==3 && nlhs<=1);
        Mat src(rhs[2].toMat(CV_32F)), dst;
        obj->detectEdges(src, dst);
        plhs[0] = MxArray(dst);
    }
    else if (method == "computeOrientation") {
        nargchk(nrhs==3 && nlhs<=1);
        Mat src(rhs[2].toMat(CV_32F)), dst;
        obj->computeOrientation(src, dst);
        plhs[0] = MxArray(dst);
    }
    else if (method == "edgesNms") {
        nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=1);
        int r = 2;
        int s = 0;
        float m = 1;
        bool isParallel = true;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "R")
                r = rhs[i+1].toInt();
            else if (key == "S")
                s = rhs[i+1].toInt();
            else if (key == "M")
                m = rhs[i+1].toFloat();
            else if (key == "IsParallel")
                isParallel = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat edge_image(rhs[2].toMat(CV_32F)),
            orientation_image(rhs[3].toMat(CV_32F)),
            dst;
        obj->edgesNms(edge_image, orientation_image, dst, r, s, m, isParallel);
        plhs[0] = MxArray(dst);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
