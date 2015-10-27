/**
 * @file EM_.cpp
 * @brief mex interface for cv::ml::EM
 * @ingroup ml
 * @author Vladimir Eremeev, Amro
 * @date 2012, 2015
 */
#include "mexopencv.hpp"
#include "mexopencv_ml.hpp"
using namespace std;
using namespace cv;
using namespace cv::ml;

// Persistent objects
namespace {
/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,Ptr<EM> > obj_;

/// CovMatType map for option processing
const ConstMap<string, int> CovMatType = ConstMap<string, int>
    ("Spherical", cv::ml::EM::COV_MAT_SPHERICAL)
    ("Diagonal",  cv::ml::EM::COV_MAT_DIAGONAL)
    ("Generic",   cv::ml::EM::COV_MAT_GENERIC)
    ("Default",   cv::ml::EM::COV_MAT_DEFAULT);

/// CovMatTypeInv map for option processing
const ConstMap<int, string> CovMatTypeInv = ConstMap<int, string>
    (cv::ml::EM::COV_MAT_SPHERICAL, "Spherical")
    (cv::ml::EM::COV_MAT_DIAGONAL,  "Diagonal")
    (cv::ml::EM::COV_MAT_GENERIC,   "Generic")
    (cv::ml::EM::COV_MAT_DEFAULT,   "Default");
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

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);
    int id = rhs[0].toInt();
    string method(rhs[1].toString());

    // Constructor is called. Create a new object from argument
    if (method == "new") {
        nargchk(nrhs==2 && nlhs<=1);
        obj_[++last_id] = EM::create();
        plhs[0] = MxArray(last_id);
        return;
    }

    // Big operation switch
    Ptr<EM> obj = obj_[id];
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
            if (key == "ObjName")
                objname = rhs[i+1].toString();
            else if (key == "FromString")
                loadFromString = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        obj_[id] = (loadFromString ?
            Algorithm::loadFromString<EM>(rhs[2].toString(), objname) :
            Algorithm::load<EM>(rhs[2].toString(), objname));
    }
    else if (method == "save") {
        nargchk(nrhs==3 && nlhs<=1);
        string fname(rhs[2].toString());
        if (nlhs > 0) {
            // write to memory, and return string
            FileStorage fs(fname, FileStorage::WRITE + FileStorage::MEMORY);
            fs << obj->getDefaultName() << "{";
            fs << "format" << 3;
            obj->write(fs);
            fs << "}";
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
    else if (method == "getVarCount") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getVarCount());
    }
    else if (method == "isClassifier") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->isClassifier());
    }
    else if (method == "isTrained") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->isTrained());
    }
    else if (method == "train") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=1);
        vector<MxArray> dataOptions;
        int flags = 0;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Data")
                dataOptions = rhs[i+1].toVector<MxArray>();
            else if (key == "Flags")
                flags = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Ptr<TrainData> data;
        if (rhs[2].isChar())
            data = loadTrainData(rhs[2].toString(),
                dataOptions.begin(), dataOptions.end());
        else
            data = createTrainData(
                rhs[2].toMat(CV_32F), Mat(),
                dataOptions.begin(), dataOptions.end());
        bool b = obj->train(data, flags);
        plhs[0] = MxArray(b);
    }
    else if (method == "calcError") {
        nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=2);
        vector<MxArray> dataOptions;
        bool test = false;
        for (int i=4; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Data")
                dataOptions = rhs[i+1].toVector<MxArray>();
            else if (key == "TestError")
                test = rhs[i+1].toBool();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Ptr<TrainData> data;
        if (rhs[2].isChar())
            data = loadTrainData(rhs[2].toString(),
                dataOptions.begin(), dataOptions.end());
        else
            data = createTrainData(
                rhs[2].toMat(CV_32F),
                rhs[3].toMat(rhs[3].isInt32() ? CV_32S : CV_32F),
                dataOptions.begin(), dataOptions.end());
        Mat resp;
        float err = obj->calcError(data, test, (nlhs>1 ? resp : noArray()));
        plhs[0] = MxArray(err);
        if (nlhs>1)
            plhs[1] = MxArray(resp);
    }
    else if (method == "predict") {
        nargchk(nrhs>=3 && (nrhs%2)==1 && nlhs<=2);
        int flags = 0;
        for (int i=3; i<nrhs; i+=2) {
            string key(rhs[i].toString());
            if (key == "Flags")
                flags = rhs[i+1].toInt();
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat samples(rhs[2].toMat(rhs[2].isSingle() ? CV_32F : CV_64F)),
            results;
        float f = obj->predict(samples, results, flags);
        plhs[0] = MxArray(results);
        if (nlhs>1)
            plhs[1] = MxArray(f);
    }
    else if (method == "trainEM") {
        nargchk(nrhs==3 && nlhs<=4);
        Mat samples(rhs[2].toMat(rhs[2].isSingle() ? CV_32F : CV_64F)),
            logLikelihoods, labels, probs;
        bool b = obj->trainEM(samples,
            (nlhs>0 ? logLikelihoods : noArray()),
            (nlhs>1 ? labels : noArray()),
            (nlhs>2 ? probs : noArray()));
        plhs[0] = MxArray(logLikelihoods);
        if (nlhs > 1)
            plhs[1] = MxArray(labels);
        if (nlhs > 2)
            plhs[2] = MxArray(probs);
        if (nlhs > 3)
            plhs[3] = MxArray(b);
    }
    else if (method == "trainE") {
        nargchk(nrhs>=4 && (nrhs%2)==0 && nlhs<=4);
        vector<Mat> covs0;
        Mat weights0;
        for(int i = 4; i < nrhs; i += 2) {
            string key(rhs[i].toString());
            if (key == "Covs0") {
                //covs0 = rhs[i+1].toVector<Mat>();
                covs0.clear();
                vector<MxArray> arr(rhs[i+1].toVector<MxArray>());
                covs0.reserve(arr.size());
                for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
                    covs0.push_back(it->toMat(
                        it->isSingle() ? CV_32F : CV_64F));
            }
            else if (key == "Weights0")
                weights0 = rhs[i+1].toMat(
                    rhs[i+1].isSingle() ? CV_32F : CV_64F);
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                    "Unrecognized option %s", key.c_str());
        }
        Mat samples(rhs[2].toMat(rhs[2].isSingle() ? CV_32F : CV_64F)),
            means0(rhs[3].toMat(rhs[3].isSingle() ? CV_32F : CV_64F)),
            logLikelihoods, labels, probs;
        bool b = obj->trainE(samples, means0, covs0, weights0,
            (nlhs>0 ? logLikelihoods : noArray()),
            (nlhs>1 ? labels : noArray()),
            (nlhs>2 ? probs : noArray()));
        plhs[0] = MxArray(logLikelihoods);
        if (nlhs > 1)
            plhs[1] = MxArray(labels);
        if (nlhs > 2)
            plhs[2] = MxArray(probs);
        if (nlhs > 3)
            plhs[3] = MxArray(b);
    }
    else if (method == "trainM") {
        nargchk(nrhs==4 && nlhs<=4);
        Mat samples(rhs[2].toMat(rhs[2].isSingle() ? CV_32F : CV_64F)),
            probs0(rhs[3].toMat(rhs[3].isSingle() ? CV_32F : CV_64F)),
            logLikelihoods, labels, probs;
        bool b = obj->trainM(samples, probs0,
            (nlhs>0 ? logLikelihoods : noArray()),
            (nlhs>1 ? labels : noArray()),
            (nlhs>2 ? probs : noArray()));
        plhs[0] = MxArray(logLikelihoods);
        if (nlhs > 1)
            plhs[1] = MxArray(labels);
        if (nlhs > 2)
            plhs[2] = MxArray(probs);
        if (nlhs > 3)
            plhs[3] = MxArray(b);
    }
    else if (method == "predict2") {
        nargchk(nrhs==3 && nlhs<=3);
        Mat samples(rhs[2].toMat(rhs[2].isSingle() ? CV_32F : CV_64F)),
            probs;
        if (samples.rows == 1 || samples.cols == 1)
            samples = samples.reshape(1,1); // ensure 1xd vector if one sample
        if (nlhs > 1)
            probs.create(samples.rows, obj->getClustersNumber(), CV_64F);
        vector<Vec2d> results;
        results.reserve(samples.rows);
        for (size_t i = 0; i < samples.rows; ++i) {
            Vec2d res = obj->predict2(samples.row(i),
                (nlhs>1 ? probs.row(i) : noArray()));
            results.push_back(res);
        }
        plhs[0] = MxArray(Mat(results, false).reshape(1,0));  // Nx2
        if (nlhs > 1)
            plhs[1] = MxArray(probs);  // NxK
    }
    else if (method == "getCovs") {
        nargchk(nrhs==2 && nlhs<=1);
        vector<Mat> covs;
        obj->getCovs(covs);
        plhs[0] = MxArray(covs);
    }
    else if (method == "getMeans") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getMeans());
    }
    else if (method == "getWeights") {
        nargchk(nrhs==2 && nlhs<=1);
        plhs[0] = MxArray(obj->getWeights());
    }
    else if (method == "get") {
        nargchk(nrhs==3 && nlhs<=1);
        string prop(rhs[2].toString());
        if (prop == "ClustersNumber")
            plhs[0] = MxArray(obj->getClustersNumber());
        else if (prop == "CovarianceMatrixType")
            plhs[0] = MxArray(CovMatTypeInv[obj->getCovarianceMatrixType()]);
        else if (prop == "TermCriteria")
            plhs[0] = MxArray(obj->getTermCriteria());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else if (method == "set") {
        nargchk(nrhs==4 && nlhs==0);
        string prop(rhs[2].toString());
        if (prop == "ClustersNumber")
            obj->setClustersNumber(rhs[3].toInt());
        else if (prop == "CovarianceMatrixType")
            obj->setCovarianceMatrixType(CovMatType[rhs[3].toString()]);
        else if (prop == "TermCriteria")
            obj->setTermCriteria(rhs[3].toTermCriteria());
        else
            mexErrMsgIdAndTxt("mexopencv:error",
                "Unrecognized property %s", prop.c_str());
    }
    else
        mexErrMsgIdAndTxt("mexopencv:error","Unrecognized operation");
}
