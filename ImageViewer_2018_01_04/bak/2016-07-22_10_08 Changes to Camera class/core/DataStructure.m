classdef DataStructure < handle
    properties(Constant)
        % parameter indeces
        iHoldTime = 1    % Quench time
        iRunNo = 2       % averaging run number
        iIsDefringed = 3 % boolean
        smoothing = 1
    end
    properties
        % Cell array of all hauke Sets (setIndex)
        haukeSets

        % parameters for each hauke set (setIndex, parameterIndex)
        parameters
        filename
        
        times
        % additional
        lvl % lattice vector length in pixels
        center % (x,y)
        shakingFrequency
        shakingAmplitude
        M % average atom count
        STD % atom std
    end
    
    methods
        function createFFTs(o, N)
            if nargin > 1
                for iSet=1:numel(o.haukeSets)
                    o.haukeSets{iSet}.createFFTs(N);
                end
            else
                for iSet=1:numel(o.haukeSets)
                    o.haukeSets{iSet}.createFFTs();
                end
            end
            
        end
        
        function normalizeFFTs(o)
            for iSet=1:numel(o.haukeSets)
                o.haukeSets{iSet}.normalizeFFTs();
            end
        end
        
        
        function hs = getHaukeSet(o, time, run)
            % xxx: defringed
            [~,indx]=ismember(o.parameters(:,1:2),[time run],'rows');
            if sum(indx) > 1
                [~,indx]=ismember(o.parameters,[time run 1 o.smoothing],'rows');
            end
            indx = find(indx);
            if indx
                hs = o.haukeSets{indx};
            else
                hs = [];
            end
        end
        
        function hs = getHaukeSetsTime(o, time)
            [~,indx]=ismember(o.parameters(:,1),[time],'rows');
            if any(indx)
                hs = {o.haukeSets{indx==1}};
            else
                hs = [];
            end
        end
        
        
        function [hs, times] = getHaukeSetsRun(o, run)
            [~,indx]=ismember(o.parameters(:,[2]),[run],'rows');
            if any(indx)
                hs = {o.haukeSets{indx==1}};
                times = o.parameters(indx==1,1);
            else
                hs = [];
                times = [];
            end
        end
    end
    
end

