%% Classification demo
% This demonstrates an example of machine learning algorithms in a simple
% classification problem. It compares different classifiers using the same
% data samples.

%%
% Prepare data: there are two normal distributions
X = double([randn(1000,5)+.5; randn(1000,5)-.5]); % features
Y =  int32([    ones(1000,1);    -ones(1000,1)]); % labels
test_idx = mod(1:numel(Y),3)==0;                  % train/test split

%%
% try a bunch of classifiers
classifiers = { ...
    cv.ANN_MLP(), ...
    cv.NormalBayesClassifier(), ...
    cv.KNearest(), ...
    cv.SVM(), ...
    cv.Boost(), ...
    cv.RTrees(), ...
    ... cv.ERTrees(), ...
    ... cv.GBTrees(), ...
    cv.LogisticRegression() ...
};

if ~mexopencv.isOctave()
    %TODO: this throws and crashes Octave,
    % while MATLAB gracefully handles exceptions from MEX
    classifiers{end+1} = cv.DTrees();
end

% ANN_MLP must be initialized properly with non-default values
classifiers{1}.LayerSizes = [5,2];
classifiers{1}.setActivationFunction('Sigmoid', 'Param1',1, 'Param2',1);

%%
% for each classifier
for i = 1:numel(classifiers)
    try

        classifier = classifiers{i};
        fprintf('=== %s ===\n', class(classifier));

        Ytrain = Y(~test_idx,:);
        if isa(classifier, 'cv.ANN_MLP')
            % Unroll to an indicator representation
            Ytrain = double([Ytrain==1, Ytrain==-1]);
        elseif isa(classifier, 'cv.LogisticRegression')
            Ytrain = double(Ytrain);
        end
        
        % train
        tic;
        classifier.train(X(~test_idx,:), Ytrain);
        fprintf('Training time %f seconds\n', toc);

        % predict
        tic;
        Yhat = classifier.predict(X(test_idx,:));
        fprintf('Prediction time %f seconds\n', toc);

        if isa(classifier, 'cv.ANN_MLP')
            % Get it back to a categorical vector
            Yhat = (Yhat(:,1) > Yhat(:,2))*2 - 1;
        end

        % evaluate
        accuracy = nnz(Yhat == Y(test_idx)) / nnz(test_idx);
        fprintf('Accuracy: %.2f%%\n', accuracy*100);

    catch ME
        %disp(ME.getReport())
        disp('error!')
    end
end
