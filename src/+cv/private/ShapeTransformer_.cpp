/**
 * @file ShapeTransformer_.cpp
 * @brief mex interface for cv::ShapeTransformer
 * @ingroup shape
 * @author Amro
 * @date 2017
 */
#include "mexopencv.hpp"
#include "mexopencv_shape.hpp"
#include "opencv2/shape.hpp"
using namespace std;
using namespace cv;

namespace {
// Persistent objects
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<ShapeTransformer> > obj_;
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
        obj_[++last_id] = create_ShapeTransformer(
            rhs[2].toString(), rhs.begin() + 3, rhs.end());
        plhs[0] = MxArray(last_id);
        mexLock();
        return;
    }

    // Big operation switch
    Ptr<ShapeTransformer> obj = obj_[id];
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
            Algorithm::loadFromString<ShapeTransformer>(rhs[2].toString(), objname) :
            Algorithm::load<ShapeTransformer>(rhs[2].toString(), objname));
        */
        ///*
        // HACK: ShapeTransformer is abstract, use polymorphic obj->read
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
    else if (method == "estimateTransformation") {
        nargchk(nrhs==5 && nlhs==0);
        vector<DMatch> matches(rhs[4].toVector<DMatch>());
        if (rhs[2].isNumeric() && rhs[3].isNumeric()) {
            // contours expected as 1xNx2
            Mat transformingShape(rhs[2].toMat(CV_32F).reshape(2,1)),
                targetShape(rhs[3].toMat(CV_32F).reshape(2,1));
            obj->estimateTransformation(transformingShape, targetShape, matches);
        }
        else if (rhs[2].isCell() && rhs[3].isCell()) {
            vector<Point2f> transformingShape(rhs[2].toVector<Point2f>()),
                            targetShape(rhs[3].toVector<Point2f>());
            obj->estimateTransformation(transformingShape, targetShape, matches);
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error", "Invalid contour argument");
    }
    else if (method == "applyTransformation") {
        nargchk(nrhs==3 && nlhs<=2);
        float transformCost = 0;
        if (rhs[2].isNumeric()) {
            // Nx2/1xNx2/Nx1x2 -> 1xNx2
            Mat input(rhs[2].toMat(CV_32F).reshape(2,1)),
                output;
            transformCost = obj->applyTransformation(input,
                (nlhs>1 ? output : noArray()));
            if (nlhs > 1)
                // 1xNx2 -> Nx2
                plhs[1] = MxArray(output.reshape(1, output.cols));
        }
        else if (rhs[2].isCell() && rhs[3].isCell()) {
            vector<Point2f> input(rhs[2].toVector<Point2f>()),
                            output;
            transformCost = obj->applyTransformation(input,
                (nlhs>1 ? output : noArray()));
            if (nlhs > 1)
                plhs[1] = MxArray(output);
        }
        plhs[0] = MxArray(transformCost);
    }
    else if (method == "warpImage") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        int flags = cv::INTER_LINEAR;
        int borderMode = cv::BORDER_CONSTANT;
        Scalar borderValue;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Interpolation")
                flags = (rhs[i+1].isChar()) ?
                    InterpType[rhs[i+1].toString()] : rhs[i+1].toInt();
            else if (key == "BorderType")
                borderMode = (rhs[i+1].isChar()) ?
                    BorderType[rhs[i+1].toString()] : rhs[i+1].toInt();
            else if (key == "BorderValue")
                borderValue = rhs[i+1].toScalar();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat transformingImage(rhs[2].toMat()),
            output;
        obj->warpImage(transformingImage, output,
            flags, borderMode, borderValue);
        plhs[0] = MxArray(output);
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "RegularizationParameter") {
            Ptr<ThinPlateSplineShapeTransformer> p =
                obj.dynamicCast<ThinPlateSplineShapeTransformer>();
            if (p.empty())
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Only supported for ThinPlateSplineShapeTransformer");
            plhs[0] = MxArray(p->getRegularizationParameter());
        }
        else if (prop == "FullAffine") {
            Ptr<AffineTransformer> p = obj.dynamicCast<AffineTransformer>();
            if (p.empty())
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Only supported for AffineTransformer");
            plhs[0] = MxArray(p->getFullAffine());
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "RegularizationParameter") {
            Ptr<ThinPlateSplineShapeTransformer> p =
                obj.dynamicCast<ThinPlateSplineShapeTransformer>();
            if (p.empty())
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Only supported for ThinPlateSplineShapeTransformer");
            p->setRegularizationParameter(rhs[3].toDouble());
        }
        else if (prop == "FullAffine") {
            Ptr<AffineTransformer> p = obj.dynamicCast<AffineTransformer>();
            if (p.empty())
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Only supported for AffineTransformer");
            p->setFullAffine(rhs[3].toBool());
        }
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error",
            "Unrecognized operation %s", method.c_str());
}
