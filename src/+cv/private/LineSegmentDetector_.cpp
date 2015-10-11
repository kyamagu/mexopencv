/**
 * @file LineSegmentDetector_.cpp
 * @brief mex interface for cv::LineSegmentDetector
 * @ingroup imgproc
 * @author Amro
 * @date 2015
 */
#include "mexopencv.hpp"
using namespace std;
using namespace cv;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<LineSegmentDetector> > obj_;

/// Line Segment Detector modes for option processing
const ConstMap<string,int> LineSegmentDetectorModesMap = ConstMap<string,int>
    ("None",     cv::LSD_REFINE_NONE)  // No refinement applied.
    ("Standard", cv::LSD_REFINE_STD)   // Standard refinement is applied.
    ("Advanced", cv::LSD_REFINE_ADV);  // Advanced refinement.
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
    nargchk(nrhs>=2 && nlhs<=4);

    // Arguments vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        nargchk(nrhs>=2 && (nrhs%2)==0 && nlhs<=1);
        int refine = cv::LSD_REFINE_STD;
        double scale = 0.8;
        double sigma_scale = 0.6;
        double quant = 2.0;
        double ang_th = 22.5;
        double log_eps = 0;
        double density_th = 0.7;
        int n_bins = 1024;
        for (int i=2; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="Refine")
                refine = LineSegmentDetectorModesMap[rhs[i+1].toString()];
            else if (key=="Scale")
                scale = rhs[i+1].toDouble();
            else if (key=="SigmaScale")
                sigma_scale = rhs[i+1].toDouble();
            else if (key=="QuantError")
                quant = rhs[i+1].toDouble();
            else if (key=="AngleTol")
                ang_th = rhs[i+1].toDouble();
            else if (key=="DetectionThreshold")
                log_eps = rhs[i+1].toDouble();
            else if (key=="MinDensity")
                density_th = rhs[i+1].toDouble();
            else if (key=="NBins")
                n_bins = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        obj_[++last_id] = createLineSegmentDetector(refine, scale,
            sigma_scale, quant, ang_th, log_eps, density_th, n_bins);
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<LineSegmentDetector> obj = obj_[id];
    if (method == "delete") {
        nargchk(nrhs==2 && nlhs==0);
        obj_.erase(id);
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
            if (key=="ObjName")
                objname = rhs[i+1].toString();
            else if (key=="FromString")
                loadFromString = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        /*
        obj_[id] = (loadFromString ?
            Algorithm::loadFromString<LineSegmentDetector>(rhs[2].toString(), objname) :
            Algorithm::load<LineSegmentDetector>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: workaround for missing LineSegmentDetector::create()
        FileStorage fs(rhs[2].toString(), FileStorage::READ +
            (loadFromString ? FileStorage::MEMORY : 0));
        obj->read(objname.empty() ? fs.getFirstTopLevelNode() : fs[objname]);
        if (obj.empty())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to load algorithm");
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
    else if (method == "detect") {
        nargchk(nrhs==3 && nlhs<=4);
        Mat image(rhs[2].toMat(CV_8U)), width, prec, nfa;
        vector<Vec4f> lines;
        obj->detect(image, lines,
            (nlhs>1 ? width : noArray()),
            (nlhs>2 ? prec  : noArray()),
            (nlhs>3 ? nfa   : noArray()));
        plhs[0] = MxArray(lines);
        if (nlhs>1)
            plhs[1] = MxArray(width);
        if (nlhs>2)
            plhs[2] = MxArray(prec);
        if (nlhs>3)
            plhs[3] = MxArray(nfa);
    }
    else if (method == "drawSegments") {
        nargchk(nrhs==4 && nlhs<=1);
        Mat image(rhs[2].toMat());
        //vector<Vec4f> lines(MxArrayToVectorVec<float,4>(rhs[3]));
        vector<Vec4f> lines(rhs[3].toVector<Vec4f>());
        obj->drawSegments(image, lines);
        plhs[0] = MxArray(image);
    }
    else if (method == "compareSegments") {
        nargchk(nrhs>=5 && (nrhs%2)==1 && nlhs<=2);
        Size size(rhs[2].toSize());
        Mat image;
        for (int i=5; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="Image")
                image = rhs[i+1].toMat();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        if (image.empty()) {
            image.create(size, CV_8UC3);
            image.setTo(Scalar::all(0));
        }
        //vector<Vec4f> lines1(MxArrayToVectorVec<float,4>(rhs[3])),
        //              lines2(MxArrayToVectorVec<float,4>(rhs[4]));
        vector<Vec4f> lines1(rhs[3].toVector<Vec4f>()),
                      lines2(rhs[4].toVector<Vec4f>());
        int count = obj->compareSegments(size, lines1, lines2, image);
        plhs[0] = MxArray(image);
        if (nlhs>1)
            plhs[1] = MxArray(count);
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
