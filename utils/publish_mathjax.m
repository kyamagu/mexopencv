function outputFilename = publish_mathjax(file, opts, varargin)
    %PUBLISH_MATHJAX  Publish to HTML, and use MathJax to render equations
    %
    % ## Input
    % * __file__ M-file to publish.
    % * __opts__ Structure of options. By default this function uses a custom
    %   XSL stylesheet to publish as HTML with MathJax rendered equations, i.e
    %   `struct('format','html', 'stylesheet','mxdom2mathjax.xsl')`
    %
    % ## Output
    % * __outputFilename__ path to the generated HTML document.
    %
    % ## Options
    % Accepts the same option as the publish function.
    %
    % ## Example
    %
    %     html = publish_mathjax('my_script.m');
    %     web(html, '-browser')
    %
    %     showdemo('my_script')
    %
    % ## References
    % Inspired by a MathWorks Support Team
    % [solution](https://www.mathworks.com/matlabcentral/answers/93851).
    %
    % See also: publish, grabcode
    %

    % path to this directory
    dname = fileparts(mfilename('fullpath'));

    % HTML publish options with custom XSL
    if nargin < 2, opts = struct(); end
    opts.format = 'html';
    opts.stylesheet = fullfile(dname, 'mxdom2mathjax.xsl');

    % publish
    outputFilename = publish(file, opts, varargin{:});

    % copy CSS file to output directory
    outputCSS = fullfile(fileparts(outputFilename), 'publish_custom.css');
    if true || exist(outputCSS, 'file') ~= 2
        copyfile(fullfile(dname, 'publish_custom.css'), outputCSS);
    end
end
