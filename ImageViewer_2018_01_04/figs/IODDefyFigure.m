classdef IODDefyFigure < BaseFigure
    properties
        % Data
        integratedOD
        imageindex = 1;

    end
    
    methods
        % constructor
        function o = IODDefyFigure()
            o.windowTitle = mfilename('class');
        end
        
        function processData(o,~,~)

            
            images = o.compositor.croppedDefringedIS;
            o.imageindex = 1;
            o.integratedOD = squeeze(sum(images,3));
            o.onReplot();

        end
        
               function onIndexUp(o,~,~)
           
                    o.imageindex = o.imageindex +1;
           if ~isempty(o.integratedOD)
                    o.onRedraw();
           end
       end
       
       function onIndexDown(o,~,~)
           
                    o.imageindex = o.imageindex -1;
           if ~isempty(o.integratedOD)
                    o.onRedraw();
           end
       end
        
        % implementing BaseFigure
        function onCreate(o)
            
            addlistener(o.compositor, 'updateDataDefringedIntegratedOD',@o.processData);
            addlistener(o.compositor,'indexup', @o.onIndexUp);
            addlistener(o.compositor,'indexdown', @o.onIndexDown);

        end
        
        function onReplot(o)
            if ~isempty(o.integratedOD)
            o.plot = plot(o.axes, o.integratedOD(o.imageindex,:),'-b',...
                'Linewidth',1.5);
            axis(o.axes,'tight');
            grid(o.axes,'on');
            view(o.axes,[90,90]);
            set(o.axes, 'xdir','reverse')
            set(o.axes,'XAxisLocation','top')
            end
        end
        
        function onRedraw(o)
            o.onReplot;
        end
        
        function onNewCurrentCoordinate(o,~)
            o.onRedraw();
        end
    end
    
end

