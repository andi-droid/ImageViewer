classdef UserIndex < handle
    properties(SetObservable)
        value
    end
    
    properties
        maxValue
        minValue
    end
    
    methods
        function o = UserIndex(value, minValue, maxValue)
            o.value = value;
            o.maxValue = maxValue;
            o.minValue = minValue;
        end
        function increase(o)
             o.value = min(o.value +1, o.maxValue);
        end
        function decrease(o)
             o.value = max(o.value -1, o.minValue);
        end
    end
    
end

