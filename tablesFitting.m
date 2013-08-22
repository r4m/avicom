function tablesFitting(numFramesPack, orderPSNR, orderFC, handles, nameTables)

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

if(~exist('DATA/decodedFrames','dir'))
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
ParametriPSNR = zeros(orderPSNR,numFramesPack);    % in ogni colonna t-esima, i parametri PSNR b_i 
ParametriCost = zeros(orderFC,numFramesPack);      % in ogni colonna t-esima, i parametri FC a_i
FitsPSNR = cell(1,numFramesPack);                           % valori fittati S*theta_{PSNR}
FitsCost = cell(1,numFramesPack);                           % valori fittati S*theta_{FC}
MsePSNR = zeros(1,numFramesPack);                           % errore quadratico medio del fit PSNR        
MseCost = zeros(1,numFramesPack);                           % errore quadratico medio del fit FC        
VettoreEnergia = eMin:stepEnergy:eMax;    % epsilon1 = E energia percentuale (i.e. 0.6 = 60%)
VettoreBlkDim = dMin:stepBlkdim:dMax;     % epsilon1 = L in numero di pixel
[X,Y] = meshgrid(VettoreEnergia,VettoreBlkDim);

% Fit superfici
h = waitbar(0,'Fit PSNR and FC surfaces...');
for i = 0:numFramesPack-1
    ud = get(handles.avicom, 'Userdata');
    if(ud.abort), close(h); return; end
    waitbar((i+1)/numFramesPack);
    file = ['DATA/tables/' nameTables int2str(i) '.mat'];
    if(exist(file,'file'))
        load(file);
    else
        error(['File ' file ' not found']);
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
            S = [];
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
            S = [];
            error('FC optimum order not in list');
    end
    % Fit superficie FC
    ParametriCost(:,i+1) = regress(tableFC(:),S);
    FitsCost{i+1} = reshape(S*ParametriCost(:,i+1),length(VettoreBlkDim),length(VettoreEnergia));
    MseCost(i+1) = (norm(tableFC(:)-S*ParametriCost(:,i+1))^2)/(length(tableFC(:))-length(ParametriCost(:,i+1)));
    clear tablePSNR tableFC 
end
close(h);

%--------------------------------------------------------------------------
% OTTIMIZZAZIONE BASATA SUI PARAMETRI FITTATI SULLE TABELLE PSNR E FC
% Si utilizzano i parametri stimati in maniera statica ai minimi quadrati
% per trovare i controlli di Energia e DimensioneBlocco ottimi: ciò è
% realizzato minimizzando la funzione costo FC con il vincolo che l'indice
% di qualità HSV sia sempre sopra ad una certa soglia.
%--------------------------------------------------------------------------

qualityThreshold = get(handles.qtSlider, 'Value');
% Inizializzazioni
Controlli = zeros(2,numFramesPack);           % nella prima riga i controlli di energia, nella seconda quelli di dimensione
MinCost = zeros(1,numFramesPack);             % valori minimi di FC relativi ai controlli ottimi
%HSVVero = zeros(1,numFramesPack);             % valori di HSV ottenuti simulando la compressione SVD con i controlli ottimi
CostVero = zeros(1,numFramesPack);            % valori di FC ottenuti simulando la compressione SVD con i controlli ottimi
%x0 = [.65;36];                    % inizializzazione della routine di ottimizzazione "fmincon" (valori plausibili)
%flag = zeros(1,numFramesPack);
%options = optimset('TolFun',1e-10,'TolCon',1e-10,'MaxFunEvals',10000,'LargeScale','off','MaxIter',10000);
%options = optimset('TolFun',1e-10,'TolCon',1e-10,'MaxFunEvals',10000,'LargeScale','off','MaxIter',10000);
%[u,v] = meshgrid(-numFramesPack:numFramesPack-1,-numFramesPack:numFramesPack-1);
%H = (0.2+0.45*sqrt(u.^2+v.^2)).*exp(-0.18*sqrt(u.^2+v.^2));

h = waitbar(0,'Create all the decoded video sub-frames...');
for i = 0:numFramesPack-1
    ud = get(handles.avicom, 'Userdata');
    if(ud.abort), close(h); return; end 
    
    waitbar((i+1)/numFramesPack);
%     % Calcolo controlli ottimi
%     [Controlli(:,i),MinCost(i), flag(i)] = fmincon(@(x) CostFunction(x,ParametriCost(:,i),'fpe'),x0,...
%                                            [eye(2);-eye(2)],[1;64;-.4;-8],[],[],[],[],...
%                                            @(x) PsnrConstrain(x,ParametriPSNR(:,i),qualityThreshold,'fpe'),options);
    [Controlli(:,i+1),MinCost(i+1)] = optimizationRoutine(ParametriCost(:,i+1), ParametriPSNR(:,i+1), qualityThreshold, handles);
    % x0 = Controlli(:,i);            % aggiornamento inizializzazione della routine "fmincon"
    % Simulazione compressione SVD con i controlli ottimi

    file = ['DATA/originalFrames/framesGrayPack' int2str(i) '.mat'];
    if(exist(file,'file'))
        load(file);
    else
        error(['File ' file ' not found']);
    end   
    [decodedSubFramesGray Components] = SVDCompressionSimRev(subFramesGray, Controlli(1,i+1), round(Controlli(2,i+1)));
    
%     figure
%     FramesVisualization(decodedSubFramesGray)
    save(['DATA/decodedFrames/decodedFramesGrayPack' int2str(i) '.mat'],'decodedSubFramesGray');
    % Calcolo HSV e FC ottimi
%     tic
    PSNR(i+1) = compute_psnr(subFramesGray, decodedSubFramesGray);                
%     toc
    Cost(i+1) = sum((4*round(Controlli(2,1))^2+4*size(decodedSubFramesGray,3))*Components)/(size(decodedSubFramesGray,3)*size(decodedSubFramesGray,1)*size(decodedSubFramesGray,2));
    
    decodedSubFramesGray = uint8(decodedSubFramesGray);
    clear subFramesGray decodedSubFramesGray Components
end
close(h);

save DATA/PSNR_Cost.mat PSNR Cost