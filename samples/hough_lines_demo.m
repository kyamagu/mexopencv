%% Hough Lines Transform
% An example using the Hough line detector.
%
% This program demonstrates line finding with the Hough transform.
% We show how to use the OpenCV functions |cv.HoughLines| and |cv.HoughLinesP|
% to detect lines in an image.
%
% Sources:
%
% * <https://github.com/opencv/opencv/blob/3.2.0/samples/cpp/houghlines.cpp>
% * <https://github.com/opencv/opencv/blob/3.2.0/samples/python/houghlines.py>
% * <https://docs.opencv.org/3.2.0/d9/db0/tutorial_hough_lines.html>
% * <https://github.com/opencv/opencv/blob/3.2.0/samples/cpp/tutorial_code/ImgTrans/HoughLines_Demo.cpp>
% * <https://docs.opencv.org/3.2.0/d6/d10/tutorial_py_houghlines.html>
%

%% Theory
%
% The explanation below belongs to the book *Learning OpenCV* by
% Bradski and Kaehler.
%
% The Hough Line Transform is a transform used to detect straight lines. To
% apply the Transform, first an edge detection pre-processing is desirable.
%
% As you know, a line in the image space can be expressed with two variables.
% For example:
%
% * In the *Cartesian coordinate system:* Parameters: $(m,b)$.
% * In the *Polar coordinate system:* Parameters: $(r,\theta)$
%
% <<https://docs.opencv.org/3.2.0/Hough_Lines_Tutorial_Theory_0.jpg>>
%
% For Hough Transforms, we will express lines in the _Polar system_. Hence, a
% line equation can be written as:
%
% $$y = \left ( -\frac{\cos \theta}{\sin \theta} \right ) x +
%       \left ( \frac{r}{\sin \theta} \right )$$
%
% Arranging the terms: $r = x \cos \theta + y \sin \theta$
%
% In general for each point $(x_{0}, y_{0})$, we can define the family of
% lines that goes through that point as:
%
% $$r_{\theta} = x_{0} \cdot \cos \theta + y_{0} \cdot \sin \theta$$
%
% Meaning that each pair $(r_{\theta},\theta)$ represents each line that
% passes by $(x_{0}, y_{0})$.
%
% If for a given $(x_{0}, y_{0})$ we plot the family of lines that goes
% through it, we get a sinusoid. For instance, for $x_{0} = 8$ and $y_{0} = 6$
% we get the following plot (in a plane $\theta$ - $r$):
%
% <<https://docs.opencv.org/3.2.0/Hough_Lines_Tutorial_Theory_1.jpg>>
%
% We consider only points such that $r > 0$ and $0< \theta < 2 \pi$.
%
% We can do the same operation above for all the points in an image. If the
% curves of two different points intersect in the plane $\theta$ - $r$, that
% means that both points belong to a same line. For instance, following with
% the example above and drawing the plot for two more points:
% $x_{1} = 4$, $y_{1} = 9$ and $x_{2} = 12$, $y_{2} = 3$, we get:
%
% <<https://docs.opencv.org/3.2.0/Hough_Lines_Tutorial_Theory_2.jpg>>
%
% The three plots intersect in one single point $(0.925, 9.6)$, these
% coordinates are the parameters ($\theta, r$) or the line in which
% $(x_{0}, y_{0})$, $(x_{1}, y_{1})$ and $(x_{2}, y_{2})$ lay.
%
% What does all the stuff above mean? It means that in general, a line can be
% _detected_ by finding the number of intersections between curves. The more
% curves intersecting means that the line represented by that intersection
% have more points. In general, we can define a _threshold_ of the minimum
% number of intersections needed to _detect_ a line.
%
% This is what the Hough Line Transform does. It keeps track of the
% intersection between curves of every point in the image. If the number of
% intersections is above some _threshold_, then it declares it as a line with
% the parameters $(\theta, r_{\theta})$ of the intersection point.
%
%% Standard and Probabilistic Hough Line Transform
%
% OpenCV implements two kind of Hough Line Transforms:
%
% 1) *The Standard Hough Transform*
%
% * It consists in pretty much what we just explained in the previous section.
%   It gives you as result a vector of couples $(\theta, r_{\theta})$
% * In OpenCV it is implemented with the function |cv.HoughLines|
%
% 2) *The Probabilistic Hough Line Transform*
%
% * A more efficient implementation of the Hough Line Transform. It gives as
%   output the extremes of the detected lines $(x_{0}, y_{0}, x_{1}, y_{1})$
% * In OpenCV it is implemented with the function |cv.HoughLinesP|
%

%% Code
%
% This program:
%
% * Loads an image
% * Applies either a _Standard Hough Line Transform_ or a
%   _Probabilistic Line Transform_.
% * Display the original image and the detected line in two windows.
%
% You may observe that the number of lines detected vary while you change the
% _threshold_. The explanation is sort of evident: If you establish a higher
% threshold, fewer lines will be detected (since you will need more points to
% declare a line detected).
%

%%
% Input image
if true
    fname = fullfile(mexopencv.root(), 'test', 'sudoku.jpg');
    thresh = 200;
    threshP = 100;
    minlen = 100;
else
    fname = fullfile(mexopencv.root(), 'test', 'pic1.png');
    thresh = 85;
    threshP = 50;
    minlen = 50;
end
src = cv.imread(fname, 'Color',true);

%%
% Edge Detection
gray = cv.cvtColor(src, 'RGB2GRAY');
edges = cv.Canny(gray, [50, 150], 'ApertureSize',3);
imshow(edges), title('Edges')

%%
% HoughLines: Standard Hough Line Transform
tic
lines = cv.HoughLines(edges, 'Rho',1, 'Theta',pi/180, 'Threshold',thresh);
toc

%%
% draw the lines, and display the result
lines = cat(1, lines{:});
rho = lines(:,1);
theta = lines(:,2);
a = cos(theta); b = sin(theta);
x0 = a.*rho; y0 = b.*rho;
pt1 = round([x0 + 1000*(-b), y0 + 1000*(a)]);
pt2 = round([x0 - 1000*(-b), y0 - 1000*(a)]);
out = cv.line(src, pt1, pt2, ...
    'Color',[0 255 0], 'Thickness',2, 'LineType','AA');
figure, imshow(out), title('Detected Lines')

%%
% HoughLinesP: Probabilistic Hough Line Transform
tic
linesP = cv.HoughLinesP(edges, 'Rho',1, 'Theta',pi/180, ...
    'Threshold',threshP, 'MinLineLength',minlen, 'MaxLineGap',10);
toc

%%
% draw the line segments, and display the result
linesP = cat(1, linesP{:});
outP = cv.line(src, linesP(:,1:2), linesP(:,3:4), ...
    'Color',[0 255 0], 'Thickness',2, 'LineType','AA');
figure, imshow(outP), title('Detected Line Segments')
