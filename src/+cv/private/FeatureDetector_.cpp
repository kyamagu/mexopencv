/**
 * @file FeatureDetector_.cpp
 * @brief mex interface for FeatureDetector
 * @author Kota Yamaguchi
 * @date 2012
 */
#include <typeinfo>
#include "mexopencv.hpp"
#include "opencv2/nonfree/nonfree.hpp"
using namespace std;
using namespace cv;

namespace {
/** Algorithm parameter types map
 */
const ConstMap<int,std::string> AlgParamTypes = ConstMap<int,std::string>
    (cv::Param::INT,          "int")
    (cv::Param::BOOLEAN,      "bool")
    (cv::Param::REAL,         "double")
    (cv::Param::STRING,       "string")
    (cv::Param::MAT,          "cv::Mat")
    (cv::Param::MAT_VECTOR,   "std::vector<cv::Mat>")
    (cv::Param::ALGORITHM,    "Algorithm");
    //(cv::Param::FLOAT,        "float")
    //(cv::Param::UNSIGNED_INT, "unsigned")
    //(cv::Param::UINT64,       "uint64")
    //(cv::Param::SHORT,        "short");

/** Function to get algorithm parameter
 * @param obj FeatureDetector object
 * @param param Parameter name string
 * @return parameter value
 */
MxArray get_param(const cv::Ptr<cv::FeatureDetector> &obj, const std::string &param)
{
    MxArray val(static_cast<const mxArray*>(NULL));
    int paramType = obj->paramType(param);
    if (paramType == cv::Param::STRING) {
        val = MxArray( obj->getString(param) );     // obj->get<string>(param)
    } else if (paramType == cv::Param::BOOLEAN) {
        val = MxArray( obj->getBool(param) );       // obj->get<bool>(param)
    } else if (paramType == cv::Param::REAL) {
        val = MxArray( obj->getDouble(param) );     // obj->get<double>(param)
    } else if (paramType == cv::Param::INT ) {
        val = MxArray( obj->getInt(param) );        // obj->get<int>(param)
    } else if (paramType == cv::Param::MAT) {
        val = MxArray( obj->getMat(param) );        // obj->get<cv::Mat>(param)
    } else if (paramType == cv::Param::MAT_VECTOR) {
        val = MxArray( obj->getMatVector(param) );  // obj->get<vector<cv::Mat> >(param)
    } else {
        mexErrMsgIdAndTxt("mexopencv:error", "Unsupported parameter: %s (%s)",
            param.c_str(), AlgParamTypes[paramType].c_str());
    }
    return val;
}

/** Function to set algorithm parameter
 * @param obj FeatureDetector object
 * @param param Parameter name string
 * @param parameter value
 */
void set_param(cv::Ptr<cv::FeatureDetector> &obj, const std::string &param, MxArray val)
{
    int paramType = obj->paramType(param);
    if (paramType == cv::Param::STRING) {
        obj->setString(param, val.toString());
    } else if (paramType == cv::Param::BOOLEAN) {
        obj->setBool(param, val.toBool());
    } else if (paramType == cv::Param::REAL) {
        obj->setDouble(param, val.toDouble());
    } else if (paramType == cv::Param::INT) {
        obj->setInt(param, val.toInt());
    } else if (paramType == cv::Param::MAT) {
        obj->setMat(param, val.toMat());
    } else if (paramType == cv::Param::MAT_VECTOR) {
        obj->setMatVector(param, val.toVector<cv::Mat>());
    } else {
        mexErrMsgIdAndTxt("mexopencv:error", "Unsupported parameter: %s (%s)",
            param.c_str(), AlgParamTypes[paramType].c_str());
    }
}
}

// Persistent objects

/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<FeatureDetector> > obj_;

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
    if (nrhs<1 || nlhs>1)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    if (last_id==0)
        initModule_nonfree();
    
    // Determine argument format between constructor or (id,method,...)
    vector<MxArray> rhs(prhs,prhs+nrhs);
    int id = 0;
    string method;
    if (rhs[0].isChar() && nrhs==1) {
        // Constructor is called. Create a new object from argument
        string detectorType(rhs[0].toString());
        // Temporary work-around of bug (#2585) in the OpenCV.
        Ptr<FeatureDetector> obj = (detectorType == "SimpleBlob")
            ? Ptr<FeatureDetector>(new SimpleBlobDetector) 
            : FeatureDetector::create(detectorType);
        if (obj.empty())
            mexErrMsgIdAndTxt("mexopencv:error","FeatureDetector::create returned empty object");
        obj_[++last_id] = obj;
        plhs[0] = MxArray(last_id);
        return;
    }
    else if (rhs[0].isNumeric() && rhs[0].numel()==1 && nrhs>1) {
        id = rhs[0].toInt();
        method = rhs[1].toString();
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Invalid arguments");
    
    // Big operation switch
    Ptr<FeatureDetector> obj = obj_[id];
    if (method == "delete") {
        if (nrhs!=2 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Output not assigned");
        obj_.erase(id);
    }
    else if (method == "type") {
        if (nrhs!=2)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        plhs[0] = MxArray(string(typeid(*obj).name()));
    }
    else if (method == "detect") {
        if (nrhs<3 || (nrhs%2)!=1)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat mask;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key=="Mask")
                mask = rhs[i+1].toMat(CV_8U);
            else
                mexErrMsgIdAndTxt("mexopencv:error","Unrecognized option");
        }
        
        Mat image(rhs[2].toMat());
        vector<KeyPoint> keypoints;
        obj->detect(image, keypoints, mask);
        plhs[0] = MxArray(keypoints);
    }
    else if (method == "read") {
        if (nrhs!=3 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        FileStorage fs(rhs[2].toString(),FileStorage::READ);
        obj->read(fs.root());
    }
    else if (method == "write") {
        if (nrhs!=3 || nlhs!=0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        FileStorage fs(rhs[2].toString(),FileStorage::WRITE);
        obj->write(fs);
    }
    else if (method == "name") {
        if (nrhs!=2) {
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        }
        plhs[0] = MxArray(obj->name());
    }
    else if (method == "get") {
        if (nrhs == 2) {
            // return a struct with all parameters and their values
            vector<string> params;
            obj->getParams(params);
            MxArray s = MxArray::Struct();
            for(vector<string>::const_iterator p = params.begin(); p != params.end(); ++p) {
                s.set(*p, get_param(obj,*p));
            }
            plhs[0] = s;
        } else if (nrhs == 3 && rhs[2].isChar()) {
            // get parameter
            string param(rhs[2].toString());
            plhs[0] = get_param(obj, param);
        } else {
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        }
    }
    else if (method == "set") {
        if (nrhs == 2) {
            // return a list of all parameter names
            vector<string> params;
            obj->getParams(params);
            plhs[0] = MxArray(params);
        } else if (nrhs == 4 && rhs[2].isChar()) {
            // set parameter
            string param(rhs[2].toString());
            set_param(obj, param, rhs[3]);
        } else {
            mexErrMsgIdAndTxt("mexopencv:error", "Wrong number of arguments");
        }
    }
    else {
        mexErrMsgIdAndTxt("mexopencv:error", "Unrecognized operation");
    }
}
