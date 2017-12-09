%% Letter Recognition using kNN
%
% We will use kNN to build a basic OCR application.
%
% Sources:
%
% * <https://docs.opencv.org/3.2.0/d8/d4b/tutorial_py_knn_opencv.html>
%

%% English Alphabets Dataset
%
% This example is similar to the digits dataset seen in another demo, but for
% the English alphabets, there is a slight change in data and feature set.
% Here, instead of images, OpenCV comes with a data file,
% |letter-recognition.data|. If you open it, you will see 20000 lines. In each
% row, first column is an alphabet which is our label. Next 16 numbers
% following it are its different features. These features are obtained from
% _UCI Machine Learning Repository_. You can find the details of these
% features <http://archive.ics.uci.edu/ml/datasets/Letter+Recognition here>.
%
% There are 20000 samples available, so we take first 10000 data as training
% samples and remaining 10000 as test samples. We also should change the
% alphabets to ASCII codes as integer class labels.
%

%%
% Load dataset
fname = fullfile(mexopencv.root(), 'test', 'letter-recognition.data');
if exist(fname, 'file') ~= 2
    disp('Downloading dataset...')
    url = 'https://cdn.rawgit.com/opencv/opencv/3.2.0/samples/data/letter-recognition.data';
    urlwrite(url, fname);
end
if ~mexopencv.isOctave()
    fid = fopen(fname, 'rt');
    D = textscan(fid, ['%c' repmat(' %d',1,16)], 20000, ...
        'Delimiter',',', 'CollectOutput',true);
    fclose(fid);
else
    %HACK: textscan failed to read the whole file in Octave!
    D = cell(1,1+16);
    [D{:}] = textread(fname, ['%s' repmat(' %d',1,16)], 20000, 'Delimiter',',');
    D = {char(D{1}), cat(2, D{2:end})};
end

%%
% Prepare data for classification
labels = int32(D{1}) - int32('A');
data = single(D{2});
whos data labels
if ~mexopencv.isOctave() && mexopencv.require('stats')
    %HACK: tabulate in Octave behaves differently
    tabulate(sort(D{1}))
end
N = 10000;  % fix(numel(labels)/2)

%% Train
K = 5;
knn = cv.KNearest();
knn.DefaultK = K;
fprintf('Training... '); tic
knn.train(data(1:N,:), labels(1:N));
toc

%% Test
fprintf('Testing... '); tic
yhat = knn.findNearest(data(N+1:end,:), K);
toc
%TODO: https://savannah.gnu.org/bugs/?50716

%%
% Performance on test set
confmat = accumarray([labels(N+1:end), yhat]+1, 1);
fprintf('Accuracy = %d/%d\n', trace(confmat), sum(confmat(:)));
if mexopencv.isOctave()
    display(confmat)
else
    % Display confusion matrix as a nicley formatted table
    letters = cellstr(unique(D{1}));  % num2cell('A':'Z')
    t = array2table(confmat, 'RowNames',letters, 'VariableNames',letters);
    display(t)

    % We can see how most classification errors involve similar looking letters
    [r,c,v] = find(triu(confmat,1) + tril(confmat,-1).');
    t = table(letters(r), letters(c), v, ...
        'VariableNames',{'letter1', 'letter2', 'err'});
    t = sortrows(t, [-3 1 2]);
    display(t(1:min(end,10),:))
end

%% Citations
%
% * P. W. Frey and D. J. Slate. "Letter Recognition Using Holland-style
%   Adaptive Classifiers". Machine Learning Vol 6 #2, March 91.
% * M. Lichman, "UCI Machine Learning Repository", 2013.
%   <http://archive.ics.uci.edu/ml>. University of California, Irvine,
%   School of Information and Computer Science.
%
