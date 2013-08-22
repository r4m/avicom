function plotFigures(handles, numFramesPack)

file = 'DATA/PSNR_Cost.mat';
if(exist(file) && numFramesPack ~=-1)

    load(file);
    sel_index = get(handles.qmList, 'Value'); 
    % plot Q
    axes(handles.psnrPlot);
    cla;
    switch sel_index
        case 1  
            plot(1:numFramesPack,PSNR(2:end), '.-r');
        case 2
            plot(1:numFramesPack,PSNR(1:end), '.-r');
    end
    xlabel('Step');
    ylabel('PSNR [dB]');
    axis tight;
    grid on;

    % plot FC
    axes(handles.fcPlot);
    cla;
    switch sel_index
        case 1  
            plot(1:numFramesPack,Cost(2:end), '.-b');
        case 2
            plot(1:numFramesPack,Cost(1:end), '.-b');
    end  
    xlabel('Step');
    ylabel('FC');
    axis tight;
    grid on;  
else
    % plot Q
    axes(handles.psnrPlot);
    cla;

    xlabel('Step');
    ylabel('PSNR')
    grid on;

    % plot FC
    axes(handles.fcPlot);
    cla;
    xlabel('Step');
    ylabel('FC')
    grid on;  
end 
