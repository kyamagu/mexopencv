%% Parameters for training face landmark detector
%
% The configuration file mentioned below contains the training parameters
% which are required for training. Description of parameters is as follows:
%
% # *Cascade depth*: This stores the depth of cascade of regressors used for
%   training.
% # *Tree depth*: This stores the depth of trees created as weak learners
%   during gradient boosting.
% # *Number of trees per cascade level*: This stores number of trees required
%   per cascade level.
% # *Learning rate*: This stores the learning rate for gradient boosting. This
%   is required to prevent overfitting using shrinkage.
% # *Oversampling amount*: This stores the oversampling amount for the samples.
% # *Number of test coordinates*: This stores number of test coordinates to be
%   generated as samples to decide for making the split.
% # *Lambda*: This stores the value used for calculating the probabilty which
%   helps to select closer pixels for making the split.
% # *Number of test splits*: This stores the number of test splits to be
%   generated before making the best split.
%
% To get more detailed description about the training parameters you can refer
% to the
% <https://pdfs.semanticscholar.org/d78b/6a5b0dcaa81b1faea5fb0000045a62513567.pdf Research paper>.
%
% These variables have been initialised below as defined in the research paper
% "One millisecond face alignment" CVPR 2014
%
% Sources:
%
% * <https://github.com/opencv/opencv_contrib/blob/3.4.0/modules/face/samples/samplewriteconfigfile.cpp>
% * <https://github.com/opencv/opencv_contrib/blob/3.4.0/modules/face/samples/sample_config_file.xml>
% * <https://github.com/opencv/opencv_extra/blob/3.4.0/testdata/cv/face/config.xml>
%

% [OUTPUT] path to file which you want to create as config file
configFile = fullfile(tempdir(), 'config_kazemi.xml');

S = struct();

% stores the depth of cascade of regressors used for training.
S.cascade_depth = uint32(15);

% stores the depth of trees created as weak learners during gradient boosting.
S.tree_depth = uint32(4);

% stores number of trees required per cascade level.
S.num_trees_per_cascade_level = uint32(500);

% stores the learning rate for gradient boosting.
S.learning_rate = 0.1;

% stores the oversampling amount for the samples.
S.oversampling_amount = uint32(20);

% stores number of test coordinates required for making the split.
S.num_test_coordinates = uint32(400);

% stores the value used for calculating the probabilty.
S.lambda = 0.1;

% stores the number of test splits to be generated before making the best split.
S.num_test_splits = uint32(20);

% write file
cv.FileStorage(configFile, S);
disp('Write Done')
type(configFile)
