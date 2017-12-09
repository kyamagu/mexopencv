function varargout = UnitTest(varargin)
    %UNITTEST  Helper function for mexopencv unit testing
    %
    %     [results, passed] = UnitTest()
    %     [...] = UnitTest('OptionName',optionValue, ...)
    %
    % ## Options
    % * __MainModules__ enable main modules tests. default true
    % * __ContribModules__ enable contrib modules tests. default false
    % * __MatchPattern__ regex pattern to filter test classes. Only matched
    %   tests are kept. default empty (no filtering)
    % * __Verbosity__ Verbosity level. default 1:
    %   * __0__ quiet mode.
    %   * __1__ dot-matrix output (one character per test, either ".", "S", or
    %     "F"). Good for minimal output.
    %   * __2__ verbose output, one line per test (test name and status),
    %     along with error message and stack trace if any.
    % * __HotLinks__ Allow HTML hyperlinks in error messages. default 'default'
    % * __FilterStack__ remove test framework from exceptions stack traces.
    %   default false
    % * __DryRun__ dont actually run the tests, just print them. default false
    % * __Progress__ display a graphical progress bar. default false
    % * __LogFile__ name of log file (output logged using DIARY). default is a
    %   timestamped file named `UnitTest_*.log` in current directory. Set to
    %   empty string to disable logging.
    % * __XUnitFile__ export results to an XML file (in xUnit Format), this
    %   can be consumed by several CI systems. default is `tests.xml`. Set to
    %   empty string to disable report.
    %
    % ## Output
    % * __results__ output structure of results with the following fields:
    %   * __Duration__ total time elapsed running all tests.
    %   * __Timestamp__ when test suite was executed (serial date number).
    %   * __Passed__ number of tests passed.
    %   * __Failed__ number of tests failed.
    %   * __Incomplete__ number of tests skipped.
    %   * __Details__ structure array (one struct for each test) with the
    %     following fields:
    %     * __Name__ test name.
    %     * __Duration__ time elapsed running test.
    %     * __Timestamp__ when test case was executed.
    %     * __Passed__ boolean indicating if test passed.
    %     * __Failed__ boolean indicating if test failed.
    %     * __Incomplete__ boolean indicating if test was incomplete (skipped).
    %     * __Exception__ exception thrown if failed/skipped.
    %   * __Logs__ test runner log.
    % * __passed__ boolean indicates tests status (passed or failed).
    %
    % ## Usage
    %
    %     cd test;
    %     results = UnitTest('Verbosity',0);
    %     t = struct2table(results.Details)
    %     sortrows(t(t.Duration>1,:), 'Duration')  % inspect slow tests
    %     t(t.Incomplete|t.Failed,:)               % inspect non-passing tests
    %     disp(results.Log)
    %
    % See also: matlab.unittest
    %

    % parse inputs
    nargoutchk(0,2);
    opts = parse_options(varargin{:});

    % output logging
    if ~isempty(opts.LogFile) && ~opts.DryRun
        diary(opts.LogFile);
        cObj = onCleanup(@() diary('off'));
    end

    % collect tests from all folders
    addpath(opts.TestDirs{:});
    tests = cellfun(@(d) testsuite_fromFolder(d, opts), opts.TestDirs, ...
        'UniformOutput',false);
    tests = cat(1, tests{:});

    % run test suite
    [results, passed] = testsuite_run(tests, opts);

    % xUnit report
    if ~isempty(opts.XUnitFile) && ~opts.DryRun
        export_xunit(results, opts);
    end

    % output
    if nargout > 0, varargout{1} = results; end
    if nargout > 1, varargout{2} = passed; end
end

function opts = parse_options(varargin)
    %PARSE_OPTIONS  Help function to parse input arguments
    %
    %     opts = parse_options(...)
    %
    % ## Output
    % * __opts__ options structure.
    %
    % See also: inputParser
    %

    %TODO: attempt to detect if opencv_contrib is available
    %TODO: add option to specify file handle to print to, which can replace
    % the logging options

    % by default, log output to timestamped file in current directory
    logFile = sprintf('UnitTest_%s.log', datestr(now(),'yyyymmddTHHMMSS'));

    % helper function to validate true/false arguments
    isbool = @(x) isscalar(x) && (islogical(x) || isnumeric(x));

    %HACK: Octave inputParser: 4.0.x has addParamValue, 4.2.0 has addParameter
    p = inputParser();
    if mexopencv.isOctave() && compare_versions(version(), '4.2.0', '<')
        addParam = @(varargin) p.addParamValue(varargin{:}); %#ok<NVREPL>
    else
        addParam = @(varargin) p.addParameter(varargin{:});
    end
    addParam('MainModules', true, isbool);
    addParam('ContribModules', false, isbool);
    addParam('MatchPattern', '', @ischar);
    addParam('Verbosity', 1, @isnumeric);
    addParam('HotLinks', 'default', @ischar);
    addParam('FilterStack', false, isbool);
    addParam('DryRun', false, isbool);
    addParam('Progress', false, isbool);
    addParam('LogFile', logFile, @ischar);
    addParam('XUnitFile', 'tests.xml', @ischar);
    p.parse(varargin{:});
    opts = p.Results;

    opts.MainModules = logical(opts.MainModules);
    opts.ContribModules = logical(opts.ContribModules);
    opts.HotLinks = validatestring(opts.HotLinks, {'on', 'off', 'default'});
    opts.FilterStack = logical(opts.FilterStack);
    opts.DryRun = logical(opts.DryRun);
    opts.Progress = logical(opts.Progress);
    %{
    %TODO
    if ~isempty(opts.MatchPattern)
        opts.MatchPattern = regexptranslate('wildcard', opts.MatchPattern);
    end
    %}

    % root directory for opencv/opencv_contrib tests
    opts.TestDirs = {};
    if opts.MainModules
        opts.TestDirs{end+1} = ...
            fullfile(mexopencv.root(), 'test', 'unit_tests');
    end
    if opts.ContribModules
        opts.TestDirs{end+1} = ...
            fullfile(mexopencv.root(), 'opencv_contrib', 'test', 'unit_tests');
    end
    assert(~isempty(opts.TestDirs), 'No tests included');

    % monitor function
    opts.monitor = @(varargin) testrunner_monitor(opts, varargin{:});
end

function skip = skip_class(fpath)
    %SKIP_CLASS  Determine if test class should be skipped (Octave)
    %
    %     skip = skip_class(fpath)
    %
    % ## Input
    % * __fpath__ full absolute path to M-file to check.
    %
    % ## Output
    % * __skip__ true or false.
    %
    % This is manily use for Octave to avoid certain Octave-specific bugs and
    % incompatibilities.
    %
    % See also: mlint, checkcode
    %

    %HACK: Octave throws syntax error if a local function is defined in the
    % same file as a classdef, http://savannah.gnu.org/bugs/?41723
    skip = false;
    if mexopencv.isOctave()
        % check if file is accepted by Octave parser
        try
            builtin('__parse_file__', fpath);
        catch
            skip = true;
        end
    end
end

function tests = testsuite_fromFolder(dpath, opts)
    %TESTSUITE_FROMFOLDER  Create test suite from all test classes in a folder
    %
    %     tests = testsuite_fromFolder(dpath, opts)
    %
    % ## Input
    % * __dpath__ Folder containing test classes `Test*.m`.
    % * __opts__ Options structure.
    %
    % ## Output
    % * __tests__ Cell array of test names discovered.
    %
    % ## Usage
    %
    %     t = testsuite_fromFolder(fullfile(mexopencv.root(),'test','unit_tests'));
    %
    % Test class files must be named with a "Test" prefix.
    %
    % See also: matlab.unittest.TestSuite.fromFolder
    %

    % list of all test classes
    names = dir(fullfile(dpath, 'Test*.m'));
    names = regexprep({names.name}, '\.m$', '');

    % keep only classes that match the specified pattern
    if ~isempty(opts.MatchPattern)
        idx = ~cellfun(@isempty, regexp(names, opts.MatchPattern, 'once'));
        names = names(idx);
    end

    % remove classes that dont work in Octave
    %TODO: should count towards skipped tests
    idx = cellfun(@(c) skip_class(fullfile(dpath, [c '.m'])), names);
    names = names(~idx);

    % sort classes alphabetically
    names = sort(names(:));

    % get test methods from all classes
    tests = cellfun(@(c) testsuite_fromClass(c, opts), names, ...
        'UniformOutput',false);

    % combine all
    tests = cat(1, tests{:});
    if isempty(tests)
        %HACK: avoid an Octave bug when later concatenated with other tests
        % https://savannah.gnu.org/bugs/index.php?49759
        tests = {};
    end
end

function tests = testsuite_fromPackage(name, opts)
    %TESTSUITE_FROMPACKAGE  Create test suite from package
    %
    %     tests = testsuite_fromPackage(name, opts)
    %
    % ## Input
    % * __name__ Package. This can be specified as:
    %   * name of a package as a string
    %   * metapackage object associated with the package
    % * __opts__ Options structure.
    %
    % ## Output
    % * __tests__ Cell array of test names discovered.
    %
    % See also: matlab.unittest.TestSuite.fromPackage
    %

    % introspection to get package metadata
    if ischar(name)
        mp = meta.package.fromName(name);
    elseif isa(name, 'meta.package')
        mp = name;
    else
        error('UnitTest:error', 'Invalid package argument');
    end
    assert(~isempty(mp), 'UnitTest:error', 'Package not found');

    % sub-packages
    if ~mexopencv.isOctave() && isprop(mp, 'PackageList')
        testsP = arrayfun(@(p) testsuite_fromPackage(p.Name, opts), ...
            mp.PackageList, 'UniformOutput',false);
    else
        testsP = cellfun(@(p) testsuite_fromPackage(p.Name, opts), ...
            mp.Packages, 'UniformOutput',false);
    end

    % classes
    %{
    %TODO
    if ~mexopencv.isOctave() && isprop(mp, 'ClassList')
        mc = findobj(mp.ClassList, '-depth',1, '-regexp', 'Name','^Test');
        cnames = {mc.Name};
    else
        cnames = cellfun(@(c) c.Name, mp.Classes, 'UniformOutput',false);
        cnames = cnames(strncmp('Test', cnames, length('Test')));
    end
    testsC = cellfun(@(c) testsuite_fromClass(c, opts), ...
        cnames, 'UniformOutput',false);
    %}
    if ~mexopencv.isOctave() && isprop(mp, 'ClassList')
        testsC = arrayfun(@(c) testsuite_fromClass(c.Name, opts), ...
            mp.ClassList, 'UniformOutput',false);
    else
        testsC = cellfun(@(c) testsuite_fromClass(c.Name, opts), ...
            mp.Classes, 'UniformOutput',false);
    end

    % combine all
    tests = cat(1, testsP{:}, testsC{:});
    if isempty(tests)
        %HACK: avoid an Octave bug when later concatenated with other tests
        % https://savannah.gnu.org/bugs/index.php?49759
        tests = {};
    end
end

function tests = testsuite_fromClass(klass, opts)
    %TESTSUITE_FROMCLASS  Create test suite from test class
    %
    %     tests = testsuite_fromClass(klass, opts)
    %
    % ## Input
    % * __klass__ Test class. This can be specified as:
    %   * name of class as a string
    %   * path to class file as a string
    %   * metaclass object associated with the test class
    %   * instance of test class itself as object
    % * __opts__ Options structure.
    %
    % ## Output
    % * __tests__ Cell array of test names discovered.
    %
    % ## Usage
    %
    %     t = testsuite_fromClass('TestBlur');
    %     t = testsuite_fromClass(fullfile(mexopencv.root(),'test','unit_tests','TestBlur.m'));
    %     t = testsuite_fromClass(?TestBlur);
    %     t = testsuite_fromClass(TestBlur());
    %
    % The class must be on the path and contains test methods
    % (static functions whose name start with "test").
    %
    % See also: matlab.unittest.TestSuite.fromClass
    %

    % introspection to get class metadata
    if ischar(klass)
        [~,klass] = fileparts(klass);
        mc = meta.class.fromName(klass);
    elseif isa(klass, 'meta.class')
        mc = klass;
    elseif isobject(klass)
        mc = metaclass(klass);
    else
        error('UnitTest:error', 'Invalid class argument');
    end
    assert(~isempty(mc), 'UnitTest:error', 'Test class not found');

    % get list of all names of static test methods
    %HACK: for Octave and backward-compatibility
    if ~mexopencv.isOctave() && isprop(mc, 'MethodList')
        mt = findobj(mc.MethodList, '-regexp', 'Name','^test', ...
            '-and', 'Static',true);
        names = {mt.Name};
    else
        % names of static methods
        idx = cellfun(@(m) m.Static, mc.Methods);
        names = cellfun(@(m) m.Name, mc.Methods(idx), 'UniformOutput',false);

        % only keep methods starting with the 'test' prefix
        idx = strncmp('test', names, length('test'));
        names = names(idx);
    end

    % sort methods alphabetically
    names = sort(names(:));

    % return canonical name of static class methods
    tests = strcat(mc.Name, '.', names);
    if isempty(tests)
        %HACK: avoid an Octave bug when later concatenated with other tests
        % https://savannah.gnu.org/bugs/index.php?49759
        tests = {};
    end
end

function [results, passed] = testsuite_run(tests, opts)
    %TESTSUITE_RUN  Execute all tests in a suite
    %
    %     [results, passed] = testsuite_run(tests, opts)
    %
    % ## Input
    % * __tests__ Cell array of test names to run.
    % * __opts__ Options structure.
    %
    % ## Output
    % * __results__ output structure of results.
    % * __passed__ boolean indicates if passed or failed.
    %
    % See also: matlab.unittest.TestSuite.run, runtests
    %

    % show graphical progress
    if opts.Progress
        if ~mexopencv.isOctave()
            cancel = {'CreateCancelBtn','setappdata(gcbf,''cancel'',true)'};
        else
            %HACK: https://savannah.gnu.org/bugs/?45364
            cancel = {};
        end
        hWait = waitbar(0, 'Running tests...', 'Name',mfilename(), cancel{:});
        setappdata(hWait, 'cancel',false);
        wbCleanObj = onCleanup(@() delete(hWait));
    end

    % run all test methods
    passed = true;
    opts.monitor('tsuite_started', tests);
    ts = now();
    tid = tic();
    for i=1:numel(tests)
        % show graphical progress
        if opts.Progress
            waitbar(i/numel(tests), hWait, strrep(tests{i}, '_', '\_'));
            if getappdata(hWait, 'cancel'), break; end
        end

        % run test
        status = testcase_run(tests{i}, opts);
        passed = passed && (status ~= 0);
    end
    elapsed = toc(tid);
    results = opts.monitor('tsuite_finished', tests, elapsed, ts, passed);
end

function status = testcase_run(t, opts)
    %TESTCASE_RUN  Run test
    %
    %     status = testcase_run(t, opts)
    %
    % ## Input
    % * __t__ test name to run.
    % * __opts__ Options structure.
    %
    % ## Output
    % * __status__ Result of running test. One of:
    %   * __1__ pass
    %   * __0__ fail
    %   * __-1__ skip
    %
    % See also: matlab.unittest.TestCase.run
    %

    status = 1;
    opts.monitor('tcase_started', t);
    ts = now();
    tid = tic();
    try
        if ~opts.DryRun
            if mexopencv.isOctave()
                %HACK: Octave errors on feval of a "Class.Method"
                eval(t);
            else
                feval(t);
            end
        end
        % pass
        status = 1;
        opts.monitor('tcase_passed', t);
    catch ME
        if strcmp(ME.identifier, 'mexopencv:testskip')
            % skip
            status = -1;
            opts.monitor('tcase_skipped', t, ME);
        else
            % fail
            status = 0;
            opts.monitor('tcase_failed', t, ME);
        end
    end
    elapsed = toc(tid);
    opts.monitor('tcase_finished', t, elapsed, ts, status);
end

function varargout = testrunner_monitor(opts, action, t, varargin)
    %TESTRUNNER_MONITOR  Test runner monitor
    %
    %     [...] = testrunner_monitor(opts, action, t, ...)
    %
    % ## Input
    % * __opts__ Options structure.
    % * __action__ Current phase (test suite/case start/finish, pass/fail/skip)
    % * __t__ Current test case, or test suite
    %
    % ## Output
    % * __results__ output structure of results when test suite is finished.
    %
    % The function takes optional arguments depending on monitor phase
    % (elapsed time, timestamp, test status, exception, etc.)
    %
    % See also: matlab.unittest.TestRunner
    %

    persistent n res logs

    % log timestamped message
    if isempty(logs), logs = {}; end
    if opts.Verbosity < 1
        if ischar(t)
            str = t;
        else
            str = sprintf('%d tests', numel(t));
        end
        logs{end+1} = sprintf('[%s] %-20s: %s', datestr(now(),13), action, str);
    end

    switch action
        case 'tsuite_started'
            % initialize persistent data
            n = 0;
            res = struct('Name',t(:), 'Duration',NaN, 'Timestamp',NaN, ...
                'Exception',[], 'Passed',false, 'Failed',false, ...
                'Incomplete',false);
            % print version/config info
            if opts.Verbosity > 1
                print_version();
            end

        case 'tsuite_finished'
            % return final results
            [elapsed, ts, passed] = deal(varargin{:});
            out = struct();
            out.Duration = elapsed;
            out.Timestamp = ts;
            out.Passed = nnz([res.Passed]);
            out.Failed = nnz([res.Failed]);
            out.Incomplete = nnz([res.Incomplete]);
            out.Details = res;
            out.Log = sprintf('%s\n', logs{:});
            varargout{1} = out;
            % clear persistent data
            clear n res logs
            % print summary
            if opts.Verbosity > 0
                print_summary(out);
                if opts.Verbosity == 1
                    print_faults(out, opts);
                end
            end

        case 'tcase_started'
            % increment counter and store test name
            n = n + 1;
            res(n).Name = t;
            % print progress
            if opts.Verbosity > 1
                fprintf('[%4d/%4d] %-60s ', n, numel(res), t);
            end

        case 'tcase_finished'
            % store test duration
            [elapsed, ts, status] = deal(varargin{:});
            res(n).Duration = elapsed;
            res(n).Timestamp = ts;
            % wrap lines
            if opts.Verbosity > 1
                if status == 1
                    %fprintf(' (%.3g ms)\n', elapsed*1000);  %TODO
                    fprintf('\n');
                end
            elseif opts.Verbosity > 0
                %{
                %TODO: adapt to console size
                if mexopencv.isOctave()
                    sz = terminal_size();  % [rows,cols]
                else
                    sz = get(0, 'CommandWindowSize');  % [cols,rows]
                end
                %}
                if mod(n, 80) == 0
                    fprintf('\n');
                end
            end

        case 'tcase_passed'
            % mark test as passed
            res(n).Passed = true;
            % print progress
            if opts.Verbosity > 1
                fprintf('OK');
            elseif opts.Verbosity > 0
                fprintf('.');
            end

        case 'tcase_skipped'
            % mark test as skipped
            ex = varargin{1};
            res(n).Incomplete = true;
            res(n).Exception = ex;
            % print progress
            if opts.Verbosity > 1
                fprintf('SKIP\n');
                fprintf('%s\n', exception_getReport(ex, opts));
            elseif opts.Verbosity > 0
                fprintf('S');
            end

        case 'tcase_failed'
            % mark test as failed
            ex = varargin{1};
            res(n).Failed = true;
            res(n).Exception = ex;
            % print progress
            if opts.Verbosity > 1
                fprintf('FAIL\n');
                fprintf(1, '%s\n', exception_getReport(ex, opts));
            elseif opts.Verbosity > 0
                fprintf('F');
            end
    end
end

function print_version()
    %PRINT_VERSION  Display MATLAB/Octave version
    %
    %     print_summary(results)
    %
    % See also: ver, version
    %

    if mexopencv.isOctave()
        ver('octave');
        %{
        disp(octave_config_info());
        dump_prefs();
        %}
    else
        ver('matlab');
    end
    fprintf('\n');
end

function print_summary(results)
    %PRINT_SUMMARY  Display summary of tests totals
    %
    %     print_summary(results)
    %
    % ## Input
    % * __results__ output structure of results.
    %

    fprintf('\n\nTotals:\n');
    fprintf('  %d Passed, %d Failed, %d Incomplete\n', ...
        results.Passed, results.Failed, results.Incomplete);
    fprintf('  Elapsed time is %f seconds.\n', results.Duration);
end

function print_faults(results, opts)
    %PRINT_FAULTS  Display list of exceptions thrown from tests
    %
    %     print_faults(results, opts)
    %
    % ## Input
    % * __results__ output structure of results.
    % * __opts__ Options structure.
    %

    for i=1:numel(results.Details)
        if results.Details(i).Failed
            ftype = 'Failure';
        elseif results.Details(i).Incomplete
            ftype = 'Incomplete';
        else
            continue;
        end
        fprintf('\n===== %s: %s =====\n', ftype, results.Details(i).Name);
        fprintf(1, '%s\n', exception_getReport(results.Details(i).Exception, opts));
    end
end

function str = xml_escape(str)
    %XML_ESCAPE  Escape XML special characters

    str = strrep(str, '&', '&amp;');
    str = strrep(str, '<', '&lt;');
    str = strrep(str, '>', '&gt;');
    str = strrep(str, '"', '&quot;');
    str = strrep(str, '''', '&apos;');
end

function export_xunit(results, opts)
    %EXPORT_XUNIT  Save test results in xUnit XML Format
    %
    %     export_xunit(results, opts)
    %
    % ## Input
    % * __results__ output structure of results.
    % * __opts__ Options structure.
    %
    % See also: matlab.unittest.plugins.XMLPlugin
    %

    % open XML file
    fid = fopen(opts.XUnitFile, 'wt');
    fprintf(fid, '<?xml version="1.0" encoding="UTF-8"?>\n');

    % test suite root node which contains test case nodes
    fprintf(fid, ['<testsuite name="mexopencv" timestamp="%s" time="%f"' ...
        ' tests="%d" errors="%d" failures="%d" skip="%d">\n'], ...
        datestr(results.Timestamp, 'yyyy-mm-ddTHH:MM:SS'), results.Duration, ...
        numel(results.Details), 0, results.Failed, results.Incomplete);

    % environment properties
    if mexopencv.isOctave()
        name = 'Octave';
    else
        name = 'MATLAB';
    end
    fprintf(fid, '<properties>\n');
    fprintf(fid, '<property name="computer" value="%s"/>\n', computer());
    fprintf(fid, '<property name="software" value="%s %s"/>\n', name, version());
    fprintf(fid, '<property name="opencv" value="%s"/>\n', cv.Utils.version());
    fprintf(fid, '</properties>\n');

    % test cases
    opts.HotLinks = 'off';
    for i=1:numel(results.Details)
        % test case node
        t = results.Details(i);
        name = regexp(t.Name, '\.', 'split');
        fprintf(fid, '<testcase classname="%s" name="%s" time="%f">', ...
            name{1}, name{2}, t.Duration);

        % reason if test did not pass
        if ~t.Passed
            if t.Failed
                tag = 'failure';
            else
                tag = 'skipped';
            end
            ex = t.Exception;
            fprintf(fid, '\n<%s type="%s" message="%s">\n%s\n</%s>\n', ...
                tag, ex.identifier, xml_escape(ex.message), ...
                xml_escape(exception_getReport(ex, opts)), tag);
        end

        fprintf(fid, '</testcase>\n');
    end

    fprintf(fid, '</testsuite>\n');
    fclose(fid);
end

function str = exception_getReport(ME, opts)
    %EXCEPTION_GETREPORT  Get error message for exception
    %
    %     str = exception_getReport(ME, opts)
    %
    % ## Input
    % * __ME__ exception caught. Either a MATLAB MException object or an
    %   Octave error structure.
    % * __opts__ Options structure.
    %
    % ## Output
    % * __str__ a formatted error message, along with stack trace.
    %
    % See also: MException.getReport
    %

    if mexopencv.isOctave()
        str = {};
        str{end+1} = sprintf('error: %s', ME.message);
        if ~isempty(ME.stack)
            str{end+1} = sprintf('error: called from');
            for i=1:numel(ME.stack)
                str{end+1} = sprintf('    %s at line %d column %d', ...
                    ME.stack(i).name, ME.stack(i).line, ME.stack(i).column);
            end
        end
        str = sprintf('%s\n', str{:});
    elseif opts.FilterStack
        %HACK: filter stack trace to not show UnitTest itself
        % unfortunately MException.stack is read-only so we have to
        % traverse it manually
        %TODO: add "matlab:opentoline()" hyperlinks
        thisFile = [mfilename('fullpath') '.m'];
        str = {};
        str{end+1} = ME.message;
        for i=1:numel(ME.stack)
            if strcmp(ME.stack(i).file, thisFile)
                continue;
            end
            if isempty(strfind(ME.stack(i).name, '.'))
                [~,name] = fileparts(ME.stack(i).file);
                if ~strcmp(ME.stack(i).name, name)
                    name = [name filemarker() ME.stack(i).name];
                end
            else
                name = ME.stack(i).name;
            end
            str{end+1} = sprintf('Error in %s (line %d)', ...
                name, ME.stack(i).line);
            %HACK: dbtype is missing in Octave
            cmd = sprintf('dbtype(''%s'',''%d'')', ...
                ME.stack(i).file, ME.stack(i).line);
            str{end+1} = strtrim(evalc(cmd));
        end
        str = sprintf('%s\n', str{:});
    else
        str = getReport(ME, 'extended', 'hyperlinks',opts.HotLinks);
    end
end
