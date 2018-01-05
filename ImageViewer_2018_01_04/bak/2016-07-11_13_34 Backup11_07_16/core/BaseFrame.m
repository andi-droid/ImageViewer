classdef BaseFrame < handle
    properties
        group
        name = 'BaseFrame' %used by base figure
        nXPanes
        nYPanes
    end
    
    methods
        function h = create(o)
              desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
%               if desktop.hasGroup(o.name);
%                   desktop.closeGroup(o.name);
%                   desktop.removeGroup(o.name);
%               end
              o.group = desktop.addGroup(o.name);
              desktop.setGroupDocked(o.name, 0);
              desktop.showGroup(o.name,1);
              pause(0.01);
              while ~desktop.isGroupShowing(o.name), pause(0.01); end;
              %container = o.group.getInternalFrame.getTopLevelAncestor();
              %container.setMaximized(1);
              desktop.setDocumentArrangement(o.name, 2, java.awt.Dimension(o.nXPanes, o.nYPanes));
              %desktop.setGroupMaximized(o.name,1);
              % Create Tiling
%                jpanel = desktop.getGroupContainer(groupname);
%                tilepane = findjobj(jpanel,'Name','DesktopTiledPane');
       
            o.onCreate();      
            h = o.group;
        end
        function addFigure(o, figure)
            set(figure,...
                'WindowStyle', 'docked', ...
                'NumberTitle', 'off');
            set(get(handle(figure), 'javaframe'), ...
                'GroupName', o.name);
        end
    end
    
    methods(Abstract)
       onCreate(o);
    end
end

