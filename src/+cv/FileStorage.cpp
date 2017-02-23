/**
 * @file FileStorage.cpp
 * @brief mex interface for cv::FileStorage
 * @ingroup core
 * @author Kota Yamaguchi
 * @date 2012
 */
#include "mexopencv.hpp"
#include <sstream>
using namespace std;
using namespace cv;

namespace {
/** Check if the node is of a user-defined type
 * @param node node to test.
 * @param type_name type name. e.g., "opencv-matrix"
 * @return flag
 */
bool isa(const FileNode& node, const string& type_name)
{
    const CvFileNode* pnode = (*node);
    return (pnode && pnode->info && pnode->info->type_name) ?
        (string(pnode->info->type_name) == type_name) : false;
}

/** Recursive function to output to a file storage
 * @param fs FileStorage object
 * @param x MxArray to be read
 * @param node FileNode to read
 */
void read(FileStorage& fs, MxArray& x, const FileNode& node)
{
    if (node.type() == FileNode::SEQ) {
        size_t n = node.size();
        vector<MxArray> v(n, MxArray(static_cast<mxArray*>(NULL)));
        for (size_t i=0; i<n; ++i) {
            const FileNode& elem = node[i];
            switch (elem.type()) {
                case FileNode::INT:
                    v[i] = MxArray(static_cast<int>(elem));
                    break;
                case FileNode::REAL:
                    v[i] = MxArray(static_cast<double>(elem));
                    break;
                case FileNode::STR:
                    v[i] = MxArray(static_cast<string>(elem));
                    break;
                case FileNode::SEQ: {
                    MxArray y(static_cast<mxArray*>(NULL));
                    read(fs, y, elem);
                    v[i] = y;
                    break;
                }
                case FileNode::MAP: {
                    if (isa(elem, "opencv-matrix")) {
                        Mat m;
                        elem >> m;
                        v[i] = MxArray(m);
                    }
                    else if (isa(elem, "opencv-nd-matrix")) {
                        MatND m;
                        elem >> m;
                        v[i] = MxArray(m);
                    }
                    else if (isa(elem, "opencv-sparse-matrix")) {
                        SparseMat m;
                        elem >> m;
                        v[i] = MxArray(m);
                    }
                    else {
                        MxArray y = MxArray::Struct();
                        read(fs, y, elem);
                        v[i] = y;
                    }
                    break;
                }
            }
        }
        x = MxArray(v);
    }
    else if (node.type() == FileNode::MAP) {
        int i = 1;
        for (FileNodeIterator it = node.begin(); it != node.end(); ++it) {
            const FileNode& elem = (*it);
            string name(elem.name());
            if (name.empty()) {
                //HACK: create a unique field name for the current struct
                ostringstream ss;
                ss << "x" << (i++);
                name = ss.str();
            }
            switch (elem.type()) {
                case FileNode::INT:
                    x.set(name, static_cast<int>(elem));
                    break;
                case FileNode::REAL:
                    x.set(name, static_cast<double>(elem));
                    break;
                case FileNode::STR:
                    x.set(name, static_cast<string>(elem));
                    break;
                case FileNode::SEQ: {
                    MxArray y(static_cast<mxArray*>(NULL));
                    read(fs, y, elem);
                    x.set(name, y);
                    break;
                }
                case FileNode::MAP: {
                    if (isa(elem, "opencv-matrix")) {
                        Mat m;
                        elem >> m;
                        x.set(name, m);
                    }
                    else if (isa(elem, "opencv-nd-matrix")) {
                        MatND m;
                        elem >> m;
                        x.set(name, m);
                    }
                    else if (isa(elem, "opencv-sparse-matrix")) {
                        SparseMat m;
                        elem >> m;
                        x.set(name, m);
                    }
                    else {
                        MxArray y = MxArray::Struct();
                        read(fs, y, elem);
                        x.set(name, y);
                    }
                    break;
                }
            }
        }
    }
}

/** Recursive function to output to a file storage
 * @param fs FileStorage object
 * @param x MxArray to be written
 * @param root Flag inidicating the root node
 */
void write(FileStorage& fs, const MxArray& x, bool root=false)
{
    mxClassID classid = x.classID();
    switch (classid) {
        case mxUNKNOWN_CLASS:
        case mxFUNCTION_CLASS:
            mexErrMsgIdAndTxt("mexopencv:error", "Invalid MxArray");
            break;
        case mxSTRUCT_CLASS: {
            mwSize n = x.numel();
            vector<string> fields(x.fieldnames());
            if (n > 1) fs << "[";
            for (mwIndex i=0; i<n; ++i) {
                if (!root) fs << "{";
                for (vector<string>::const_iterator it = fields.begin(); it != fields.end(); ++it) {
                    fs << (*it);
                    write(fs, MxArray(x.at(*it, i)));
                }
                if (!root) fs << "}";
            }
            if (n > 1) fs << "]";
            break;
        }
        case mxCELL_CLASS: {
            vector<MxArray> arr(x.toVector<MxArray>());
            fs << "[";
            for (vector<MxArray>::const_iterator it = arr.begin(); it != arr.end(); ++it)
                write(fs, *it);
            fs << "]";
            break;
        }
        case mxCHAR_CLASS:
            fs << x.toString();
            break;
        default:  // x.isNumeric() or x.isLogical()
            if (x.numel() == 1) {
                switch (classid) {
                    case mxDOUBLE_CLASS:
                        fs << x.toDouble();
                        break;
                    case mxSINGLE_CLASS:
                        fs << x.toFloat();
                        break;
                    default:
                        fs << x.toInt();
                        break;
                }
            }
            else if (x.isSparse())
                fs << x.toSparseMat();
            else
                fs << x.toMat();
    }
}
}  // anonymous namespace

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
    nargchk(nrhs>=1 && nlhs<=2);

    // Argument vector
    vector<MxArray> rhs(prhs, prhs+nrhs);

    string filename(rhs[0].toString());
    if (nrhs == 1) {
        // Read
        FileStorage fs(filename, FileStorage::READ +
            ((nlhs > 1) ? FileStorage::MEMORY : 0));
        if (!fs.isOpened())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to open file");
        FileNode fn(fs.root());
        if (fn.empty())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to get node");
        MxArray s = MxArray::Struct();
        read(fs, s, fn);
        plhs[0] = s;
        if (nlhs > 1)
            plhs[1] = MxArray(true);  // dummy output
    }
    else {
        // Write
        nargchk(nrhs>=2 && nlhs<=1);
        FileStorage fs(filename, FileStorage::WRITE +
            ((nlhs > 0) ? FileStorage::MEMORY : 0));
        if (!fs.isOpened())
            mexErrMsgIdAndTxt("mexopencv:error", "Failed to open file");
        if (nrhs==2 && rhs[1].isStruct() && rhs[1].numel()==1)
            // Write a scalar struct
            write(fs, rhs[1], true);
        else {
            // Create a temporary scalar struct and write
            string nodeName(FileStorage::getDefaultObjectName(filename));
            MxArray s = MxArray::Struct();
            if (nrhs == 2)
                s.set(nodeName, rhs[1].clone());
            else {
                MxArray cell = MxArray::Cell(nrhs-1);
                for (int i=0; i<nrhs-1; ++i)
                    cell.set(i, rhs[i+1].clone());
                s.set(nodeName, cell);
            }
            write(fs, s, true);
            s.destroy();
        }
        if (nlhs > 0)
            plhs[0] = MxArray(fs.releaseAndGetString());
    }
}
