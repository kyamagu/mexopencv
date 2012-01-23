function classification_demo
%CLASSIFICATION_DEMO  classification demo
%
% This demonstrates an example of machine learning algorithms in a simple
% classification problem. It compares different classifiers using the same
% data samples.
%
% Before start, addpath('/path/to/mexopencv');
%

% Prepare data: there are two normal distributions
X = [randn(1000,5)+.5; randn(1000,5)-.5]; % features
Y = [    ones(1000,1);    -ones(1000,1)]; % labels
test_idx = mod(1:numel(Y),3)==0;

% Try ANN_MLP
ann_mlp_demo(cv.ANN_MLP([5,2]), X, Y, test_idx);

% Try other classifiers
classifiers = {...
	cv.DTree,   {'VarType', 'Categorical'},...
	cv.Boost,   {'VarType', 'Categorical'},...
	cv.RTrees,  {'VarType', 'Categorical'},...
	cv.ERTrees, {'VarType', 'Categorical'},...
...% cv.GBTrees, {'VarType', 'Categorical', 'LossFunctionType', 'Deviance'},...
	cv.NormalBayesClassifier, {},...
	cv.KNearest, {},...
	cv.SVM, {}...
};
for i = 1:2:numel(classifiers)
    classifier_demo(classifiers{i}, X, Y, test_idx, classifiers{i+1});
end

end

function ann_mlp_demo(classifier, X, Y, test_idx)
%ANN_MLP_DEMO

Yi = double([Y==1,Y==-1]); % Unroll to an indicator representation

fprintf('=== %s ===\n',class(classifier));
tic;
classifier.train(X(~test_idx,:),Yi(~test_idx,:));
fprintf('Training time %f seconds\n',toc);
tic;
Yihat = classifier.predict(X(test_idx,:));
fprintf('Prediction time %f seconds\n',toc);

Yhat = 2*(Yihat(:,1)>Yihat(:,2))-1; % Get it back to categorical vector

accuracy = nnz(Yhat==Y(test_idx)) / nnz(test_idx);
fprintf('Accuracy: %f\n',accuracy);

end

function classifier_demo(classifier, X, Y, test_idx, option)
%CLASSIFIER_DEMO

fprintf('=== %s ===\n',class(classifier));
tic;
classifier.train(X(~test_idx,:),Y(~test_idx), option{:});
fprintf('Training time %f seconds\n',toc);
tic;
Yhat = classifier.predict(X(test_idx,:));
fprintf('Prediction time %f seconds\n',toc);
accuracy = nnz(Yhat==Y(test_idx)) / nnz(test_idx);
fprintf('Accuracy: %f\n',accuracy);

end