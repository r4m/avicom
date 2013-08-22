function kalmanFiltering(numFPFT, numFPFV, orderPSNR, orderFC, handles, nameTables)

%--------------------------------------------------------------------------
% STIMA STATICA AI MINIMI QUADRATI DELLE SUPERFICI INTERPOLANTI LE TABELLE 
% PSNR E FC
% A partire dalle tabelle PSNR e FC risultanti dalle simulazioni di
% compressione, si fittano dei modelli polinomiali di ordine ottimo,
% stabilito in precedenza.
% Nel seguito si utilizzano i parametri così stimati per calcolare le
% varianze dei rumori di modello (indicanti il tasso di variabilità 
% temporale dei parametri) da utilizzarsi successivamente nei filtri di
% Kalman; inoltre, si utilizzano gli errori quadratici medi (MSE) delle 
% interpolazioni per tarare le varianze dei rumori di misura. 
%--------------------------------------------------------------------------

if(~exist('DATA/decodedFrames', 'dir'))
    if(~mkdir('DATA/decodedFrames'));
        error('Unable to create directory DATA/decodedFrames');
    end
else
   delete(['DATA/decodedFrames/' nameTables '*.mat']);
end

stepEnergy = getappdata(handles.avicom, 'stepEnergy');
stepBlkdim = getappdata(handles.avicom, 'stepBlkdim');
eMin = get(handles.energyMinSlider, 'Value');
eMax = get(handles.energyMaxSlider, 'Value');
dMin = get(handles.blkdimMinSlider, 'Value');
dMax = get(handles.blkdimMaxSlider, 'Value');

% Inizializzazioni
ParametriPSNR = zeros(orderPSNR,numFPFT);    % in ogni colonna t-esima, i parametri PSNR b_i 
ParametriCost = zeros(orderFC,numFPFT);      % in ogni colonna t-esima, i parametri FC a_i
FitsPSNR = cell(1,numFPFT);                           % valori fittati S*theta_{PSNR}
FitsCost = cell(1,numFPFT);                           % valori fittati S*theta_{FC}
MsePSNR = zeros(1,numFPFT);                           % errore quadratico medio del fit PSNR        
MseCost = zeros(1,numFPFT);                           % errore quadratico medio del fit FC        
VettoreEnergia = eMin:stepEnergy:eMax;    % epsilon1 = E energia percentuale (i.e. 0.6 = 60%)
VettoreBlkDim = dMin:stepBlkdim:dMax;     % epsilon1 = L in numero di pixel
[X,Y] = meshgrid(VettoreEnergia,VettoreBlkDim);

% Fit superfici
h = waitbar(0,'Fit PSNR and FC surfaces...');
for i = 0:numFPFT-1
    ud = get(handles.avicom, 'Userdata');
    if(ud.abort), close(h); return; end
    file = ['DATA/tables/' nameTables int2str(i) '.mat'];
    if(exist(file, 'file')), load(file);
    else error(['File ' file ' not found']);
    end    
    % costruzione della matrice S corrispondente all'ordine ottimo orderPSNR
    switch orderPSNR
        case 3
            S = [ones(length(tablePSNR(:)),1) X(:) Y(:)];
        case 4
            S = [ones(length(tablePSNR(:)),1) X(:) Y(:) X(:).*Y(:)];
        case 5
            S = [ones(length(tablePSNR(:)),1) X(:) Y(:) X(:).*Y(:) X(:).^2];
        case 6
            S = [ones(length(tablePSNR(:)),1) X(:) Y(:) X(:).*Y(:) X(:).^2 Y(:).^2];
        case 7
            S = [ones(length(tablePSNR(:)),1) X(:) Y(:) X(:).*Y(:) X(:).^2 Y(:).^2 (X(:).^2).*Y(:)];
        case 8
            S = [ones(length(tablePSNR(:)),1) X(:) Y(:) X(:).*Y(:) X(:).^2 Y(:).^2 (X(:).^2).*Y(:) (Y(:).^2).*X(:)];
        case 9
            S = [ones(length(tablePSNR(:)),1) X(:) Y(:) X(:).*Y(:) X(:).^2 Y(:).^2 (X(:).^2).*Y(:) (Y(:).^2).*X(:) (X(:).^2).*(Y(:).^2)];
        case 10
            S = [ones(length(tablePSNR(:)),1) X(:) Y(:) X(:).*Y(:) X(:).^2 Y(:).^2 (X(:).^2).*Y(:) (Y(:).^2).*X(:) (X(:).^2).*(Y(:).^2) X(:).^3];
        case 11
            S = [ones(length(tablePSNR(:)),1) X(:) Y(:) X(:).*Y(:) X(:).^2 Y(:).^2 (X(:).^2).*Y(:) (Y(:).^2).*X(:) (X(:).^2).*(Y(:).^2) X(:).^3 Y(:).^3];
        otherwise
            error('PSNR optimum order not in list');
    end
    % Fit superficie PSNR
    ParametriPSNR(:,i+1) = regress(tablePSNR(:),S);
    FitsPSNR{i+1} = reshape(S*ParametriPSNR(:,i+1),length(VettoreBlkDim),length(VettoreEnergia));
    MsePSNR(i+1) = (norm(tablePSNR(:)-S*ParametriPSNR(:,i+1))^2)/(length(tablePSNR(:))-length(ParametriPSNR(:,i+1)));
        % costruzione della matrice S corrispondente all'ordine ottimo orderFC
    switch orderFC
        case 3
            S = [ones(length(tableFC(:)),1) X(:) Y(:)];
        case 4
            S = [ones(length(tableFC(:)),1) X(:) Y(:) X(:).*Y(:)];
        case 5
            S = [ones(length(tableFC(:)),1) X(:) Y(:) X(:).*Y(:) X(:).^2];
        case 6
            S = [ones(length(tableFC(:)),1) X(:) Y(:) X(:).*Y(:) X(:).^2 Y(:).^2];
        case 7
            S = [ones(length(tableFC(:)),1) X(:) Y(:) X(:).*Y(:) X(:).^2 Y(:).^2 (X(:).^2).*Y(:)];
        case 8
            S = [ones(length(tableFC(:)),1) X(:) Y(:) X(:).*Y(:) X(:).^2 Y(:).^2 (X(:).^2).*Y(:) (Y(:).^2).*X(:)];
        case 9
            S = [ones(length(tableFC(:)),1) X(:) Y(:) X(:).*Y(:) X(:).^2 Y(:).^2 (X(:).^2).*Y(:) (Y(:).^2).*X(:) (X(:).^2).*(Y(:).^2)];
        case 10
            S = [ones(length(tableFC(:)),1) X(:) Y(:) X(:).*Y(:) X(:).^2 Y(:).^2 (X(:).^2).*Y(:) (Y(:).^2).*X(:) (X(:).^2).*(Y(:).^2) X(:).^3];
        case 11
            S = [ones(length(tableFC(:)),1) X(:) Y(:) X(:).*Y(:) X(:).^2 Y(:).^2 (X(:).^2).*Y(:) (Y(:).^2).*X(:) (X(:).^2).*(Y(:).^2) X(:).^3 Y(:).^3];
        otherwise
            error('FC optimum order not in list');
    end
    % Fit superficie FC
    ParametriCost(:,i+1) = regress(tableFC(:),S);
    FitsCost{i+1} = reshape(S*ParametriCost(:,i+1),length(VettoreBlkDim),length(VettoreEnergia));
    MseCost(i+1) = (norm(tableFC(:)-S*ParametriCost(:,i+1))^2)/(length(tableFC(:))-length(ParametriCost(:,i+1)));
    clear tablePSNR tableFC 
    waitbar((i+1)/numFPFT);
end
close(h);

% Stima del tasso di variabilità dei parametri (Q) tramite th.ergodico (si veda Report april 08)
StimaQ = cell(1,numFPFT);                    % raccolta di tutte le Q_FC stimate al variare di t
StimaQ{1} = eye(orderFC);                  % Q(1) = I
TrStimaQ = zeros(1,numFPFT);
TrStimaQ(1) = trace(StimaQ{1});
TempStimaQ = zeros(orderFC);
% Stima mediante th.ergodico
h = waitbar(0,'Estimate FC variance... ');
for i = 0:numFPFT-2
    waitbar(i/(numFPFT-2));
    for j = 1:i
        TempStimaQ = TempStimaQ + (ParametriCost(:,j+1)-ParametriCost(:,j))*(ParametriCost(:,j+1)-ParametriCost(:,j))';
    end
    StimaQ{i+2} = TempStimaQ/(i+1);
    TrStimaQ(i+2) = trace(StimaQ{i+2});
    TempStimaQ = zeros(orderFC);
end
close(h);
Qcost = StimaQ{end};                    % Q_FC da usare nel filtro di Kalman    

StimaQ = cell(1,numFPFT);                    % raccolta di tutte le Q_PSNR stimate al variare di t
StimaQ{1} = eye(orderPSNR);
TrStimaQ = zeros(1,numFPFT);
TrStimaQ(1) = trace(StimaQ{1});
TempStimaQ = zeros(orderPSNR);
% Stima mediante th.ergodico
h = waitbar(0,'Estimate PSNR variance... ');
for i = 0:numFPFT-2
    waitbar(i/(numFPFT-2));
    for j = 1:i
        TempStimaQ = TempStimaQ + (ParametriPSNR(:,j+1)-ParametriPSNR(:,j))*(ParametriPSNR(:,j+1)-ParametriPSNR(:,j))';
    end
    StimaQ{i+2} = TempStimaQ/(i+1);
    TrStimaQ(i+2) = trace(StimaQ{i+2});
    TempStimaQ = zeros(orderPSNR);
end
close(h);
QPSNR = StimaQ{end};                    % Q_PSNR da usare nel filtro di Kalman   

% Calcolo varianza del rumore di misura (R) da usarsi nei filtri di Kalman
Rcost = mean(MseCost)*eye(orderFC);
RPSNR = mean(MsePSNR)*eye(orderPSNR);


%--------------------------------------------------------------------------
% OTTIMIZZAZIONE BASATA SUI PARAMETRI STIMATI TRAMITE FILTRO DI KALMAN
% In primo luogo si stimano ricorsivamente i parametri delle superfici PSNR
% e FC tramite due filtri di Kalman; le misure dei filtri sono pescate a
% random rispettivamente in TabellaPSNR e TabellaFC per ciascun istante t.
% In seguito si calcolano i controlli ottimi analogamente al caso statico
% di stima.
%--------------------------------------------------------------------------

% Inizializzazioni
qualityThreshold = get(handles.qtSlider, 'Value');
% [u,v] = meshgrid(-40:39,-40:39);
% H = (0.2+0.45*sqrt(u.^2+v.^2)).*exp(-0.18*sqrt(u.^2+v.^2));

% Simulazione compressione SVD con i controlli ottimi
StimeParametriPSNR = zeros(orderPSNR,numFPFV);             % parametri PSNR stimati dal KF
StimeParametriCost = zeros(orderFC,numFPFV);             % parametri FC stimati dal KF
StimeControlli = zeros(2,numFPFV);                    % controlli ottimi calcolati usando i par stimati dal KF
StimeCostFunc = zeros(1,numFPFV);                     % valori minimi di FC relativi ai controlli ottimi
PSNR = zeros(1,numFPFV);                              % valori di PSNR ottenuti simulando la compressione SVD con i controlli ottimi    
Cost = zeros(1,numFPFV);                              % valori di FC ottenuti simulando la compressione SVD con i controlli ottimi

StimeParametriPSNR(:,1) = ParametriPSNR(:,numFPFT);   % inizializzazione del KF
StimeParametriCost(:,1) = ParametriCost(:,numFPFT);   % inizializzazione del KF
VarQ = 0.1*eye(orderPSNR);                     % inizializzazione del KF
VarFC = 0.1*eye(orderFC);                     % inizializzazione del KF

h = waitbar(0,'Create all the decoded video sub-frames...');
%[StimeControlli(:,1), StimeCostFunc(1)] = optimizationRoutine(StimeParametriCost(:,1),normalizeQ(StimeParametriPSNR(:,1),X,Y),qualityThreshold,handles);
[StimeControlli(:,1), StimeCostFunc(1)] = optimizationRoutine(StimeParametriCost(:,1),StimeParametriPSNR(:,1),qualityThreshold,handles);
file = ['DATA/originalFrames/framesGrayPack' int2str(numFPFT-1) '.mat'];
if(exist(file, 'file')) load(file);
else error(['File ' file ' not found']);
end  

waitbar(0);
[DecodedFrame Components] = SVDCompressionSimRev(subFramesGray, StimeControlli(1,1), round(StimeControlli(2,1)));
%FramesVisualization(DecodedFrame)
PSNR(1) = compute_psnr(subFramesGray, DecodedFrame);                
Cost(1) = sum((4*round(StimeControlli(2,1))^2+4*size(DecodedFrame,3))*Components)/(size(DecodedFrame,3)*size(DecodedFrame,1)*size(DecodedFrame,2));
% clear subFramesGray DecodedFrame Components

% systemTime = zeros(1,numFPFV);

% Test del sistema sui dati di validazione
for i = numFPFT : numFPFT+numFPFV-1
    ud = get(handles.avicom, 'Userdata');
    if(ud.abort), close(h); return; end
    file = ['DATA/originalFrames/framesGrayPack' int2str(i) '.mat'];
    if(exist(file,'file')), load(file);
    else error(['File ' file ' not found']);
    end   
    %t = cputime;
    k = i-numFPFT;
    
    waitbar((k+1)/numFPFV);
    [PSNR(k+2),Cost(k+2),StimeParametriPSNR(:,k+2),VarQ,StimeParametriCost(:,k+2),VarFC,StimeControlli(:,k+2),decodedSubFramesGray,Components] = ...
    globalSystemPSNR(subFramesGray,orderPSNR,orderFC,StimeParametriPSNR(:,k+1),VarQ,StimeParametriCost(:,k+1),VarFC,QPSNR,RPSNR,Qcost,Rcost,qualityThreshold,X,Y,VettoreEnergia,VettoreBlkDim,handles);
    %systemTime(k+2) = cputime - t;
    save(['DATA/decodedFrames/decodedFramesGrayPack' int2str(i) '.mat'],'decodedSubFramesGray');
end
close(h);

save DATA/PSNR_Cost.mat PSNR Cost