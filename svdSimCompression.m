function svdSimCompression(numFramesPack, handles, nameTables)

%--------------------------------------------------------------------------
% SIMULAZIONI COMPRESSIONE VIA SVD
% Dopo aver caricato ciascun sottoflusso video, si simula la compressione
% attraverso SVD per tutte le combinazioni dei parametri di controllo 
% Energia e Dimensione Blocchetto; infine si calcolano l'indice di qualità 
% PSNR e la funzione costo FC.
%--------------------------------------------------------------------------

if(~exist('DATA/tables','dir'))
    if(~mkdir('DATA/tables'));
        error('Unable to create directory DATA/tables');
    end
else
   delete(['DATA/tables/' nameTables '*.mat']);
end
stepEnergy = getappdata(handles.avicom, 'stepEnergy');
stepBlkdim = getappdata(handles.avicom, 'stepBlkdim');
eMin = get(handles.energyMinSlider, 'Value');
eMax = get(handles.energyMaxSlider, 'Value');
dMin = get(handles.blkdimMinSlider, 'Value');
dMax = get(handles.blkdimMaxSlider, 'Value');

% Definizione dei vettori ENERGIA e Dimensione BLOCCHI
VettoreEnergia = eMin:stepEnergy:eMax;    % epsilon1 = E energia percentuale (i.e. 0.6 = 60%)
VettoreBlkDim = dMin:stepBlkdim:dMax;     % epsilon1 = L in numero di pixel

% Inizializzazione Tabelle contenenti i valori di PSNR e FC al variare dei
% Parametri Energia e Dimensione Blocco
tableTimeSVD = zeros(length(VettoreBlkDim),length(VettoreEnergia));
tableFC = zeros(length(VettoreBlkDim),length(VettoreEnergia));       % tabella che raccoglie i costi  
tablePSNR = zeros(length(VettoreBlkDim),length(VettoreEnergia));     % tabella che raccoglie i PSNR                                                                    % nelle righe le dim. dei blk, nelle colonne le percentuali di energia
tableTimePSNR = zeros(length(VettoreBlkDim),length(VettoreEnergia));
%TabellaPSHVSNR = zeros(length(VettoreBlkDim),length(VettoreEnergia));
%TabellaTimePSHVSNR = zeros(length(VettoreBlkDim),length(VettoreEnergia));
%TabellalogHVSNMSE = zeros(length(VettoreBlkDim),length(VettoreEnergia));
%TabellaTimelogHVSNMSE = zeros(length(VettoreBlkDim),length(VettoreEnergia));

% [u,v] = meshgrid(-40:39,-40:39);
% H = (0.2+0.45*sqrt(u.^2+v.^2)).*exp(-0.18*sqrt(u.^2+v.^2));

totalStep = length(VettoreEnergia)*length(VettoreBlkDim)*(numFramesPack);

h = waitbar(0,['Create all ' nameTables '...']);
for k = 0:numFramesPack-1
    file = ['DATA/originalFrames/framesGrayPack' int2str(k) '.mat'];
    if(exist(file, 'file'))
        load(file);
    else
        error(['File ' file ' not found']);
    end
    sizeSubFramesGray = size(subFramesGray,3);
    for i = 1:length(VettoreBlkDim)
        for j = 1:length(VettoreEnergia)
            ud = get(handles.avicom, 'Userdata');
            if(ud.abort), close(h); return; end
            % Scelta del parametro energia
            Energia = VettoreEnergia(j);
            % Scelta del parametro dimensione blocco
            L = VettoreBlkDim(i);
            % Simulazione della compressione SVD
%             t = cputime;
            [DecodedFrame Components] = SVDCompressionSimRev(subFramesGray, Energia, L);
%             tableTimeSVD(i,j) = cputime - t;
            % Calcolo FC
            tableFC(i,j) = sum((4*L^2+4*sizeSubFramesGray)*Components)/(sizeSubFramesGray*size(DecodedFrame,1)*size(DecodedFrame,2));           
            % Calcolo PSNR
%             t = cputime;
            tablePSNR(i,j) = compute_psnr(subFramesGray, DecodedFrame);           
%             tableTimePSNR(i,j) = cputime - t;   
%             % Calcolo PSHVSNR
%             t = cputime;
%             TabellaPSHVSNR(i,j) = compute_PSHVSNR(subFramesGray, DecodedFrame, H);
%             TabellaTimePSHVSNR(i,j) = cputime - t;
%             % Calcolo logHVSNMSE
%             t = cputime;
%             TabellalogHVSNMSE(i,j) = compute_logHVSNMSE(subFramesGray, DecodedFrame, H);
%             TabellaTimelogHVSNMSE(i,j) = cputime - t;
            clear DecodedFrame Components
            waitbar(((length(VettoreEnergia)*(length(VettoreBlkDim)*k+i-1))+j)/totalStep);
        end
    end
    clear subFramesGray
    % Salvataggio delle tabelle PSNR e FC relative al sottoflusso k-esimo
    save(['DATA/tables/' nameTables int2str(k) '.mat'], 'tableFC', 'tablePSNR');
    %save(['DATA/tables/' nameTables int2str(k) '.mat'], 'tableTimeSVD', 'tableFC', 'tablePSNR', 'tableTimePSNR');
    %save(['tabelleRIScompSVD' int2str(k) '.mat'],'TabellaPSNR','TabellaFC','TabellaPSHVSNR','TabellalogHVSNMSE','TabellaTimePSNR','TabellaTimePSHVSNR','TabellaTimelogHVSNMSE','TabellaTimeSVD');
end
close(h);