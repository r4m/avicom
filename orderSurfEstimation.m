function [orderPSNR orderFC] = orderSurfEstimation(numFramesPack, handles, nameTables)

%--------------------------------------------------------------------------
% STIMA DELL'ORDINE DELLE SUPERFICI
% Dopo aver suddiviso le tabelle PSNR e FC in dati per la calibrazione (la 
% prima metà di righe) e per la validazione (la seconda metà), si fittato 
% delle superfici interpolanti sui dati di calibrazione utilizzando vari
% modelli di ordine p crescente e si calcolano gli indici FPE. L'ordine
% migliore è calcolato minimizzando la funzione FPE al variare di p.
%--------------------------------------------------------------------------

stepEnergy = getappdata(handles.avicom, 'stepEnergy');
stepBlkdim = getappdata(handles.avicom, 'stepBlkdim');
eMin = get(handles.energyMinSlider, 'Value');
eMax = get(handles.energyMaxSlider, 'Value');
dMin = get(handles.blkdimMinSlider, 'Value');
dMax = get(handles.blkdimMaxSlider, 'Value');

VettoreEnergia = eMin:stepEnergy:eMax;    % epsilon1 = E energia percentuale (i.e. 0.6 = 60%)
VettoreBlkDim = dMin:stepBlkdim:dMax;     % epsilon1 = L in numero di pixel

minOrder = 3;
maxOrder = 11;
p = minOrder : maxOrder;                               

% Creazione della tabella di coppie (Energia,Dimensione Blocco)
[X,Y] = meshgrid(VettoreEnergia, VettoreBlkDim);
% Suddivisione in parametri per l'IDentificazione e per la VALidazione
XID = X(1:round(size(X,1)/3),:); 
%XVAL = X(round(size(X,1)/2)+1:end,:); 
YID = Y(1:round(size(Y,1)/3),:); 
%YVAL = Y(round(size(Y,1)/2)+1:end,:); 
% Numero di dati con cui si calibrano le superfici
N = length(XID(:));

% Generazione dei modelli con p crescente y = S_p*theta in cui y = PSNR o y
% = FC
% p=3: f = a0 + a1*x + a2*y
S3 = [ones(length(XID(:)),1) XID(:) YID(:)];
% p=4: f = a0 + a1*x + a2*y + a3*x*y
S4 = [ones(length(XID(:)),1) XID(:) YID(:) XID(:).*YID(:)];
% p=5: f = a0 + a1*x + a2*y + a3*x*y + a4*x^2
S5 = [ones(length(XID(:)),1) XID(:) YID(:) XID(:).*YID(:) XID(:).^2];
% p=6: f = a0 + a1*x + a2*y + a3*x*y + a4*x^2 + a5*y^2
S6 = [ones(length(XID(:)),1) XID(:) YID(:) XID(:).*YID(:) XID(:).^2 YID(:).^2];
% p=7: f = a0 + a1*x + a2*y + a3*x*y + a4*x^2 + a5*y^2 + a6*x^2*y
S7 = [ones(length(XID(:)),1) XID(:) YID(:) XID(:).*YID(:) XID(:).^2 YID(:).^2 (XID(:).^2).*YID(:)];
% p=8: f = a0 + a1*x + a2*y + a3*x*y + a4*x^2 + a5*y^2 + a6*x^2*y +
% a7*x*y^2
S8 = [ones(length(XID(:)),1) XID(:) YID(:) XID(:).*YID(:) XID(:).^2 YID(:).^2 (XID(:).^2).*YID(:) (YID(:).^2).*XID(:)];
% p=9: f = a0 + a1*x + a2*y + a3*x*y + a4*x^2 + a5*y^2 + a6*x^2*y +
% a7*x*y^2 + a8*x^2*y^2
S9 = [ones(length(XID(:)),1) XID(:) YID(:) XID(:).*YID(:) XID(:).^2 YID(:).^2 (XID(:).^2).*YID(:) (YID(:).^2).*XID(:)...
      (XID(:).^2).*(YID(:).^2)];
% p=10: f = a0 + a1*x + a2*y + a3*x*y + a4*x^2 + a5*y^2 + a6*x^2*y +
% a7*x*y^2 + a8*x^2*y^2 + a9*x^3
S10 = [ones(length(XID(:)),1) XID(:) YID(:) XID(:).*YID(:) XID(:).^2 YID(:).^2 (XID(:).^2).*YID(:) (YID(:).^2).*XID(:)...
      (XID(:).^2).*(YID(:).^2) XID(:).^3];
% p=11: f = a0 + a1*x + a2*y + a3*x*y + a4*x^2 + a5*y^2 + a6*x^2*y +
% a7*x*y^2 + a8*x^2*y^2 + a9*x^3 + a10*y^3
S11 = [ones(length(XID(:)),1) XID(:) YID(:) XID(:).*YID(:) XID(:).^2 YID(:).^2 (XID(:).^2).*YID(:) (YID(:).^2).*XID(:)...
      (XID(:).^2).*(YID(:).^2) XID(:).^3 YID(:).^3];
  
% Calcolo degli indici FPE per tutti gli istanti t
FPEPSNR = zeros(numFramesPack,length(p));                      % in ogni riga t-esima, FPE(p) relativo alla t-esima sottosequenza 
pPSNR = zeros(numFramesPack,1);                                % ordini ottimali dei modelli per ogni t
FPEPSNRMin = zeros(numFramesPack,1);                           % valori minimi di FPE in corrispondenza degli ordini ottimali
FPECost = zeros(numFramesPack,length(p));                      % in ogni riga t-esima, FPE(p) relativo alla t-esima sottosequenza 
pCost = zeros(numFramesPack,1);                                % ordini ottimali dei modelli per ogni t
FPECostMin = zeros(numFramesPack,1);                           % valori minimi di FPE in corrispondenza degli ordini ottimali

h = waitbar(0,'Estimate surfaces orders...');
for i = 0:numFramesPack-1
    ud = get(handles.avicom, 'Userdata');
    if(ud.abort), close(h); orderPSNR = -1; orderFC = -1; return; end
    waitbar((i+1)/numFramesPack);    
    % Caricamento di tutti i dati
    file = ['DATA/tables/' nameTables int2str(i) '.mat'];
    if(exist(file,'file'))
        load(file);
    else
        error(['File ' file ' not found']);
    end        
    tablePSNR = -10*log10(tablePSNR);
    % Suddivisione in dati per l'identificazione e dati per la validazione
    DatiIDPSNR = tablePSNR(1:round(size(tablePSNR,1)/3),:);
    %DatiVALPSNR = tablePSNR(round(size(tablePSNR,1)/2)+1:end,:);
    DatiIDCost = tableFC(1:round(size(tableFC,1)/3),:);
    %DatiVALCost = tableFC(round(size(tableFC,1)/2)+1:end,:);
    % Stima dei parametri PSNR sui dati di calibrazione
    theta3PSNR = regress(DatiIDPSNR(:),S3);
    theta4PSNR = regress(DatiIDPSNR(:),S4);
    theta5PSNR = regress(DatiIDPSNR(:),S5);
    theta6PSNR = regress(DatiIDPSNR(:),S6);
    theta7PSNR = regress(DatiIDPSNR(:),S7);
    theta8PSNR = regress(DatiIDPSNR(:),S8);
    theta9PSNR = regress(DatiIDPSNR(:),S9);
    theta10PSNR = regress(DatiIDPSNR(:),S10);
    theta11PSNR = regress(DatiIDPSNR(:),S11);
    % Stima dei parametri FC sui dati di calibrazione
    theta3Cost = regress(DatiIDCost(:),S3);
    theta4Cost = regress(DatiIDCost(:),S4);
    theta5Cost = regress(DatiIDCost(:),S5);
    theta6Cost = regress(DatiIDCost(:),S6);
    theta7Cost = regress(DatiIDCost(:),S7);
    theta8Cost = regress(DatiIDCost(:),S8);
    theta9Cost = regress(DatiIDCost(:),S9);
    theta10Cost = regress(DatiIDCost(:),S10);
    theta11Cost = regress(DatiIDCost(:),S11);
    % Stima dei residui di proiezione sui modelli PSNR di ordine p
    resPSNR = zeros(1,length(p));
    resPSNR(1) = (norm(DatiIDPSNR(:)-S3*theta3PSNR)^2)/N;
    resPSNR(2) = (norm(DatiIDPSNR(:)-S4*theta4PSNR)^2)/N;
    resPSNR(3) = (norm(DatiIDPSNR(:)-S5*theta5PSNR)^2)/N;
    resPSNR(4) = (norm(DatiIDPSNR(:)-S6*theta6PSNR)^2)/N;
    resPSNR(5) = (norm(DatiIDPSNR(:)-S7*theta7PSNR)^2)/N;
    resPSNR(6) = (norm(DatiIDPSNR(:)-S8*theta8PSNR)^2)/N;
    resPSNR(7) = (norm(DatiIDPSNR(:)-S9*theta9PSNR)^2)/N;
    resPSNR(8) = (norm(DatiIDPSNR(:)-S10*theta10PSNR)^2)/N;
    resPSNR(9) = (norm(DatiIDPSNR(:)-S11*theta11PSNR)^2)/N;
    % Stima dei residui di proiezione sui modelli FC di ordine p
    resCost = zeros(1,length(p));
    resCost(1) = (norm(DatiIDCost(:)-S3*theta3Cost)^2)/N;
    resCost(2) = (norm(DatiIDCost(:)-S4*theta4Cost)^2)/N;
    resCost(3) = (norm(DatiIDCost(:)-S5*theta5Cost)^2)/N;
    resCost(4) = (norm(DatiIDCost(:)-S6*theta6Cost)^2)/N;
    resCost(5) = (norm(DatiIDCost(:)-S7*theta7Cost)^2)/N;
    resCost(6) = (norm(DatiIDCost(:)-S8*theta8Cost)^2)/N;
    resCost(7) = (norm(DatiIDCost(:)-S9*theta9Cost)^2)/N;
    resCost(8) = (norm(DatiIDCost(:)-S10*theta10Cost)^2)/N;
    resCost(9) = (norm(DatiIDCost(:)-S11*theta11Cost)^2)/N;
    % Calcolo funzioni FPE
    FPEPSNR(i+1,:) = resPSNR.*(1+p/N)./(1-p/N);
    FPECost(i+1,:) = resCost.*(1+p/N)./(1-p/N);
    [FPEPSNRMin(i+1),IPSNR] = min(FPEPSNR(i+1,:));
    [FPECostMin(i+1),ICost] = min(FPECost(i+1,:));
    pPSNR(i+1) = p(IPSNR);
    pCost(i+1) = p(ICost);
end
close(h);

orderPSNR = mode(pPSNR);
orderFC = mode(pCost);

% Istogrammi dei punti di minimo delle funzioni FPE
% figure
% subplot(2,1,1)
% hist(pPSNR,p)
% xlabel('$p_{PSNR}$','Interpreter','latex')
% ylabel('numero $p_{opt}$','Interpreter','latex')
% grid on
% title('Istogramma ordini PSNR','Interpreter','latex')
% subplot(2,1,2)
% hist(pCost,p)
% xlabel('$p_{FC}$','Interpreter','latex')
% ylabel('numero $p_{opt}$','Interpreter','latex')
% grid on
% title('Istogramma ordini FC','Interpreter','latex')