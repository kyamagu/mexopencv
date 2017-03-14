classdef TestFileStorage
    %TestFileStorage

    methods (Static)
        function test_write_read_extensions
            S = struct('field1',magic(4), 'field2','a second field');
            exts = {'.xml', '.yml', '.xml.gz', '.yml.gz', '.json', '.json.gz'};
            for i=1:numel(exts)
                fname = [tempname() exts{i}];
                cleanObj = onCleanup(@() delete(fname));

                cv.FileStorage(fname, S);
                assert(exist(fname, 'file') == 2, ...
                    'Failed to write %s file', exts{i});

                S2 = cv.FileStorage(fname);
                validateattributes(S, {'struct'}, {'scalar'});

                if ~isempty(strfind(exts{i}, 'json'))
                    %TODO: for some reason top-level node names are reported
                    % as empty in JSON format
                    continue;
                end

                assert(all(ismember(fieldnames(S), fieldnames(S2))));
                assert(isequal(S.field1, S2.field1));
                assert(isequal(S.field2, S2.field2));
            end
        end

        function test_write_read_inmemory
            S = struct('field1',magic(4), 'field2','hello world');

            str = cv.FileStorage('dummy.yml', S);
            validateattributes(str, {'char'}, {'row', 'nonempty'});

            [S2,~] = cv.FileStorage(str);
            validateattributes(S2, {'struct'}, {'scalar'});
            assert(isequal(S, S2));
        end

        function test_write_variables
            vars = {pi, 1:5, 'hello world'};
            str = cv.FileStorage('dummy.yml', vars{:});
            str2 = cv.FileStorage('dummy.yml', struct('dummy',{vars}));
            assert(isequal(str, str2));
        end

        function test_numerics
            S = struct('a',int32(-1), 'b',uint8(1), 'c',pi, ...
                'd',eps('single'), 'e',NaN, 'f',Inf, 'g',realmax);
            str = cv.FileStorage('dummy.yml', S);
            [S2,~] = cv.FileStorage(str);
            assert(isequaln(S, S2));  % NOTE: S2.* are all double
        end

        function test_sparse
            S = struct('field1',speye(10));
            str = cv.FileStorage('dummy.yml', S);
            [S2,~] = cv.FileStorage(str);
            assert(isequaln(S, S2) && issparse(S2.field1));
        end

        function test_struct_array
            S = dir(mexopencv.root());  % Nx1 struct array
            SS = struct('dummy',S);     % wrap inside a scalar struct
            str = cv.FileStorage('dummy.xml', SS);
            [S2,~] = cv.FileStorage(str);
            S2 = S2.dummy;  % unwrap
            S2 = [S2{:}];   % cell array of structs to 1xN struct array
            assert(isequaln(S(:), S2(:)));
        end

        function test_struct
            S = struct('field1',struct('a',1, 'b',2), 'field2',struct());
            str = cv.FileStorage('dummy.xml', S);
            [S2,~] = cv.FileStorage(str);
            if false
                %TODO: mismatch in "field2" in Octave
                assert(isequal(S, S2));
            end
        end

        function test_cell
            S = struct('field1',1, 'field2',{{2, 'hi', magic(4)}});
            str = cv.FileStorage('dummy.yml', S);
            [S2,~] = cv.FileStorage(str);
            assert(isequal(S, S2));
        end

        function test_cellstr
            S = struct('field1',1, 'field2',{{'hi','hello there'}});
            str = cv.FileStorage('dummy.yml', S);
            [S2,~] = cv.FileStorage(str);
            assert(isequal(S, S2));
        end

        function test_str_whitespace
            S = struct('str','  hello  ');

            % XML
            str = cv.FileStorage('dummy.xml', S);
            [S2,~] = cv.FileStorage(str);
            assert(isequal(S, S2));

            % YAML
            str = cv.FileStorage('dummy.yml', S);
            [S2,~] = cv.FileStorage(str);
            if false
                %NOTE: yml loader seems to trim leading/trailing spaces
                assert(isequal(S, S2));
            end
        end

        function test_error_argnum
            try
                cv.FileStorage();
                throw('UnitTest:Fail');
            catch e
                assert(strcmp(e.identifier,'mexopencv:error'));
            end
        end
    end

end
