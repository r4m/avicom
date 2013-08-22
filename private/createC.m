function [C,IndexSet] = createC(Npar,VettoreEnergia,VettoreBlkDim)

% Calcolo matrice C(t) dei filtri di Kalman
% Input: dimensione matrice "Npar", vettore contenente i possibili valori
%        di energia "VettoreEnergia", vettore contenente i possibili valori
%        di blockdimension "VettoreBlkDim"
% Output: matrice C(t)
%         array contenente gli indici (lineari) per la scelta dei controlli
%         "IndexSet"

% Inizializzazione vettore che contiene i controlli per stimare poi le
% superfici FC e Q
firstControls = zeros(2,Npar);

% Campionamento casuale nella LUT dei controlli
IndexSet = randint(1,Npar,length(VettoreEnergia)*length(VettoreBlkDim))+1;

for j = 1:Npar
    [u1,u2] = ind2sub([length(VettoreBlkDim) length(VettoreEnergia)],IndexSet(j));
    firstControls(:,j) = [VettoreEnergia(u2);VettoreBlkDim(u1)]; 
end
% Scelta di C in modo che abbia rango pieno ad ogni istante t
C = [ones(Npar,1) firstControls(1,:)' firstControls(2,:)' (firstControls(1,:).*firstControls(2,:))' firstControls(1,:)'.^2 ...
     firstControls(2,:)'.^2 ((firstControls(1,:).^2).*(firstControls(2,:)))' ((firstControls(2,:).^2).*(firstControls(1,:)))'...
     ((firstControls(1,:).^2).*(firstControls(2,:).^2))' firstControls(1,:)'.^3];
while rank(C)<Npar
    IndexSet = randint(1,Npar,length(VettoreEnergia)*length(VettoreBlkDim))+1;
    for j = 1:Npar
        [u1,u2] = ind2sub([length(VettoreBlkDim) length(VettoreEnergia)],IndexSet(j));
        firstControls(:,j) = [VettoreEnergia(u2);VettoreBlkDim(u1)]; 
    end
    C = [ones(Npar,1) firstControls(1,:)' firstControls(2,:)' (firstControls(1,:).*firstControls(2,:))' firstControls(1,:)'.^2 ...
         firstControls(2,:)'.^2 ((firstControls(1,:).^2).*(firstControls(2,:)))' ((firstControls(2,:).^2).*(firstControls(1,:)))'...
         ((firstControls(1,:).^2).*(firstControls(2,:).^2))' firstControls(1,:)'.^3];
end