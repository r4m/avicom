function [fr_dec,num_pc] = SVDCompressionSimRev(frame, ENERGIApc, BLSZE)

% Simula la compressione e la decodifica col sistema semplificato che
% prevede la suddivisione della scena in blocchi di dimensione BLSZE 
% (senza classificare zone statiche e dinamiche e senza quantizzazione).
% VERSIONE OTTIMIZZATA E ADATTATA A QUALSIASI DIM NEI FRAME
%
% INPUT:
% - frame: la sequenza video
% - BLSZE: lato dei blocchetti in cui viene suddivisa la scena
% - ENERGIApc: energia richiesta a ciascun blocchetto
% RESTITUISCE:
% - comp: componenti principali
% - combinat: combinatori
% - num_pc: vettore col numero di componenti principali per ogni blocchetto
% - fr_dec: sequenza video decodificata dopo la compressione

 frame = single(frame);
 fr_dec = zeros(size(frame));
 num_pc = zeros(ceil(size(frame,2)/BLSZE)*ceil(size(frame,1)/BLSZE),1);

%% 

for nr = 1:1:ceil(size(frame,1)/BLSZE)
    for nc = 1:1:ceil(size(frame,2)/BLSZE)
        if nr == ceil(size(frame,1)/BLSZE) && nc == ceil(size(frame,2)/BLSZE)
            block = frame((nr-1)*BLSZE+1:end,(nc-1)*BLSZE+1:end, :);
        elseif nr == ceil(size(frame,1)/BLSZE) && nc ~= ceil(size(frame,2)/BLSZE)
            block = frame((nr-1)*BLSZE+1:end,(nc-1)*BLSZE+1:(nc-1)*BLSZE+BLSZE, :);
        elseif nr ~= ceil(size(frame,1)/BLSZE) && nc == ceil(size(frame,2)/BLSZE)
            block = frame((nr-1)*BLSZE+1:(nr-1)*BLSZE+BLSZE,(nc-1)*BLSZE+1:end, :);
        else
            block = frame((nr-1)*BLSZE+1:(nr-1)*BLSZE+BLSZE,(nc-1)*BLSZE+1:(nc-1)*BLSZE+BLSZE, :);
        end
        % Indicizzazione dei blocchetti
        id = sub2ind([ceil(size(frame,2)/BLSZE) ceil(size(frame,1)/BLSZE)], nc, nr);
        
        %% Vettorizzazione del blocco estratto
        O = reshape(block,size(block,1)*size(block,2),size(frame,3));
        
        %% Calcolo SVD
        [u s] = svd(O,0); % singular value decomposition
%         save  debug.mat u s O   
%         totEnergia = sum(s(:));
%         s = s(1:size(u,2),1:size(u,2));

        %% Calcolo il numero di componenti che mi garantiscono almeno ENERGIA % dell'energia totale       
        % ENERGIApc = 0.9;
        sTOT = sum(s(:));
        rapp = 0;
        sTEMP = 0;
        f = 1;
        while f < size(u,2) && rapp < ENERGIApc
              sTEMP = sTEMP + s(f,f);
              rapp = sTEMP /sTOT;
              f = f+1;
        end    
        num_pc(id) = f-1; 
%         num_pc(id) = min(find(cumsum(diag(s))/totEnergia - ENERGIApc >= 0));

        clear f rapp sTOT sTEMP

        %% Riduco dimensioni di u
        u = u(:,1:num_pc(id));
        
        %% Calcolo coefficienti di proiezione
        %a = inv(u'*u)*u'*O ;% ogni riga di a contiene i "num_pc" coeff di un frame del video, corrispondenti alle "num_pc" autoimmagini
        a = u'*O;
        
        % Decodifica
        if nr == ceil(size(frame,1)/BLSZE) && nc == ceil(size(frame,2)/BLSZE)
            fr_dec((nr-1)*BLSZE+1:end,(nc-1)*BLSZE+1:end, :) = reshape(u*a,size(block,1),size(block,2),size(frame,3));
        elseif nr == ceil(size(frame,1)/BLSZE) && nc ~= ceil(size(frame,2)/BLSZE)
            fr_dec((nr-1)*BLSZE+1:end,(nc-1)*BLSZE+1:(nc-1)*BLSZE+BLSZE, :) = reshape(u*a,size(block,1),size(block,2),size(frame,3));
        elseif nr ~= ceil(size(frame,1)/BLSZE) && nc == ceil(size(frame,2)/BLSZE)
            fr_dec((nr-1)*BLSZE+1:(nr-1)*BLSZE+BLSZE,(nc-1)*BLSZE+1:end, :) = reshape(u*a,size(block,1),size(block,2),size(frame,3));
        else
            fr_dec((nr-1)*BLSZE+1:(nr-1)*BLSZE+BLSZE,(nc-1)*BLSZE+1:(nc-1)*BLSZE+BLSZE, :) = reshape(u*a,size(block,1),size(block,2),size(frame,3));
        end
            
        clear u a s O block
    end
end
