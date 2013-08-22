function [realQ,realFC,QparEstimate,VarQ,FCparEstimate,VarFC,optContr,DecodedFrame,Components] = globalSystemPSNR(frame,orderPSNR,orderFC,QparEstimate,VarQ,FCparEstimate,VarFC,QHSV,RHSV,Qcost,Rcost,sigmaQ,E,L,VettoreEnergia,VettoreBlkDim,handles)

% Simulazione del sistema globale sviluppato usando come indice PSNR
% Input: sequenza di frame "frame"
%        numero di parametri per le superfici FC e Q "Npar"
%        stime parametri superficie Q al passo precedente "QparEstimate"
%        varianza d'errore di stima dei parametri Q del filtro di Kalman al passo
%        precedente "VarQ"
%        stime parametri superficie FC al passo precedente "FCparEstimate"
%        varianza d'errore di stima dei parametri FC del filtro di Kalman al passo
%        precedente "VarFC"
%        varianza del rumore di modello per la stima Q "QHSV"
%        varianza del rumore di misura per la stima Q "RHSV"
%        varianza del rumore di modello per la stima FC "Qcost"
%        varianza del rumore di misura per la stima FC "Rcost"
%        soglia di qualità "sigmaQ" 
%        [E,L] = meshgrid(VettoreEnergia,VettoreBlkDim)
% Output:qualità Q della compressione finale "realQ"
%        qualità FC della compressione finale "realFC"
%        stime parametri superficie Q al passo corrente "QparEstimate"
%        varianza d'errore di stima dei parametri Q del filtro di Kalman al passo
%        corrente "VarQ"
%        stime parametri superficie FC al passo corrente "FCparEstimate"
%        varianza d'errore di stima dei parametri FC del filtro di Kalman al passo
%        corrente "VarFC"
%        controlli ottimi "optContr"

% Dimensionamento
[n1,n2,n3] = size(frame);

% Campionamento casuale e calcolo matrici A e C del filtro di Kalman

[C1,randContr1] = createCRev(orderPSNR,VettoreEnergia,VettoreBlkDim);
A1 = eye(orderPSNR);
% Simulazioni per la stima delle superfici
yQ = zeros(orderPSNR,1);
for i = 1:orderPSNR
    [DecodedFrame Components] = SVDCompressionSimRev(frame, randContr1(1,i), round(randContr1(2,i)));
    yQ(i) = compute_psnr(frame, DecodedFrame);
    clear DecodedFrame
end

[C2,randContr2] = createCRev(orderFC,VettoreEnergia,VettoreBlkDim);
A2 = eye(orderFC);
% Simulazioni per la stima delle superfici
yFC = zeros(orderFC,1);
for i = 1:orderFC
    [DecodedFrame Components] = SVDCompressionSimRev(frame, randContr2(1,i), round(randContr2(2,i)));
    yFC(i) = sum((4*round(randContr2(2,i))^2+4*n3)*Components)/(n1*n2*n3);
    clear DecodedFrame
end


% Stime parametri superfici
[QparEstimate VarQ] = LinearKF(QparEstimate,VarQ,yQ,A1,C1,QHSV,RHSV);
[FCparEstimate VarFC] = LinearKF(FCparEstimate,VarFC,yFC,A2,C2,Qcost,Rcost);

% % Calcolo controlli ottimi
% [QparEstimateNorm,m,q] = normalizeQ(QparEstimate,E,L);
% optContr = optimizationRoutine(FCparEstimate,QparEstimateNorm,sigmaQ, handles);
% 
% % Simulazione della compressione SVD con i controlli ottimi
% [DecodedFrame Components] = SVDCompressionSimRev(frame, optContr(1), round(optContr(2)));
% realQ = (compute_psnr(frame, DecodedFrame)-q)/m;
% realFC = sum((4*round(optContr(2))^2+4*n3)*Components)/(n1*n2*n3);

% Calcolo controlli ottimi
optContr = optimizationRoutine(FCparEstimate,QparEstimate,sigmaQ, handles);

% Simulazione della compressione SVD con i controlli ottimi
[DecodedFrame Components] = SVDCompressionSimRev(frame, optContr(1), round(optContr(2)));
realQ = compute_psnr(frame, DecodedFrame);
realFC = sum((4*round(optContr(2))^2+4*n3)*Components)/(n1*n2*n3);