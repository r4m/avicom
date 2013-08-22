function [f,df] = CostFunction(x,CostPar,type)
% Funzione di costo (numero di byte trasmessi) da minimizzare
% Input: controlli "x" (x(1) = controllo sull'energia,x(2) = controllo sulla dimensione dei blocchi)
%        CostPar = parametri della superficie costo interpolata, type = tipo di modello per l'interpolazione
% Output: funzione costo "f" e suo gradiente "df"
tmpf = 0;
df = 0;

if isequal(type,'quadratic') && size(CostPar,1)>=6
    tmpf = CostPar(1) + CostPar(2)*x(1) + CostPar(3)*x(2) + CostPar(4)*x(1)*x(2) + CostPar(5)*x(1)^2 + CostPar(6)*x(2)^2;
elseif isequal(type,'loglinear') && size(CostPar,1)>=4
    tmpf = CostPar(1) + CostPar(2)*log(x(1)) + CostPar(3)*log(x(2)) + CostPar(4)*log(x(1)).*log(x(2));
elseif isequal(type,'cubic') && size(CostPar,1)>=7
    tmpf = CostPar(1) + CostPar(2)*x(1) + CostPar(3)*x(2) + CostPar(4)*x(1)*x(2) + CostPar(5)*x(1)^2 + CostPar(6)*x(2)^2 + CostPar(7)*x(1)^3;
elseif isequal(type,'biquadratic') && size(CostPar,1)>=8
    tmpf = CostPar(1) + CostPar(2)*x(1) + CostPar(3)*x(2) + CostPar(4)*x(1)*x(2) + CostPar(5)*x(1)^2 + CostPar(6)*x(2)^2 + CostPar(7)*x(1)^3 + ...
        CostPar(8)*x(1)^4;
elseif isequal(type,'fpe') && size(CostPar,1)>=10
    tmpf = CostPar(1) + CostPar(2)*x(1) + CostPar(3)*x(2) + CostPar(4)*x(1)*x(2) + CostPar(5)*x(1)^2 + CostPar(6)*x(2)^2 + CostPar(7)*(x(1)^2)*x(2) + ...
        CostPar(8)*x(1)*(x(2)^2) + CostPar(9)*(x(1)^2)*(x(2)^2) + CostPar(10)*x(1)^3;
elseif size(CostPar,1)>=8
%     disp(['Warning: The dimension of cost surface parameters is ' int2str(size(CostPar,1)) '. The type of the model will be set to biquadratic.']);
    tmpf = CostPar(1) + CostPar(2)*x(1) + CostPar(3)*x(2) + CostPar(4)*x(1)*x(2) + CostPar(5)*x(1)^2 + CostPar(6)*x(2)^2 + CostPar(7)*x(1)^3 + ...
        CostPar(8)*x(1)^4;
elseif size(CostPar,1)==7
%     disp(['Warning: The dimension of cost surface parameters is ' int2str(size(CostPar,1)) '. The type of the model will be set to cubic.']);
    tmpf = CostPar(1) + CostPar(2)*x(1) + CostPar(3)*x(2) + CostPar(4)*x(1)*x(2) + CostPar(5)*x(1)^2 + CostPar(6)*x(2)^2 + CostPar(7)*x(1)^3;
elseif size(CostPar,1)==6
%     disp(['Warning: The dimension of cost surface parameters is ' int2str(size(CostPar,1)) '. The type of the model will be set to quadratic.']);
    tmpf = CostPar(1) + CostPar(2)*x(1) + CostPar(3)*x(2) + CostPar(4)*x(1)*x(2) + CostPar(5)*x(1)^2 + CostPar(6)*x(2)^2;    
elseif size(CostPar,1)==5 || size(CostPar,1)==4 
%     disp(['Warning: The dimension of cost surface parameters is ' int2str(size(CostPar,1)) '. The type of the model will be set to loglinear.']);
    tmpf = CostPar(1) + CostPar(2)*log(x(1)) + CostPar(3)*log(x(2)) + CostPar(4)*log(x(1)).*log(x(2));
elseif size(CostPar,1)<4
    error(['The dimension of cost surface parameters is ' int2str(size(CostPar,1)) '. There isn''t a suitable type of interpolation.']);
    tmpf = [];
end

f = tmpf;

if nargout>1
    if size(CostPar,1)>=10
        df = [CostPar(2) + CostPar(4)*x(2) + 2*CostPar(5)*x(1) + 2*CostPar(7)*x(1)*x(2) + CostPar(8)*x(2)^2 + 2*CostPar(9)*x(1)*x(2)^2 + 3*CostPar(10)*x(1)^2 ...
              CostPar(3) + CostPar(4)*x(1) + 2*CostPar(6)*x(2) + 2*CostPar(8)*x(1)*x(2) + CostPar(7)*x(1)^2 + 2*CostPar(9)*x(2)*x(1)^2];
    elseif size(CostPar,1)==9
        df = [CostPar(2) + CostPar(4)*x(2) + 2*CostPar(5)*x(1) + 2*CostPar(7)*x(1)*x(2) + CostPar(8)*x(2)^2 + 2*CostPar(9)*x(1)*x(2)^2 ...
              CostPar(3) + CostPar(4)*x(1) + 2*CostPar(6)*x(2) + 2*CostPar(8)*x(1)*x(2) + CostPar(7)*x(1)^2 + 2*CostPar(9)*x(2)*x(1)^2];
    elseif size(CostPar,1)==8
        df = [CostPar(2) + CostPar(4)*x(2) + 2*CostPar(5)*x(1) + 2*CostPar(7)*x(1)*x(2) + CostPar(8)*x(2)^2 ...
              CostPar(3) + CostPar(4)*x(1) + 2*CostPar(6)*x(2) + 2*CostPar(8)*x(1)*x(2) + CostPar(7)*x(1)^2];
    elseif size(CostPar,1)==7
        df = [CostPar(2) + CostPar(4)*x(2) + 2*CostPar(5)*x(1) + 2*CostPar(7)*x(1)*x(2) ...
              CostPar(3) + CostPar(4)*x(1) + 2*CostPar(6)*x(2) + CostPar(7)*x(1)^2];
    elseif size(CostPar,1)==6
        df = [CostPar(2) + CostPar(4)*x(2) + 2*CostPar(5)*x(1) ...
              CostPar(3) + CostPar(4)*x(1) + 2*CostPar(6)*x(2)];
    elseif size(CostPar,1)==5
        df = [CostPar(2) + CostPar(4)*x(2) + 2*CostPar(5)*x(1) ...
              CostPar(3) + CostPar(4)*x(1)];
    elseif size(CostPar,1)==4
        df = [CostPar(2) + CostPar(4)*x(2) ...
              CostPar(3) + CostPar(4)*x(1)];
    end
end