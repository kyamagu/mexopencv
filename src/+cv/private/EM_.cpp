/**
 * @file EM.cpp
 * @brief mex interface for EM
 * @author Vladimir Eremeev
 * @date 2012
 */
#include "mexopencv.hpp"
#include "opencv2/ml/ml.hpp"
using namespace std;
using namespace cv;

// Persistent objects

/// Last object id to allocate
int last_id = 0;
/// Object container
map<int,EM> obj_;

/// CovMatType map for option processing
const ConstMap<string, int> CovMatType = ConstMap<string, int>
    ("Spherical", EM::COV_MAT_SPHERICAL)
    ("Diagonal",  EM::COV_MAT_DIAGONAL)
    ("Generic",   EM::COV_MAT_GENERIC);

/// CovMatTypeInv map for option processing
const ConstMap<int, string> CovMatTypeInv = ConstMap<int, string>
    (EM::COV_MAT_SPHERICAL, "Spherical")
    (EM::COV_MAT_DIAGONAL,  "Diagonal")
    (EM::COV_MAT_GENERIC,   "Generic");

// convenience macro to return results
#define assign_lhs(ll, label, prob)  do { \
    plhs[0] = MxArray(ll); \
if (nlhs > 1) \
    plhs[1] = MxArray(label); \
if (nlhs > 2) \
    plhs[2] = MxArray(prob); \
} while(0)

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
    // Check the number of arguments
    if (nrhs < 2 || nlhs > 3)
        mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

    // Argument vector
    vector<MxArray> rhs(prhs,prhs+nrhs);
    
    // Determine argument format between constructor or (id,method,...)
    int id = 0;
    string method;
    if (nrhs > 1 && rhs[0].isNumeric() && rhs[1].isChar()) {
        id = rhs[0].toInt();
        method = rhs[1].toString();
    } else {
        mexErrMsgIdAndTxt("mexopencv:error","Invalid arguments");
    }

    // Big operation switch
    if (method == "new") {
        if (nrhs > 3  && (nrhs % 2)==0) {

            int nclusters = EM::DEFAULT_NCLUSTERS;
            int covMatType = EM::COV_MAT_DIAGONAL;
            int maxIter = EM::DEFAULT_MAX_ITERS;
            double eps = FLT_EPSILON;

            for(int i = 2; i < nrhs; i += 2) {
                string key(rhs[i].toString());
                if (key == "Nclusters") {
                    nclusters = rhs[i + 1].toInt();
                } else if (key == "CovMatType") {
                    covMatType = CovMatType[rhs[i + 1].toString()];
                } else if (key == "MaxIters") {
                    maxIter = rhs[i + 1].toInt();
                } else if (key == "Epsilon") {
                    eps = rhs[i + 1].toDouble();
                }
            }

            obj_[++last_id] = EM(nclusters, covMatType, TermCriteria(TermCriteria::COUNT+TermCriteria::EPS, maxIter, eps));
        } else if (nrhs == 2)
            obj_[++last_id] = EM();
        else 
            mexErrMsgIdAndTxt("mexopencv:error","Invalid arguments");
        
        plhs[0] = MxArray(last_id);
        return;
    }

    EM& obj = obj_[id];
    if (method == "delete") {
        if (nrhs != 2 || nlhs != 0)
            mexErrMsgIdAndTxt("mexopencv:error","Output not assigned");
        obj_.erase(id);
    } else if (method == "train") {
        if (nrhs != 3)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat samples = rhs[2].toMat();
        Mat log_likelihoods;
        Mat labels;
        Mat probs;
        obj.train(samples, log_likelihoods, labels, probs);
        assign_lhs(log_likelihoods, labels, probs);
    } else if (method == "trainE") {
        if (nrhs < 4 || (nrhs % 2) != 0)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        Mat samples = rhs[2].toMat();
        Mat means0  = rhs[3].toMat();
        // transpose matrix for convenience
        if (means0.cols == obj.get<int>("nclusters") && means0.rows == samples.cols)
            means0 = means0.t();
        vector<Mat> covs0;
        Mat weights0;
        for(int i = 4; i < nrhs; i += 2) {
            string key = rhs[i].toString();
            if (key == "Covs0") {
                covs0 = rhs[i + 1].toVector<Mat>();
            } else if (key == "Weights0") {
                weights0 = rhs[i + 1].toMat();
            }
        }

        Mat log_likelihoods;
        Mat labels;
        Mat probs;
        obj.trainE(samples, means0, covs0, weights0, log_likelihoods, labels, probs);
        assign_lhs(log_likelihoods, labels, probs);
    } else if (method == "trainM") {
        if (nrhs < 4)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");

        Mat samples = rhs[2].toMat();
        Mat probs0  = rhs[3].toMat();
        // transpose matrix for convenience
        if (probs0.rows == obj.get<int>("nclusters") && probs0.cols == samples.rows)
            probs0 = probs0.t();
        Mat log_likelihoods;
        Mat labels;
        Mat probs;
        obj.trainM(samples, probs0, log_likelihoods, labels, probs);
        assign_lhs(log_likelihoods, labels, probs);
    } else if (method == "nclusters") {
        if (nrhs == 3 && nlhs == 0)
            obj.set(method, rhs[2].toInt());
        else if (nrhs == 2 && nlhs == 1)
            plhs[0] = MxArray(obj.get<int>(method));
        else
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    } else if (method == "covMatType") {
        if (nrhs == 3 && nlhs == 0)
            obj.set(method, CovMatType[rhs[2].toString()]);
        else if (nrhs == 2 && nlhs == 1)
            plhs[0] = MxArray(CovMatTypeInv[obj.get<int>(method)]);
        else
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    } else if (method == "maxIters") {
        if (nrhs == 3 && nlhs == 0)
            obj.set(method, rhs[2].toInt());
        else if (nrhs == 2 && nlhs == 1)
            plhs[0] = MxArray(obj.get<int>(method));
        else
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    } else if (method == "epsilon") {
        if (nrhs == 3 && nlhs == 0)
            obj.set(method, rhs[2].toDouble());
        else if (nrhs == 2 && nlhs == 1)
            plhs[0] = MxArray(obj.get<double>(method));
        else
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    } else if (method == "weights" || method == "means") {
        if (nrhs == 3 && nlhs == 0)
            mexErrMsgIdAndTxt("mexopencv:error","Attempt to set read-only property");
        else if (nrhs == 2 && nlhs == 1)
            plhs[0] = MxArray(obj.get<Mat>(method));
        else
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    } else if (method == "covs") {
        if (nrhs == 3 && nlhs == 0)
            mexErrMsgIdAndTxt("mexopencv:error","Attempt to set read-only property");
        else if (nrhs == 2 && nlhs == 1)
            plhs[0] = MxArray(obj.get<vector<Mat> >(method));
        else
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    } else if (method == "isTrained") {
        if (nrhs == 3 && nlhs == 0)
            mexErrMsgIdAndTxt("mexopencv:error","Attempt to set read-only property");
        else if (nrhs == 2 && nlhs == 1)
            plhs[0] = MxArray(obj.isTrained());
        else
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
    } else if (method == "save") {
        if (nrhs == 3 && nlhs == 0) {
            string filename = rhs[2].toString();
            FileStorage fs(filename, FileStorage::WRITE);
            if (fs.isOpened())
                obj.write(fs);
            else
                mexErrMsgIdAndTxt("mexopencv:error",
                                  "Could not open file %s for writing",
                                  filename.c_str());
        } else {
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        }
    } else if (method == "load") {
        if (nrhs == 3 && nlhs == 0) {
            string filename = rhs[2].toString();
            const FileStorage fs(filename, FileStorage::READ);
            if (fs.isOpened()) {
                const FileNode& fn = fs["StatModel.EM"];
                obj.read(fn);
            } else {
                mexErrMsgIdAndTxt("mexopencv:error",
                                  "Could not open file %s for reading.",
                                  filename.c_str());
            }
        } else {
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of arguments");
        }
    } else if (method == "predict") {
        if (nrhs != 3)
            mexErrMsgIdAndTxt("mexopencv:error","Wrong number of input arguments");
        Mat sample = rhs[2].toMat();
        Mat probs;
        Vec2d result = obj.predict(sample, probs);
        assign_lhs(result[0], result[1], probs);
    }
}
