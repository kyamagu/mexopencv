classdef UnitTest
    %UnitTest helper class for unit test
    % USAGE:
    %   cd test;
    %   UnitTest;
    properties (Constant)
        TESTDIR = fullfile(mexopencv.root(),'test','unit_tests');
    end

    methods
        function obj = UnitTest()
            %UNITTEST execute all unit tests
            addpath(UnitTest.TESTDIR);
            d = dir(fullfile(UnitTest.TESTDIR,'*.m'));
            for i = 1:numel(d)
                class_name = strrep(d(i).name,'.m','');
                fprintf('== %s ======\n',class_name);
                UnitTest.all(class_name);
            end
        end
    end

    methods (Static)
        function all(class_name)
            %ALL execute all test methods starting with 'test'
            if nargin < 1, class_name = mfilename; end
            if ischar(class_name)
                mc = meta.class.fromName(class_name);
            elseif isobject(class_name)
                mc = metaclass(class_name);
            else
                error('UnitTest:all','invalid arg');
            end

            if isprop(mc,'MethodList')
                mt = {mc.MethodList.Name};
            else
                mt = cellfun(@(x) x.Name,mc.Methods,'UniformOutput',false);
            end
            mt = sort(mt(:))';
            for m = mt(strncmp('test',mt,length('test')))
                fprintf('-- %s ------\n',m{:});
                try
                    feval([class_name,'.',m{:}]);
                    disp('PASS');
                catch e
                    disp(e.getReport);
                    disp('FAIL');
                end
            end
        end
    end

end

