classdef Protocol2 < handle
    %would be best to dircetly read into good format.
    properties
        %descriptors
        timeSlotNames
        analogNames
        digitalNames
        
        %values
        slotActive
        slotDuration
        analogVals
        digitalVals
        visaText
        
        %%% additional infos
        date
        id
        atomImageName
        referenceImageName
        
        % visa
        visaValues
        
        % status
        
    end
    
    methods
        function o = Protocol2(date, id)
            o.date = date;
            o.id = id;
        end
        
        function read(o, filename)
            fileID = fopen(filename,'rt'); %'rt' is important to get newlines right
            protocol = '';
            while feof(fileID) == 0
                protocol = [protocol fgetl(fileID)]; %for format reasons once again
            end;
            %o.protocol = fread(fileID,'*char')';
            fclose(fileID);
            
            % extract information via Regular Expressions
            % Regexp Info
            % \s: space
            % ?: lazy: minimum characters in between
            % todo: think of better pattern, to recognize any number of
            % channels
            regexprStartStr = ['[ ]*(?<Name>[a-z]+?[ _a-z\d]*?)[\s\n]+?',...
                '(?<OnOff>[|X ])\s*?',...
                '(?<Time>\d+)\s+?',...
                '(?<Digitals>[|X]*?)\s+?',...
                '(?<A01>[-\d\.,]+) (?<R01>[ EL])\s*(?<A02>[-\d\.,]+) (?<R02>[ EL])\s*',...
                '(?<A03>[-\d\.,]+) (?<R03>[ EL])\s*(?<A04>[-\d\.,]+) (?<R04>[ EL])\s*',...
                '(?<A05>[-\d\.,]+) (?<R05>[ EL])\s*(?<A06>[-\d\.,]+) (?<R06>[ EL])\s*',...
                '(?<A07>[-\d\.,]+) (?<R07>[ EL])\s*(?<A08>[-\d\.,]+) (?<R08>[ EL])\s*',...
                '(?<A09>[-\d\.,]+) (?<R09>[ EL])\s*(?<A10>[-\d\.,]+) (?<R10>[ EL])\s*',...
                '(?<A11>[-\d\.,]+) (?<R11>[ EL])\s*(?<A12>[-\d\.,]+) (?<R12>[ EL])\s*',...
                '(?<A13>[-\d\.,]+) (?<R13>[ EL])\s*(?<A14>[-\d\.,]+) (?<R14>[ EL])\s*',...
                '(?<A15>[-\d\.,]+) (?<R15>[ EL])\s*(?<A16>[-\d\.,]+) (?<R16>[ EL])\s*',...
                '(?<A17>[-\d\.,]+) (?<R17>[ EL])\s*(?<A18>[-\d\.,]+) (?<R18>[ EL])\s*',...
                '(?<A19>[-\d\.,]+) (?<R19>[ EL])\s*(?<A20>[-\d\.,]+) (?<R20>[ EL])\s*',...
                '(?<A21>[-\d\.,]+) (?<R21>[ EL])\s*(?<A22>[-\d\.,]+) (?<R22>[ EL])\s*'];
            regexprMidStr = [ '(?<A23>[-\d\.,]+) (?<R23>[ EL])\s*(?<A24>[-\d\.,]+) (?<R24>[ EL])\s*'];
            regexprEndStr = [ '.*?',''];
            % search for 24 Analog channels
            slots = regexpi(protocol, [regexprStartStr regexprMidStr regexprEndStr], 'names', 'all');
            if numel(slots) == 0
                % search for 22 Analog channels
                slots = regexpi(protocol, [regexprStartStr regexprEndStr], 'names', 'all');
            end
            o.timeSlotNames = {slots.Name};
            digitals = regexpi(protocol, '\<Digital\>[ ]+\#[ \d\|\^-]+?(?<Name>[a-z]+?[ \(\)a-z\d]*[^;\f\n\r\t\v])', 'names', 'all');
            o.digitalNames = {digitals([end:-1:1]).Name}';
            analogs  = regexpi(protocol, '\<Analog\>[ ]+\#[ \d\|\^-]+?(?<Name>[a-z]+?[ a-z\d]*[^;\f\n\r\t\v])', 'names', 'all');
            o.analogNames  = {analogs([end:-1:1]).Name}';
            VISA     = regexpi(protocol, '\s*;<<[ ]*?(?<Nummer>\d+?)[ ]*?>>\s*?(?<Commands>(([\w\.\+\-\#\* ]+(;*)(?!;<)[^<\f\n\r])*)*)', 'names', 'all');

            % xxx check if names are sound
            % Error checking
            if numel(slots) == 0
                throw(MException('Protocol:read', 'Slots empty of protocol %s', filename));
            else
                if size(o.timeSlotNames) ~= size(slots)
                    throw(MException('Protocol:read', 'Inequal number of timeslotnames and timeslots of protocol %s', filename));
                end
                if numel(slots(1).Digitals) ~= numel(digitals)
                    throw(MException('Protocol:read', 'Unequal number of digitalnames and digital data of protocol %s', filename));
                end
                if ~isfield(slots(1),sprintf('A%02d',numel(analogs)))
                    throw(MException('Protocol:read', 'Unequal number of analog names and analog data of protocol %s', filename));
                end
            end
            o.slotActive = [slots.OnOff]=='X';
            o.slotDuration = str2double({slots.Time});
            for iAnalogChannel = 1:numel(o.analogNames);
                    o.analogVals(:, iAnalogChannel) = str2double({slots.(sprintf('A%02d',iAnalogChannel))});
                    % xxx Ramps
            end
            for iSlot=1:numel(o.timeSlotNames)
                    o.digitalVals(iSlot, :) = slots(iSlot).Digitals == 'X';
            end
            o.visaText = {VISA.Commands};
            
        end
        
        
    end
    
end

