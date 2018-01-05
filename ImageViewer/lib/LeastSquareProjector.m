classdef LeastSquareProjector < handle
    % improvements to be implemented
    % use LU to cache calculation -> use cholesky? 
    % Solve for all coefficients at the same time
    % be able to add bases gradually
    properties
        basis
        B
    end
    
    methods
        function prepare(obj, basis)% (iVector, iDim)
            %tic;
            obj.basis = basis;
            obj.B = basis*basis';   
            %fprintf('Preparation took %d ms\n', toc);
        end
        function coefficients = computeCoefficients(obj, A) %A is row vector
            %tic;
            coefficients = obj.B\(obj.basis*A');
            %fprintf('Computation took %d s\n', toc);
        end
       
    end
    methods(Static)
         function im = vectorFromCoefficients(coefficients, references)
            %im = dot(obj.C,obj.referenceSet.images,1);
            %tic;
            im = coefficients'*references;
            %fprintf('Recomposition took %d s\n', toc);
        end
    end
end

