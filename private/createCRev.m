function [C,firstControls] = createCRev(Npar,VettoreEnergia,VettoreBlkDim)

% Calcolo matrice C(t) dei filtri di Kalman
% Input: dimensione matrice "Npar", vettore contenente i possibili valori
%        di energia "VettoreEnergia", vettore contenente i possibili valori
%        di blockdimension "VettoreBlkDim"
% Output: matrice C(t)
%         array contenente i controlli per costruire C "firstControls"

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
switch Npar
    case 3
        C = [ones(Npar,1) firstControls(1,:)' firstControls(2,:)'];
    case 4
        C = [ones(Npar,1) firstControls(1,:)' firstControls(2,:)' (firstControls(1,:).*firstControls(2,:))'];
    case 5
        C = [ones(Npar,1) firstControls(1,:)' firstControls(2,:)' (firstControls(1,:).*firstControls(2,:))' firstControls(1,:)'.^2];
    case 6
        C = [ones(Npar,1) firstControls(1,:)' firstControls(2,:)' (firstControls(1,:).*firstControls(2,:))' firstControls(1,:)'.^2 ...
     firstControls(2,:)'.^2];
    case 7
        C = [ones(Npar,1) firstControls(1,:)' firstControls(2,:)' (firstControls(1,:).*firstControls(2,:))' firstControls(1,:)'.^2 ...
     firstControls(2,:)'.^2 ((firstControls(1,:).^2).*(firstControls(2,:)))'];
    case 8
        C = [ones(Npar,1) firstControls(1,:)' firstControls(2,:)' (firstControls(1,:).*firstControls(2,:))' firstControls(1,:)'.^2 ...
     firstControls(2,:)'.^2 ((firstControls(1,:).^2).*(firstControls(2,:)))' ((firstControls(2,:).^2).*(firstControls(1,:)))'];
    case 9
        C = [ones(Npar,1) firstControls(1,:)' firstControls(2,:)' (firstControls(1,:).*firstControls(2,:))' firstControls(1,:)'.^2 ...
     firstControls(2,:)'.^2 ((firstControls(1,:).^2).*(firstControls(2,:)))' ((firstControls(2,:).^2).*(firstControls(1,:)))'...
     ((firstControls(1,:).^2).*(firstControls(2,:).^2))'];
    case 10
        C = [ones(Npar,1) firstControls(1,:)' firstControls(2,:)' (firstControls(1,:).*firstControls(2,:))' firstControls(1,:)'.^2 ...
     firstControls(2,:)'.^2 ((firstControls(1,:).^2).*(firstControls(2,:)))' ((firstControls(2,:).^2).*(firstControls(1,:)))'...
     ((firstControls(1,:).^2).*(firstControls(2,:).^2))' firstControls(1,:)'.^3];
    case 11
        C = [ones(Npar,1) firstControls(1,:)' firstControls(2,:)' (firstControls(1,:).*firstControls(2,:))' firstControls(1,:)'.^2 ...
     firstControls(2,:)'.^2 ((firstControls(1,:).^2).*(firstControls(2,:)))' ((firstControls(2,:).^2).*(firstControls(1,:)))'...
     ((firstControls(1,:).^2).*(firstControls(2,:).^2))' firstControls(1,:)'.^3 firstControls(2,:)'.^3];
    otherwise
        error('PSNR optimum order not in list');
end

i = 0;
max_loop_time = 1e8;
while rank(C)<Npar && i <max_loop_time
    IndexSet = randint(1,Npar,length(VettoreEnergia)*length(VettoreBlkDim))+1;
    for j = 1:Npar
        [u1,u2] = ind2sub([length(VettoreBlkDim) length(VettoreEnergia)],IndexSet(j));
        firstControls(:,j) = [VettoreEnergia(u2);VettoreBlkDim(u1)]; 
    end
    
    switch Npar
        case 3
            C = [ones(Npar,1) firstControls(1,:)' firstControls(2,:)'];
        case 4
            C = [ones(Npar,1) firstControls(1,:)' firstControls(2,:)' (firstControls(1,:).*firstControls(2,:))'];
        case 5
            C = [ones(Npar,1) firstControls(1,:)' firstControls(2,:)' (firstControls(1,:).*firstControls(2,:))' firstControls(1,:)'.^2];
        case 6
            C = [ones(Npar,1) firstControls(1,:)' firstControls(2,:)' (firstControls(1,:).*firstControls(2,:))' firstControls(1,:)'.^2 ...
         firstControls(2,:)'.^2];
        case 7
            C = [ones(Npar,1) firstControls(1,:)' firstControls(2,:)' (firstControls(1,:).*firstControls(2,:))' firstControls(1,:)'.^2 ...
         firstControls(2,:)'.^2 ((firstControls(1,:).^2).*(firstControls(2,:)))'];
        case 8
            C = [ones(Npar,1) firstControls(1,:)' firstControls(2,:)' (firstControls(1,:).*firstControls(2,:))' firstControls(1,:)'.^2 ...
         firstControls(2,:)'.^2 ((firstControls(1,:).^2).*(firstControls(2,:)))' ((firstControls(2,:).^2).*(firstControls(1,:)))'];
        case 9
            C = [ones(Npar,1) firstControls(1,:)' firstControls(2,:)' (firstControls(1,:).*firstControls(2,:))' firstControls(1,:)'.^2 ...
         firstControls(2,:)'.^2 ((firstControls(1,:).^2).*(firstControls(2,:)))' ((firstControls(2,:).^2).*(firstControls(1,:)))'...
         ((firstControls(1,:).^2).*(firstControls(2,:).^2))'];
        case 10
            C = [ones(Npar,1) firstControls(1,:)' firstControls(2,:)' (firstControls(1,:).*firstControls(2,:))' firstControls(1,:)'.^2 ...
         firstControls(2,:)'.^2 ((firstControls(1,:).^2).*(firstControls(2,:)))' ((firstControls(2,:).^2).*(firstControls(1,:)))'...
         ((firstControls(1,:).^2).*(firstControls(2,:).^2))' firstControls(1,:)'.^3];
        case 11
            C = [ones(Npar,1) firstControls(1,:)' firstControls(2,:)' (firstControls(1,:).*firstControls(2,:))' firstControls(1,:)'.^2 ...
         firstControls(2,:)'.^2 ((firstControls(1,:).^2).*(firstControls(2,:)))' ((firstControls(2,:).^2).*(firstControls(1,:)))'...
         ((firstControls(1,:).^2).*(firstControls(2,:).^2))' firstControls(1,:)'.^3 firstControls(2,:)'.^3];
        otherwise
            error('PSNR optimum order not in list');
    end
    
    i=i+1;
end