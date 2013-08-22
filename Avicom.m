function varargout = Avicom(varargin)
% AVICOM M-file for avicom.fig
%      AVICOM, by itself, creates a new AVICOM or raises the existing
%      singleton*.
%
%      H = AVICOM returns the handle to a new AVICOM or the handle to
%      the existing singleton*.
%
%      AVICOM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AVICOM.M with the given input arguments.
%
%      AVICOM('Property','Value',...) creates a new AVICOM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Avicom_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Avicom_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help avicom

% Last Modified by GUIDE v2.5 12-Feb-2009 16:57:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Avicom_OpeningFcn, ...
                   'gui_OutputFcn',  @Avicom_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

addpath(genpath(pwd));    % Add the sub-directory to Matlab search $PATH
global DEBUG; DEBUG = 0;  % Activate all debug lines

% --------------------------------------------------------------------
% --- Executes just before avicom is made visible.
function Avicom_OpeningFcn(hObject, eventdata, handles, varargin)
global DEBUG;
if (DEBUG), fprintf('Avicom_OpeningFcn\n'); end

% Choose default command line output for avicom
handles.output = hObject;

% Begin my code
clc;
splash('logo.bmp', 4000);

% Setup default figure data
ud = get(handles.avicom, 'Userdata');
ud.hImage      = [];
ud.hTimer      = [];
ud.paused      = 0;
ud.nextFrame   = -1;
ud.currFrame   = -1;
ud.pathNameOriVid = '';
ud.fileNameOriVid = '';
ud.pathNameDecVid = '';
ud.fileNameDecVid = '';
ud.numberOfFrames = -1;        
ud.frameRate = -1;
ud.vidFormat = '';
ud.vidHeight = -1;
ud.vidWidth = -1;
ud.partitions = -1;
ud.numFPFV = -1;
ud.maxFramesForPackets = -1;
ud.numPackets = -1;
ud.Movie = [];
ud.numberOfMovieFrames = -1; 
ud.abort = 0;
set(handles.avicom, 'Userdata', ud);

set(handles.avicom, 'colormap', gray(256));

set(handles.nofLabel,'String',[]);
set(handles.vidHeightWidthLabel,'String',[]);
set(handles.frameRateLabel,'String',[]);

set(handles.convertButton, 'Enable', 'off');
set(handles.abortButton, 'Enable', 'off');
set(handles.qtSlider, 'Enable', 'off');
set(handles.energyMinSlider, 'Enable', 'off');
set(handles.energyMaxSlider, 'Enable', 'off');
set(handles.blkdimMinSlider, 'Enable', 'off');
set(handles.blkdimMaxSlider, 'Enable', 'off');

% stepQT = 0.01;
% setappdata(handles.avicom, 'stepQT', stepQT);
% set(handles.qtSlider, 'Value', 0.7);
% set(handles.qtText, 'String', get(handles.qtSlider,'Value'));
% set(handles.qtSlider, 'Min', 0.0);
% set(handles.qtSlider, 'Max', 1.0);
% sliderStep = stepQT/(get(handles.qtSlider, 'Max')-get(handles.qtSlider, 'Min'));
% set(handles.energyMaxSlider, 'SliderStep', [sliderStep, sliderStep]);

stepQT = 1;
setappdata(handles.avicom, 'stepQT', stepQT);
set(handles.qtSlider, 'Value', 32);
set(handles.qtText, 'String', get(handles.qtSlider,'Value'));
set(handles.qtSlider, 'Min', -100);
set(handles.qtSlider, 'Max', 100);
sliderStep = stepQT/(get(handles.qtSlider, 'Max')-get(handles.qtSlider, 'Min'));
set(handles.energyMaxSlider, 'SliderStep', [sliderStep, sliderStep]);

stepEnergy = 0.1;
setappdata(handles.avicom, 'stepEnergy', stepEnergy);
set(handles.energyMinSlider, 'Value', 0.4);
set(handles.energyMaxSlider, 'Value', 0.9);
set(handles.energyMinText, 'String', get(handles.energyMinSlider,'Value'));
set(handles.energyMaxText, 'String', get(handles.energyMaxSlider,'Value'));
set(handles.energyMinSlider, 'Min', 0.0);
set(handles.energyMinSlider, 'Max', get(handles.energyMaxSlider,'Value')-stepEnergy);
set(handles.energyMaxSlider, 'Min', get(handles.energyMinSlider,'Value')+stepEnergy);
set(handles.energyMaxSlider, 'Max', 1.0);
sliderStep = stepEnergy/(get(handles.energyMinSlider, 'Max') - get(handles.energyMinSlider, 'Min'));
set(handles.energyMinSlider, 'SliderStep', [sliderStep, sliderStep]);
sliderStep = stepEnergy/(get(handles.energyMaxSlider, 'Max') - get(handles.energyMaxSlider, 'Min'));
set(handles.energyMaxSlider, 'SliderStep', [sliderStep, sliderStep]);

stepBlkdim = 4;
setappdata(handles.avicom, 'stepBlkdim', stepBlkdim);
set(handles.blkdimMinSlider, 'Value', 8);
set(handles.blkdimMaxSlider, 'Value', 64);
set(handles.blkdimMinText, 'String', get(handles.blkdimMinSlider,'Value'));
set(handles.blkdimMaxText, 'String', get(handles.blkdimMaxSlider,'Value'));
set(handles.blkdimMinSlider, 'Min', 0);
set(handles.blkdimMinSlider, 'Max', get(handles.blkdimMaxSlider,'Value')-stepBlkdim);
set(handles.blkdimMaxSlider, 'Min', get(handles.blkdimMinSlider,'Value')+stepBlkdim);
set(handles.blkdimMaxSlider, 'Max', 100);
sliderStep = stepBlkdim/(get(handles.blkdimMinSlider, 'Max') - get(handles.blkdimMinSlider, 'Min'));
set(handles.blkdimMinSlider, 'SliderStep', [sliderStep, sliderStep]);
sliderStep = stepBlkdim/(get(handles.blkdimMaxSlider, 'Max') - get(handles.blkdimMaxSlider, 'Min'));
set(handles.blkdimMaxSlider, 'SliderStep', [sliderStep, sliderStep]);

set(handles.SaveItem, 'Enable', 'off');

% Update handles structure
guidata(hObject, handles);

% Create Toolbar
icons = load('player_icons');  
set(handles.goToStartButton,'CData',icons.goto_start_default,'Enable','off');
set(handles.stepBackButton,'CData',icons.step_back,'Enable','off');
set(handles.playButton,'CData',icons.play_on,'Enable','off');
set(handles.stopButton,'CData',icons.stop_default,'Enable','off');
set(handles.stepForwardButton,'CData', icons.step_fwd,'Enable','off');
set(handles.goToEndButton,'CData',icons.goto_end_default,'Enable','off');

% Center Avicom to the screen
set(handles.avicom,'Position',getInitialPosition(handles.avicom));

% This sets up the initial plot
if strcmp(get(hObject,'Visible'),'off')
    plotFigures(handles,-1);

end


% --------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = Avicom_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DEBUG;
if (DEBUG), fprintf('Avicom_OutputFcn\n'); end

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
% --- Executes on button press in convertButton.
function convertButton_Callback(hObject, eventdata, handles)
% hObject    handle to convertButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DEBUG;

if (DEBUG), fprintf('convertButton_Callback\n'); end

% file = 'DATA/originalVideoPartitions.mat';
% if(exist(file))
%     load(file, '-regexp', 'partitions');
% else
%     error(['File ' file ' not found']);
% end 
ud = get(handles.avicom, 'Userdata');
    partitions = ud.partitions;
    ud.abort = 0;
set(handles.avicom, 'Userdata', ud);

sel_index = get(handles.qmList, 'Value');
if(sel_index == 1 && partitions<=5)
    warndlg('Too few partitions. Use fitting method.','Warning');
    uiwait;
    return;
end   

set(handles.convertButton, 'Enable', 'off');
set(handles.abortButton, 'Enable', 'on');
set(handles.qtSlider, 'Enable', 'off');
set(handles.energyMinSlider, 'Enable', 'off');
set(handles.energyMaxSlider, 'Enable', 'off');
set(handles.blkdimMinSlider, 'Enable', 'off');
set(handles.blkdimMaxSlider, 'Enable', 'off');

set(handles.goToStartButton,'Enable','off');
set(handles.stepBackButton,'Enable','off');
set(handles.playButton,'Enable','off');
set(handles.stopButton,'Enable','off');
set(handles.stepForwardButton,'Enable','off');
set(handles.goToEndButton,'Enable','off'); 

%%%% Chiamo la routine per il calcolo dei frame compressi
switch sel_index
    case 1
        % number of subFramesGray (packages) for training (1/4 of total data)
        numFPFT = ceil(partitions/3); % numFramesPackForTraining
        % number of subFramesGray (packages) for validation (3/4 of total data)
        numFPFV = partitions - numFPFT; % numFramesPackForValidation

        % Simulo la compressione SVD e creo le tabelle corrispondenti
        svdSimCompression(numFPFT, handles, 'trainingTable');
        %Stima dell'ordine delle superfici
        ud = get(handles.avicom, 'Userdata');
        if(~ud.abort)
            [orderPSNR orderFC] = orderSurfEstimation(numFPFT, handles, 'trainingTable');        
        end
        % Fitting table
        ud = get(handles.avicom, 'Userdata');
        if(~ud.abort)
            kalmanFiltering(numFPFT, numFPFV, orderPSNR, orderFC, handles, 'trainingTable');
        end

        ud = get(handles.avicom, 'Userdata');          
        if(~ud.abort)
            ud.numFPFV = numFPFV;
            set(handles.avicom, 'Userdata', ud);
            % Disegno i grafici
            plotFigures(handles, ud.numFPFV);         

            [mergedFrames nMF] = catMovie(handles, ud.numFPFV);
            ud = get(handles.avicom, 'Userdata');
            ud.Movie = mergedFrames;
            ud.numberOfMovieFrames = nMF;
            set(handles.avicom, 'Userdata', ud);
        end  
    case 2
        % Simulo la compressione SVD e creo le tabelle corrispondenti
        svdSimCompression(partitions, handles, 'partitionsTable');
        % Stima dell'ordine delle superfici
        ud = get(handles.avicom, 'Userdata');
        if(~ud.abort)
            [orderPSNR orderFC] = orderSurfEstimation(partitions, handles, 'partitionsTable');        
        end
        % Fitting table
        ud = get(handles.avicom, 'Userdata');
        if(~ud.abort)
            tablesFitting(partitions, orderPSNR, orderFC, handles, 'partitionsTable');
        end
        
        ud = get(handles.avicom, 'Userdata');
        if(~ud.abort)
            ud.numFPFV = partitions;
            set(handles.avicom, 'Userdata', ud);           
            % Disegno i grafici
            plotFigures(handles, ud.numFPFV);

            [mergedFrames nMF] = catMovie(handles, ud.numFPFV);
            ud = get(handles.avicom, 'Userdata');
            ud.Movie = mergedFrames;
            ud.numberOfMovieFrames = nMF;
            set(handles.avicom, 'Userdata', ud);
        end
end

set(handles.qtSlider, 'Enable', 'on');
set(handles.energyMinSlider, 'Enable', 'on');
set(handles.energyMaxSlider, 'Enable', 'on');
set(handles.blkdimMinSlider, 'Enable', 'on');
set(handles.blkdimMaxSlider, 'Enable', 'on');

ud = get(handles.avicom, 'Userdata');
if(~ud.abort)
    set(handles.abortButton, 'Enable', 'off');
    set(handles.SaveItem, 'Enable', 'on');
    set(handles.originalVidLabel,'Visible','off');
    set(handles.compressedVidLabel,'Visible','off');
    UpdateButtonsEnable(handles);
end
set(handles.avicom, 'Userdata', ud);
set(handles.convertButton, 'Enable', 'on');
guidata(hObject, handles);

% --------------------------------------------------------------------
% --- Executes on button press in abortButton.
function abortButton_Callback(hObject, eventdata, handles)
% hObject    handle to abortButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DEBUG;
if (DEBUG), fprintf('abortButton_Callback\n'); end

ud = get(handles.avicom, 'Userdata');
ud.abort = 1;
set(handles.avicom, 'Userdata', ud)
set(handles.convertButton, 'Enable', 'on');
set(handles.abortButton, 'Enable', 'off');

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DEBUG;
if (DEBUG), fprintf('FileMenu_Callback\n'); end


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DEBUG;
if (DEBUG), fprintf('OpenMenuItem_Callback\n'); end

[filename, pathname] = uigetfile({'*.avi',  'AVI-files (*.avi)'}, ...
    'Pick a file');
%[filename, pathname] = uigetfile({'*.avi',  'AVI-files (*.avi)'; ...
%   '*.*',  'All Files (*.*)'}, ...
%   'Pick a file');
% hObject = findobj('Tag','avicom');

if ~isequal(filename, 0)
     pathFile = [pathname filename];

    if(~exist('DATA','dir'))
        if(~mkdir('DATA'));
            error('Unable to create directory DATA');
        end
    else
        delete('DATA/*.mat');
    end
       
    set(handles.goToStartButton,'Enable','off');
    set(handles.stepBackButton,'Enable','off');
    set(handles.playButton,'Enable','off');
    set(handles.stopButton,'Enable','off');
    set(handles.stepForwardButton,'Enable','off');
    set(handles.goToEndButton,'Enable','off');

    set(handles.SaveItem, 'Enable', 'off');
    
    h = waitbar(1,'Construct multimedia reader object...');
    % Construct a multimedia reader object
    mmrobj = mmreader(pathFile,'tag', 'originalAVI');
   
    % Read in all the video frames.
    % h = waitbar(1,'Read in all the video frames...');
    % frames = read(mmrobj, [1 Inf]);
    close(h);

    frameRate = get(mmrobj, 'FrameRate');
    numberOfFrames = get(mmrobj, 'NumberOfFrames');
    vidFormat = get(mmrobj, 'VideoFormat');
    vidHeight = get(mmrobj, 'Height');
    vidWidth = get(mmrobj, 'Width');
    save DATA/originalVideoProperties.mat pathname filename frameRate numberOfFrames vidFormat vidHeight vidWidth;
    ud = get(handles.avicom, 'Userdata');
        ud.pathNameOriVid = pathname;
        ud.fileNameOriVid = filename;
        ud.numberOfFrames = numberOfFrames;        
        ud.frameRate = frameRate;
        ud.vidFormat = vidFormat;
        ud.vidHeight = vidHeight;
        ud.vidWidth = vidWidth;
        
        ud.nextFrame   = 1;
        ud.currFrame   = 1;
    set(handles.avicom, 'Userdata', ud);  
    
    set(handles.nofLabel,'String',[int2str(numberOfFrames) ' (f)']);
    set(handles.vidHeightWidthLabel,'String',[int2str(vidHeight) 'x' int2str(vidWidth) ' (pxl)']);
    set(handles.frameRateLabel,'String',[int2str(frameRate) ' (fps)']);
 
    videoAxesPosition = get(handles.videoAxes, 'Position');

    set(handles.videoAxes, ...
    'xlim',[0 videoAxesPosition(3)], ...
    'ylim',[0 videoAxesPosition(4)]);
    
    resVidWidth = (videoAxesPosition(3)-1)/2;
    resVidHeight = videoAxesPosition(4)-1;
       
    ud = get(handles.avicom, 'Userdata');
    ud.hImage = image(...
    'Parent', handles.videoAxes, ...
    'cdata', 255*ones(resVidHeight, (resVidWidth*2)), ...
    'xdata', 1:(resVidWidth*2),...
    'ydata', 1:resVidHeight,...
    'erase','none');
    set(handles.avicom, 'Userdata', ud); 
    
    set(handles.originalVidLabel,'Visible','on');
    set(handles.compressedVidLabel,'Visible','on');

    [partitions maxFramesForPackets numPackets] = vidFlowPartitionCutted(mmrobj, resVidHeight, resVidWidth);

    ud = get(handles.avicom, 'Userdata');
        ud.partitions = partitions;
        ud.maxFramesForPackets = maxFramesForPackets;
        ud.numPackets = numPackets;
    set(handles.avicom, 'Userdata', ud);  

    set(handles.blkdimMaxSlider, 'Max', min(resVidHeight,resVidWidth));
    if(get(handles.blkdimMaxSlider, 'Value') > min(resVidHeight,resVidWidth))
        set(handles.blkdimMaxSlider, 'Value', (get(handles.blkdimMaxSlider, 'Max')- getappdata(handles.avicom, 'stepBlkdim')));
        set(handles.blkdimMinSlider, 'Max', (get(handles.blkdimMaxSlider, 'Value')- getappdata(handles.avicom, 'stepBlkdim')));        
    end 
    if(get(handles.blkdimMinSlider, 'Value') > get(handles.blkdimMinSlider, 'Max'))
        set(handles.blkdimMinSlider, 'Value', (get(handles.blkdimMinSlider, 'Max')- getappdata(handles.avicom, 'stepBlkdim')));
    end
    
    set(handles.qmList, 'Enable', 'on');  
    set(handles.convertButton, 'Enable', 'on');
    set(handles.abortButton, 'Enable', 'off');
    set(handles.qtSlider, 'Enable', 'on');
    set(handles.energyMinSlider, 'Enable', 'on');
    set(handles.energyMaxSlider, 'Enable', 'on');
    set(handles.blkdimMinSlider, 'Enable', 'on');
    set(handles.blkdimMaxSlider, 'Enable', 'on'); 
    
    % Setup timer
    ud = get(handles.avicom, 'Userdata');
    ud.hTimer = timer('ExecutionMode','fixedRate', 'TimerFcn', {@TimerTickFcn, handles}, 'StopFcn', {@TimerStopFcn, handles}, 'BusyMode', 'drop', 'TasksToExecute', Inf);
    set(handles.avicom, 'Userdata', ud);  

    % Set frames per second for playback
    isRunning = strcmp(get(ud.hTimer,'Running'),'on');
    % isPaused = ud.paused;
    if isRunning
        playButton_Callback(hObject, [], handles);  % pause
    end
    set(ud.hTimer, 'Period', 1./ud.frameRate);
    if isRunning 
        playButton_Callback(hObject, [], handles);
    %     ud = get(hfig,'Userdata');
    %     ud.paused = isPaused;
    %     set(hfig,'Userdata',ud);
    end
end


% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DEBUG;
if (DEBUG), fprintf('CloseMenuItem_Callback\n'); end

selection = questdlg(['Close ' get(handles.avicom,'Name') '?'],...
                     ['Close ' get(handles.avicom,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

ud = get(handles.avicom, 'Userdata');
isRunning = strcmp(get(ud.hTimer,'Running'),'on');
if isRunning
    stop(ud.hTimer); % Shut off timer if running
end
delete(handles.avicom);

if(exist('DATA/originalVideoProperties.mat','file')), delete('DATA/originalVideoProperties.mat'); end
if(exist('DATA/originalVideoPartitions.mat','file')), delete('DATA/originalVideoPartitions.mat'); end
if(exist('DATA/PSNR_Cost.mat','file')), delete('DATA/PSNR_Cost.mat'); end

if(exist('DATA/originalFrames','dir')), rmdir('DATA/originalFrames','s'); end
if(exist('DATA/decodedFrames','dir')), rmdir('DATA/decodedFrames','s'); end
if(exist('DATA/tables','dir')), rmdir('DATA/tables','s'); end



% --------------------------------------------------------------------
function HelpMenu_Callback(hObject, eventdata, handles)
% hObject    handle to HelpMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DEBUG;
if (DEBUG), fprintf('HelpMenu_Callback\n'); end


% --------------------------------------------------------------------
function ProductHelpItem_Callback(hObject, eventdata, handles)
% hObject    handle to ProductHelpItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Create a MATLAB movie struct Gray from the video frames.
global DEBUG;
if (DEBUG), fprintf('ProductHelpItem_Callback\n'); end

open('manual.pdf');


% --------------------------------------------------------------------
function AboutItem_Callback(hObject, eventdata, handles)
% hObject    handle to AboutItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DEBUG;
if (DEBUG), fprintf('AboutItem_Callback\n'); end

about;


% --------------------------------------------------------------------
function SaveItem_Callback(hObject, eventdata, handles)
% hObject    handle to SaveItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DEBUG;
if (DEBUG), fprintf('SaveItem_Callback\n'); end

ud = get(handles.avicom, 'Userdata');
pathname = ud.pathNameOriVid;
filename = ud.fileNameOriVid;
frameRate = ud.frameRate;
ud.numFPFV
% file = 'DATA/originalVideoProperties.mat';
% if(exist(file,'file'))
%     load(file, '-regexp', 'pathname', 'filename', 'frameRate');  
    [filename,pathname] = uiputfile({'*.avi',  'AVI-files (*.avi)'},'Save AVI',...
          [pathname 'decoded' filename]);
    ud.pathNameDecVid = pathname;
    ud.fileNameDecVid = ['decoded' filename];
    set(handles.avicom, 'Userdata', ud);
% else
%     error(['Unable to load file ' filename]);  
% end
   
if isequal(filename,0) || isequal(pathname,0)
    %disp('User selected Cancel');
else
    %disp(['User selected',fullfile(pathname, filename)]);
    decodedFramesGray = [];
%     file = 'DATA/originalVideoPartitions.mat';
%     if(exist(file))
%         load(file, '-regexp', 'partitions');
%     else
%         error(['File ' file ' not found']);
%     end 
    partitions = ud.partitions;
    h = waitbar(0,'Cat all the video frames...');
    for i = partitions-ud.numFPFV : partitions-1
        waitbar((i-partitions+ud.numFPFV)/(ud.numFPFV-1));

        file = ['DATA/decodedFrames/decodedFramesGrayPack' int2str(i) '.mat'];
        if(exist(file, 'file'))
            load(file);
        else
            error(['File ' file ' not found']);
        end
        %for k = 1: size(decodedFramesGray)
        %    eval(['decodedFramesGray = cat(3, decodedFramesGray, decodedSubFramesGray(' int2str(k) '));']);
        %end
        decodedFramesGray = cat(3, decodedFramesGray, decodedSubFramesGray);
    end
    close(h);  

    % Create AVI - Type 1 
    mov = avifile([pathname filename],'compression','none','fps',frameRate,'quality',0);
    % Create a MATLAB movie struct Gray from the video frames.
%     h = waitbar(0,'Create movie struct gray(256)...');
    decodedFramesGray4D = zeros(size(decodedFramesGray,1),size(decodedFramesGray,2),1,size(decodedFramesGray,3));
    for i = 1 : size(decodedFramesGray,3)
%         waitbar(i/size(decodedFramesGray,3));    
        decodedFramesGray4D(:,:,1,i) = decodedFramesGray(:,:,i);
        F.cdata = decodedFramesGray4D(:,:,1,i);
        F.colormap = gray(256);
        mov = addframe(mov,F);
    end
%     close(h);
    mov = close(mov); %#ok<NASGU>

    % Create AVI - Type 2 
    % Create a MATLAB movie struct Gray from the video frames.
%     h = waitbar(0,'Create movie struct gray(256)...');
%     decodedFramesGray4D = zeros(size(decodedFramesGray,1),size(decodedFramesGray,2),1,size(decodedFramesGray,3));
%     for i = 1 : size(decodedFramesGray,3)
%         waitbar(i/size(decodedFramesGray,3));    
%         decodedFramesGray4D(:,:,1,i) = decodedFramesGray(:,:,i);
%         mov(i) = immovie(decodedFramesGray4D(:,:,1,i),gray(256));
%     end
%     close(h);
% 
%     movie2avi(mov,'dec','fps',frameRate,'Compression','None');   
end


% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function qmList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qmList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global DEBUG;
if (DEBUG), fprintf('qmList_CreateFcn\n'); end

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'Kalman Estimation','Tables Fitting'});


% --------------------------------------------------------------------
% --- Executes on selection change in qmList.
function qmList_Callback(hObject, eventdata, handles)
% hObject    handle to qmList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DEBUG;
if (DEBUG), fprintf('qmList_Callback\n'); end

% Hints: contents = get(hObject,'String') returns qmList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from qmList

sel_index = get(hObject, 'Value');
switch sel_index
    case 1   
%         stepQT = 0.01;
%         setappdata(handles.avicom, 'stepQT', stepQT);
%         set(handles.qtSlider, 'Value', 0.7);
%         set(handles.qtText, 'String', get(handles.qtSlider,'Value'));
%         set(handles.qtSlider, 'Min', 0.0);
%         set(handles.qtSlider, 'Max', 1.0);
%         sliderStep = stepQT/(get(handles.qtSlider, 'Max')-get(handles.qtSlider, 'Min'));
%         set(handles.energyMaxSlider, 'SliderStep', [sliderStep, sliderStep]);
    case 2      
%         stepQT = 1;
%         setappdata(handles.avicom, 'stepQT', stepQT);
%         set(handles.qtSlider, 'Value', 32);
%         set(handles.qtText, 'String', get(handles.qtSlider,'Value'));
%         set(handles.qtSlider, 'Min', -100);
%         set(handles.qtSlider, 'Max', 100);
%         sliderStep = stepQT/(get(handles.qtSlider, 'Max')-get(handles.qtSlider, 'Min'));
%         set(handles.energyMaxSlider, 'SliderStep', [sliderStep, sliderStep]);
        warndlg('This operation could take several minutes or hours!','Warning');        
end


% --------------------------------------------------------------------
% --- Executes on slider movement.
function qtSlider_Callback(hObject, eventdata, handles)
% hObject    handle to qtSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DEBUG;
if (DEBUG), fprintf('qtSlider_Callback\n'); end

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

sliderValue = get(hObject,'Value');
sliderValueRound = round(sliderValue*100)/100;
set(handles.qtSlider, 'String', sliderValueRound);
set(handles.qtText, 'String', sliderValueRound);
guidata(hObject,handles); 


% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function qtSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qtSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global DEBUG;
if (DEBUG), fprintf('qtSlider_CreateFcn\n'); end

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --------------------------------------------------------------------
function qtText_Callback(hObject, eventdata, handles)
% hObject    handle to qtText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DEBUG;
if (DEBUG), fprintf('qtText_Callback\n'); end

% Hints: get(hObject,'String') returns contents of qtText as text
%        str2double(get(hObject,'String')) returns contents of qtText as a double


% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function qtText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qtText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global DEBUG;
if (DEBUG), fprintf('qtText_CreateFcn\n'); end

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
% --- Executes on slider movement.
function energyMinSlider_Callback(hObject, eventdata, handles)
% hObject    handle to energyMinSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DEBUG;
if (DEBUG), fprintf('energyMinSlider_Callback\n'); end

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

sliderValue = get(hObject,'Value');
sliderValueRound = round(sliderValue*10)/10;
set(handles.energyMinSlider, 'String', sliderValueRound);
set(handles.energyMinText, 'String', sliderValueRound);
set(handles.energyMinSlider, 'Value', sliderValueRound);

stepEnergy = getappdata(handles.avicom, 'stepEnergy');
set(handles.energyMaxSlider, 'Min', sliderValueRound+stepEnergy);
sliderBoundDiff = get(handles.energyMaxSlider, 'Max') - get(handles.energyMaxSlider, 'Min');
if(sliderBoundDiff < eps(1))
    set(handles.energyMaxSlider, 'SliderStep', [0, 0]);  
else if (abs(sliderBoundDiff - stepEnergy) < eps(1))
    set(handles.energyMaxSlider, 'SliderStep', [1, 1]);  
    else
    sliderStep = stepEnergy/sliderBoundDiff;
    set(handles.energyMaxSlider, 'SliderStep', [sliderStep, sliderStep]);
    end
end

if(get(handles.energyMaxSlider,'Value') < get(handles.energyMaxSlider,'Min'))
    set(handles.energyMaxSlider, 'Value', get(handles.energyMaxSlider,'Min'));
    set(handles.energyMaxSlider, 'String', get(handles.energyMaxSlider,'Min'));
end

guidata(hObject,handles); 


% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function energyMinSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to energyMinSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global DEBUG;
if (DEBUG), fprintf('energyMinSlider_CreateFcn\n'); end

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --------------------------------------------------------------------
function energyMinText_Callback(hObject, eventdata, handles)
% hObject    handle to energyMinText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DEBUG;
if (DEBUG), fprintf('energyMinText_Callback\n'); end

% Hints: get(hObject,'String') returns contents of energyMinText as text
%        str2double(get(hObject,'String')) returns contents of energyMinText as a double


% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function energyMinText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to energyMinText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global DEBUG;
if (DEBUG), fprintf('energyMinText_CreateFcn\n'); end

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
% --- Executes on slider movement.
function energyMaxSlider_Callback(hObject, eventdata, handles)
% hObject    handle to energyMaxSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DEBUG;
if (DEBUG), fprintf('energyMaxSlider_Callback\n'); end

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

sliderValue = get(hObject,'Value');
sliderValueRound = round(sliderValue*10)/10;
set(handles.energyMaxSlider, 'String', sliderValueRound);
set(handles.energyMaxText, 'String', sliderValueRound);
set(handles.energyMaxSlider, 'Value', sliderValueRound);

stepEnergy = getappdata(handles.avicom, 'stepEnergy');
set(handles.energyMinSlider, 'Max', sliderValueRound-stepEnergy);
sliderBoundDiff = get(handles.energyMinSlider, 'Max') - get(handles.energyMinSlider, 'Min');
if(sliderBoundDiff < eps(1))
    set(handles.energyMinSlider, 'SliderStep', [0, 0]);  
else if (abs(sliderBoundDiff - stepEnergy) < eps(1))
    set(handles.energyMinSlider, 'SliderStep', [1, 1]);  
    end
    sliderStep = stepEnergy/sliderBoundDiff;
    set(handles.energyMinSlider, 'SliderStep', [sliderStep, sliderStep]);
end

if(get(handles.energyMinSlider,'Value') > get(handles.energyMinSlider,'Max'))
    set(handles.energyMinSlider, 'Value', get(handles.energyMinSlider,'Max'));
    set(handles.energyMinSlider, 'String', get(handles.energyMinSlider,'Max'));
end

guidata(hObject,handles); 


% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function energyMaxSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to energyMaxSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global DEBUG;
if (DEBUG), fprintf('energyMaxSlider_CreateFcn\n'); end

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --------------------------------------------------------------------
function energyMaxText_Callback(hObject, eventdata, handles)
% hObject    handle to energyMaxText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DEBUG;
if (DEBUG), fprintf('energyMaxText_Callback\n'); end

% Hints: get(hObject,'String') returns contents of energyMaxText as text
%        str2double(get(hObject,'String')) returns contents of energyMaxText as a double


% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function energyMaxText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to energyMaxText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global DEBUG;
if (DEBUG), fprintf('energyMaxText_CreateFcn\n'); end

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
% --- Executes on slider movement.
function blkdimMinSlider_Callback(hObject, eventdata, handles)
% hObject    handle to blkdimMinSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DEBUG;
if (DEBUG), fprintf('blkdimMinSlider_Callback\n'); end

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

sliderValue = get(hObject,'Value');
sliderValueRound = round(sliderValue);

stepBlkdim = getappdata(handles.avicom, 'stepBlkdim');

if(mod(sliderValueRound,stepBlkdim))
    sliderValueRound = sliderValueRound - mod(sliderValueRound,stepBlkdim);
end
set(handles.blkdimMinSlider, 'String', sliderValueRound);
set(handles.blkdimMinText, 'String', sliderValueRound);
set(handles.blkdimMinSlider, 'Value', sliderValueRound);
    
set(handles.blkdimMaxSlider, 'Min', sliderValueRound+stepBlkdim);
sliderBoundDiff = get(handles.blkdimMaxSlider, 'Max') - get(handles.blkdimMaxSlider, 'Min');
if(sliderBoundDiff == 0)
    set(handles.blkdimMaxSlider, 'SliderStep', [0, 0]);  
else
    sliderStep = stepBlkdim/sliderBoundDiff;
    set(handles.blkdimMaxSlider, 'SliderStep', [sliderStep, sliderStep]);
end

if(get(handles.blkdimMaxSlider,'Value') < get(handles.blkdimMaxSlider,'Min'))
    set(handles.blkdimMaxSlider, 'Value', get(handles.blkdimMaxSlider,'Min'));
    set(handles.blkdimMaxText, 'String', get(handles.blkdimMaxSlider,'Min'));
end

guidata(hObject,handles);


% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function blkdimMinSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to blkdimMinSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global DEBUG;
if (DEBUG), fprintf('blkdimMinSlider_CreateFcn\n'); end

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --------------------------------------------------------------------
function blkdimMinText_Callback(hObject, eventdata, handles)
% hObject    handle to blkdimMinText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DEBUG;
if (DEBUG), fprintf('blkdimMinText_Callback\n'); end

% Hints: get(hObject,'String') returns contents of blkdimMinText as text
%        str2double(get(hObject,'String')) returns contents of blkdimMinText as a double


% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function blkdimMinText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to blkdimMinText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global DEBUG;
if (DEBUG), fprintf('blkdimMinText_CreateFcn\n'); end

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
% --- Executes on slider movement.
function blkdimMaxSlider_Callback(hObject, eventdata, handles)
% hObject    handle to blkdimMaxSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DEBUG;
if (DEBUG), fprintf('blkdimMaxSlider_Callback\n'); end

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

sliderValue = get(hObject,'Value');
sliderValueRound = round(sliderValue);

stepBlkdim = getappdata(handles.avicom, 'stepBlkdim');

if(mod(sliderValueRound,stepBlkdim))
    sliderValueRound = sliderValueRound - mod(sliderValueRound,stepBlkdim);
end
set(handles.blkdimMaxSlider, 'String', sliderValueRound);
set(handles.blkdimMaxText, 'String', sliderValueRound);
set(handles.blkdimMaxSlider, 'Value', sliderValueRound);

set(handles.blkdimMinSlider, 'Max', sliderValueRound-stepBlkdim);
sliderBoundDiff = get(handles.blkdimMinSlider, 'Max') - get(handles.blkdimMinSlider, 'Min');
if(sliderBoundDiff == 0)
    set(handles.blkdimMinSlider, 'SliderStep', [0, 0]);  
else
    sliderStep = stepBlkdim/sliderBoundDiff;
    set(handles.blkdimMinSlider, 'SliderStep', [sliderStep, sliderStep]);
end

if(get(handles.blkdimMinSlider,'Value') > get(handles.blkdimMinSlider,'Max'))
    set(handles.blkdimMinSlider, 'Value', get(handles.blkdimMinSlider,'Max'));
    set(handles.blkdimMinText, 'String', get(handles.blkdimMinSlider,'Max'));
end

guidata(hObject,handles);


% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function blkdimMaxSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to blkdimMaxSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global DEBUG;
if (DEBUG), fprintf('blkdimMaxSlider_CreateFcn\n'); end

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --------------------------------------------------------------------
function blkdimMaxText_Callback(hObject, eventdata, handles)
% hObject    handle to blkdimMaxText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DEBUG;
if (DEBUG), fprintf('blkdimMaxText_Callback\n'); end

% Hints: get(hObject,'String') returns contents of blkdimMaxText as text
%        str2double(get(hObject,'String')) returns contents of blkdimMaxText as a double


% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function blkdimMaxText_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,INUSD>
% hObject    handle to blkdimMaxText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global DEBUG;
if (DEBUG), fprintf('blkdimMaxText_CreateFcn\n'); end

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function initPos = getInitialPosition(hObject)
global DEBUG;
if (DEBUG), fprintf('getInitialPosition\n'); end

wa = getWorkArea();
hPosition = get(hObject,'Position');
x = (wa.width - hPosition(3))/2;
y = (wa.height - hPosition(4))/2;
initPos = round([x y hPosition(3) hPosition(4)]);


% --------------------------------------------------------------------
% --- Executes when user attempts to close avicom.
function avicom_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to avicom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DEBUG;
if (DEBUG), fprintf('AboutItem_Callback\n'); end
% Hint: delete(hObject) closes the figure

ud = get(handles.avicom, 'Userdata');
isRunning = strcmp(get(ud.hTimer,'Running'),'on');
if isRunning
     stop(ud.hTimer); % Shut off timer if running
end
delete(hObject);

% if(exist('DATA/originalVideoProperties.mat','file')), delete('DATA/originalVideoProperties.mat'); end
% if(exist('DATA/originalVideoPartitions.mat','file')), delete('DATA/originalVideoPartitions.mat'); end
% if(exist('DATA/PSNR_Cost.mat','file')), delete('DATA/PSNR_Cost.mat'); end
% if(exist('DATA/originalFrames','dir')), rmdir('DATA/originalFrames','s'); end
% if(exist('DATA/decodedFrames','dir')), rmdir('DATA/decodedFrames','s'); end
% if(exist('DATA/tables','dir')), rmdir('DATA/tables','s'); end


% --------------------------------------------------------------------
function DemoItem_Callback(hObject, eventdata, handles)
% hObject    handle to DemoItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DEBUG;
if (DEBUG), fprintf('DemoItem_Callback\n'); end

videoAxesPosition = get(handles.videoAxes, 'Position');

set(handles.videoAxes, ...
'xlim',[0 videoAxesPosition(3)], ...
'ylim',[0 videoAxesPosition(4)]);

resVidWidth = (videoAxesPosition(3)-1)/2;
resVidHeight = videoAxesPosition(4)-1;

ud = get(handles.avicom, 'Userdata');     
ud.hImage = image(...
    'Parent', handles.videoAxes, ...
    'cdata', 255*ones(resVidHeight, (resVidWidth*2)), ...
    'xdata', 1:(resVidWidth*2),...
    'ydata', 1:resVidHeight,...
    'erase','none');
ud.hTimer      = [];
ud.paused      = 0;
ud.nextFrame   = 1;
ud.currFrame   = 1;
ud.Movie       = [];
ud.numberOfMovieFrames = -1; 
set(handles.avicom, 'Userdata', ud);

file = 'DATA/DEMO/traffic.avi';
if(exist(file, 'file')) 
    h = waitbar(1,'Load multimedia reader object...');
    mmreader(file,'tag', 'originalAVI');
%     frameRate = get(mmrobj, 'FrameRate');
%     numFrames = get(mmrobj, 'NumberOfFrames');
%     vidFormat = get(mmrobj, 'VideoFormat');
%     vidHeight = get(mmrobj, 'Height');
%     vidWidth = get(mmrobj, 'Width'); 
    close(h);
else
   error(['File ' file ' not found']);
end

videoAxesPosition = get(handles.videoAxes, 'Position');
resVidWidth = videoAxesPosition(3)-1;
resVidHeight = videoAxesPosition(4)-1;

if(get(handles.blkdimMaxSlider, 'Value') > min(resVidHeight,resVidWidth))
    set(handles.blkdimMinSlider, 'Max', min(resVidHeight,resVidWidth));
end
set(handles.blkdimMaxSlider, 'Max', min(resVidHeight,resVidWidth));    
% if(get(handles.blkdimMaxSlider, 'Value') > min(vidHeight,vidWidth))
%     set(handles.blkdimMinSlider, 'Max', min(vidHeight,vidWidth));
% end
% set(handles.blkdimMaxSlider, 'Max', min(vidHeight,vidWidth));

set(handles.convertButton, 'Enable', 'off');
set(handles.abortButton, 'Enable', 'off');
set(handles.qmList, 'Value', 2);  
set(handles.qmList, 'Enable', 'off');  
set(handles.qtSlider, 'Value', 32);
set(handles.energyMinSlider, 'Value', 0.4);
set(handles.energyMaxSlider, 'Value', 0.9);
set(handles.blkdimMinSlider, 'Value', 8);
set(handles.blkdimMaxSlider, 'Value', 64);  
set(handles.qtSlider, 'Enable', 'off');
set(handles.energyMinSlider, 'Enable', 'off');
set(handles.energyMaxSlider, 'Enable', 'off');
set(handles.blkdimMinSlider, 'Enable', 'off');
set(handles.blkdimMaxSlider, 'Enable', 'off');

set(handles.SaveItem, 'Enable', 'on');

file = 'DATA/DEMO/originalVideoProperties.mat';
if(exist(file, 'file')), load(file);
else error(['File ' file ' not found']);
end

file = 'DATA/DEMO/originalVideoPartitions.mat';
if(exist(file, 'file')), load(file);
else error(['File ' file ' not found']);
end

set(handles.goToStartButton,'Enable','off');
set(handles.stepBackButton,'Enable','off');
set(handles.playButton,'Enable','off');
set(handles.stopButton,'Enable','off');
set(handles.stepForwardButton,'Enable','off');
set(handles.goToEndButton,'Enable','off');

set(handles.SaveItem, 'Enable', 'off');

numFPFT = ceil(partitions/4); % numFramesPackForTraining
numFPFV = partitions - numFPFT; % numFramesPackForValidation
    
% Simulo la compressione SVD e creo le tabelle corrispondenti
h = waitbar(0,'Create all trainingTable...');
for k = 1:numFPFT
    waitbar(k/numFPFT);
    pause(0.1);  
end
close(h);
% Stima dell'ordine delle superfici
h = waitbar(0,'Estimate surfaces orders...');
for k = 1:numFPFT
    waitbar(k/numFPFT);
    pause(0.1);    
end
close(h);
% Fitting table
h = waitbar(0,'Fit PSNR and FC surfaces...');
for k = 1:numFPFT
    waitbar(k/partitions);
    pause(0.1);
end
close(h);
h = waitbar(0,'Create all the decoded video sub-frames...');
for k = 1:numFPFV
    waitbar(k/numFPFV);
    pause(0.1);
end
close(h);

file = 'DATA/DEMO/PSNR_Cost.mat';
if(exist(file, 'file')), load(file);
else error(['File ' file ' not found']) 
end

axes(handles.psnrPlot);
cla;
plot(1:numFPFV,PSNR(2:size(PSNR,2)),'.-r');
xlabel('Step');
ylabel('PSNR [dB]');
axis tight;
grid on;
axes(handles.fcPlot);
cla;
plot(1:numFPFV,Cost(2:size(Cost,2)),'.-b');
xlabel('Step');
ylabel('FC')
axis tight;
grid on;

set(handles.originalVidLabel,'Visible','off');
set(handles.compressedVidLabel,'Visible','off');
   
framesGray = [];
decodedFramesGray = [];
h = waitbar(0,'Cat all the video frames...');
for i = partitions-numFPFV : partitions-1
    waitbar((i+1)/(numFPFV-1));
   
    file = ['DATA/DEMO/originalFrames/framesGrayPack' int2str(i) '.mat'];
    if(exist(file, 'file')), load(file);
    else error(['File ' file ' not found']); 
    end
    framesGray = cat(3, framesGray, subFramesGray);
    file = ['DATA/DEMO/decodedFrames/decodedFramesGrayPack' int2str(i) '.mat'];
    if(exist(file, 'file')), load(file);
    else error(['File ' file ' not found']); 
    end
    decodedFramesGray = cat(3, decodedFramesGray, decodedSubFramesGray);
end
close(h);  

mergedFrames = [framesGray decodedFramesGray];
ud.Movie = mergedFrames;
ud.numberOfMovieFrames = size(mergedFrames,3);
set(handles.avicom, 'Userdata', ud);

% Setup timer
ud = get(handles.avicom, 'Userdata');
ud.hTimer = timer('ExecutionMode','fixedRate', 'TimerFcn', {@TimerTickFcn, handles}, 'StopFcn', {@TimerStopFcn, handles}, 'BusyMode', 'drop', 'TasksToExecute', Inf);
set(handles.avicom, 'Userdata', ud);  

% Set frames per second for playback
isRunning = strcmp(get(ud.hTimer,'Running'),'on');
% isPaused = ud.paused;
if isRunning
    playButton_Callback(hObject, [], handles);  % pause
end
set(ud.hTimer, 'Period', 1./frameRate);
if isRunning 
    playButton_Callback(hObject, [], handles);
%     ud = get(hfig,'Userdata');
%     ud.paused = isPaused;
%     set(hfig,'Userdata',ud);
end

playButton_Callback(hObject, [], handles);


% --------------------------------------------------------------------
% --------------------------------------------------------------------
% --------------------------------------------------------------------

% --------------------------------------------------------
% --- Executes on button press in goToStartButton.
function goToStartButton_Callback(hObject, eventdata, handles)
% hObject    handle to goToStartButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% goto start button callback

ud = get(handles.avicom, 'Userdata');
if ud.currFrame ~= 1  % prevent repeated presses
    ud.currFrame = 1;
    ud.nextFrame = 1;
    set(handles.avicom, 'Userdata', ud);
    ud = get(handles.avicom, 'Userdata');
    set(ud.hImage, 'cdata', flipud(ud.Movie(:,:,ud.currFrame)));
end


% --------------------------------------------------------
% --- Executes on button press in stepBackButton.
function stepBackButton_Callback(hObject, eventdata, handles)
% hObject    handle to stepBackButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Step one frame backward callback

ud = get(handles.avicom, 'Userdata');
 
if ud.currFrame <= 1, return
else ud.currFrame = ud.currFrame-1;
end

ud.nextFrame = ud.currFrame;
upd = ~ud.paused;
ud.paused = 1;  % assume we're starting from pause
set(handles.avicom, 'Userdata', ud);
ud = get(handles.avicom, 'Userdata');
set(ud.hImage, 'cdata', flipud(ud.Movie(:,:,ud.currFrame)));
if upd, UpdateButtonsEnable(handles); end


% --------------------------------------------------------
% --- Executes on button press in playButton.
function playButton_Callback(hObject, eventdata, handles)
% hObject    handle to playButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Play button callback
ud = get(handles.avicom, 'Userdata');
icons = load('player_icons');  

% Check if timer is already running
if strcmp(get(ud.hTimer,'Running'),'on')
    % Movie already playing
    %  - Move to Pause mode
    %  - Show Play icon (currently must be pause indicator)
    
    % Stop timer, set pause mode
    ud.paused = 1;
    set(handles.avicom, 'Userdata', ud);
    stop(ud.hTimer);
    
    % Flush changes
    ud = get(handles.avicom, 'Userdata');
    set(ud.hImage, 'cdata', flipud(ud.Movie(:,:,ud.currFrame)));

    % Set play icon, darker
    set(handles.playButton, ...
        'tooltip', 'Resume', ...
        'cdata', icons.play_off);
else
    % Not running
    if ud.paused
        % Paused - move to play
        ud.nextFrame = ud.currFrame;
    else
        % Stopped - move to play
        ud.nextFrame = 1;  % Start from 1st frame when stopped
    end
    set(handles.avicom, 'Userdata', ud);
    
    % Show pause icon
    set(handles.playButton, ...
        'tooltip', 'Pause', ...
        'cdata', icons.pause_default);
    start(ud.hTimer);
end
UpdateButtonsEnable(handles);


% --------------------------------------------------------
function UpdateButtonsEnable(handles)
%               stopped  paused   running 
%       1st              (all 1)
%       StepRev    1        1        0
%       Stop       0        1        1
%       Play       1        1        1
%       StepFwd    1        1        0
%       Last             (all 1)

ud = get(handles.avicom,'Userdata');
isRunning = strcmp(get(ud.hTimer,'Running'),'on');
isPaused  = ~isRunning &&  ud.paused;
isStopped = ~isRunning && ~ud.paused;

if isStopped
    set(handles.goToStartButton,'Enable','on');
    set(handles.stepBackButton,'Enable','on');
    set(handles.playButton,'Enable','on');
    set(handles.stopButton,'Enable','off');
    set(handles.stepForwardButton,'Enable','on');
    set(handles.goToEndButton,'Enable','on');   
elseif isPaused
    set(handles.goToStartButton,'Enable','on');
    set(handles.stepBackButton,'Enable','on');
    set(handles.playButton,'Enable','on');
    set(handles.stopButton,'Enable','on');
    set(handles.stepForwardButton,'Enable','on');
    set(handles.goToEndButton,'Enable','on');    
else
    set(handles.goToStartButton,'Enable','on');
    set(handles.stepBackButton,'Enable','off');
    set(handles.playButton,'Enable','on');
    set(handles.stopButton,'Enable','on');
    set(handles.stepForwardButton,'Enable','off');
    set(handles.goToEndButton,'Enable','on');
end


% --------------------------------------------------------
% --- Executes on button press in stopButton.
function stopButton_Callback(hObject, eventdata, handles)
% hObject    handle to stopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Stop button callback

ud = get(handles.avicom, 'Userdata');
ud.paused = 0;  % we're stopped, not paused
set(handles.avicom,'Userdata',ud);

isRunning = strcmp(get(ud.hTimer,'Running'),'on');
if isRunning
    stop(ud.hTimer);
else
    % Allow stop even when movie not running
    % We could have been paused
    icons = load('player_icons');  
    set(handles.playButton, 'CData', icons.play_on, 'tooltip', 'Play');
    UpdateButtonsEnable(handles);
end


% --------------------------------------------------------
% --- Executes on button press in stepForwardButton.
function stepForwardButton_Callback(hObject, eventdata, handles)
% hObject    handle to stepForwardButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Step one frame forward callback

ud = get(handles.avicom, 'Userdata');
 
if ud.currFrame >= ud.numberOfMovieFrames, return
else ud.currFrame = ud.currFrame+1;
end
    
ud.nextFrame = ud.currFrame;
upd = ~ud.paused;
ud.paused = 1;  % assume we're starting from pause
set(handles.avicom, 'Userdata', ud);
ud = get(handles.avicom, 'Userdata');
set(ud.hImage, 'cdata', flipud(ud.Movie(:,:,ud.currFrame)));
if upd, UpdateButtonsEnable(handles); end


% --------------------------------------------------------
% --- Executes on button press in goToEndButton.
function goToEndButton_Callback(hObject, eventdata, handles)
% hObject    handle to goToEndButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Goto end button callback

ud = get(handles.avicom, 'Userdata');
if ud.currFrame ~= ud.numberOfMovieFrames
    ud.currFrame = ud.numberOfMovieFrames;
    ud.nextFrame = ud.currFrame;
    set(handles.avicom, 'Userdata', ud);
    ud = get(handles.avicom, 'Userdata');
    set(ud.hImage, 'cdata', flipud(ud.Movie(:,:,ud.currFrame)));
end


% --------------------------------------------------------
function TimerTickFcn(hObject, eventdata, handles)

ud = get(handles.avicom, 'Userdata');
ud.currFrame = ud.nextFrame;

set(ud.hImage, 'cdata', flipud(ud.Movie(:,:,ud.currFrame)));

% Increment frame or stop playback if finished
%if (ud.currFrame == ud.numberOfFrames)
if (ud.currFrame == ud.numberOfMovieFrames)
    % Last frame of movie just displayed
    ud.nextFrame = 1;  % loop back to beginning
    shouldStop = 1;   
    % If we hit this point, the timer ran us to the end of
    % the movie.  In particular, the user did not hit stop.
    % Now, if pause is on, it's due to manual interaction with
    % the fwd/back buttons, and not due to actual pausing,
    % obvious since we're still running and is why we're here.
    % Turn off pause:
    ud.paused = 0;   
elseif (ud.currFrame == 1)
    ud.nextFrame = 2;  % ud.currframe+1
    shouldStop = 0;   
else
    ud.nextFrame = ud.nextFrame + 1;  % next frame, fwd play
    shouldStop = 0;
end

set(handles.avicom, 'Userdata', ud);

if shouldStop
    stop(ud.hTimer); % stop playback
end


% --------------------------------------------------------
function TimerStopFcn(hObject, eventdata, handles)
% ShowMovieFrame(handles);

icons = load('player_icons');  
set(handles.playButton, 'CData', icons.play_on, 'tooltip', 'Play');
UpdateButtonsEnable(handles);


% --------------------------------------------------------
function [mergedFrames numberOfMovieFrames] = catMovie(handles, numFramesPack)

% file = 'DATA/originalVideoProperties.mat';
% if(exist(file,'file'))
%     load(file, '-regexp', 'frameRate');
% else
%     error(['Unable to load file ' filename]);  
% end
% 
% file = 'DATA/originalVideoPartitions.mat';
% if(exist(file))
%     load(file, '-regexp', 'partitions');
% else
%     error(['Unable to load file ' filename]); 
% end 
ud = get(handles.avicom, 'Userdata');
partitions = ud.partitions;
% frameRate = ud.frameRate;

framesGray = [];
decodedFramesGray = [];
h = waitbar(0,'Cat the video frames...');
for i = partitions-numFramesPack : partitions-1
    if(ud.abort), close(h); return; end
    waitbar((i-partitions+numFramesPack+1)/(numFramesPack-1));
   
    file = ['DATA/originalFrames/framesGrayPack' int2str(i) '.mat'];
    if(exist(file, 'file')), load(file);
    else error(['File ' file ' not found']);
    end
    file = ['DATA/decodedFrames/decodedFramesGrayPack' int2str(i) '.mat'];
    if(exist(file, 'file')), load(file);
    else error(['File ' file ' not found']);
    end
    if(size(framesGray,3) < 700 && size(decodedFramesGray,3) < 700)      
        framesGray = cat(3, framesGray, subFramesGray);
        decodedFramesGray = cat(3, decodedFramesGray, decodedSubFramesGray);
    else
        warndlg('Cut operation exceeded the max number of frames allowed.','Warning');       
        uiwait;
        break;
    end
end
close(h);  

mergedFrames = [framesGray decodedFramesGray];
numberOfMovieFrames = size(mergedFrames,3);

% Create a MATLAB movie struct Gray from the video frames.
% h = waitbar(0,'Create movie struct gray(256)...');
%  for i = 1 : size(mergedFrames,3)
%      waitbar(i/size(mergedFrames,3));    
%      mergedFrames4D(:,:,1,i) = mergedFrames(:,:,i);
%      mov(i) = immovie(mergedFrames4D(:,:,1,i),gray(256));
%  end
% close(h);

% movie(handles.originalVideoAxes, mov, 1, frameRate, [1 1 0 0]);