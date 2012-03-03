classdef TestBOWKMeansTrainer
    %TestBOWKMeansTrainer
    properties (Constant)
    end
    
    methods (Static)
        function test_1
            train_desc = randn(100,4);
            trainer = cv.BOWKMeansTrainer(5);
            centers = trainer.cluster(train_desc);
        end
        
        function test_2
            train_desc = randn(100,4);
            trainer = cv.BOWKMeansTrainer(5);
            trainer.add(train_desc);
            centers = trainer.cluster();
            trainer.getDescriptors();
            assert(size(train_desc,1) == trainer.descriptorsCount);
            trainer.clear();
            assert(0 == trainer.descriptorsCount);
        end
    end
    
end

