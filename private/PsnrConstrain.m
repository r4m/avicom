function [g,geq] = PsnrConstrain(x,PsnrPar,SogliaPSNR,type)
% Funzione di vincolo (PSNR) 
% x(1) = controllo sull'energia
% x(2) = controllo sulla dimensione dei blocchi
% type = tipo di curva fittata

g = []; geq = [];

if isequal(type,'quadratic') && size(PsnrPar,1)>=6
    g = SogliaPSNR - (PsnrPar(1) + PsnrPar(2)*x(1) + PsnrPar(3)*x(2) + PsnrPar(4)*x(1)*x(2) + PsnrPar(5)*x(1)^2 + PsnrPar(6)*x(2)^2);
elseif isequal(type,'loglinear') && size(PsnrPar,1)>=4
    g = SogliaPSNR - (PsnrPar(1) + PsnrPar(2)*log(x(1)) + PsnrPar(3)*log(x(2)) + PsnrPar(4)*log(x(1)).*log(x(2)));
elseif isequal(type,'cubic') && size(PsnrPar,1)>=7
    g = SogliaPSNR - (PsnrPar(1) + PsnrPar(2)*x(1) + PsnrPar(3)*x(2) + PsnrPar(4)*x(1)*x(2) + PsnrPar(5)*x(1)^2 + PsnrPar(6)*x(2)^2 + ...
        PsnrPar(7)*x(1)^3);
elseif isequal(type,'biquadratic') && size(PsnrPar,1)>=8
    g = SogliaPSNR - (PsnrPar(1) + PsnrPar(2)*x(1) + PsnrPar(3)*x(2) + PsnrPar(4)*x(1)*x(2) + PsnrPar(5)*x(1)^2 + PsnrPar(6)*x(2)^2 + ...
        PsnrPar(7)*x(1)^3 + PsnrPar(8)*x(1)^4);
elseif isequal(type,'fpe') && size(PsnrPar,1)>=10
    g = SogliaPSNR - (PsnrPar(1) + PsnrPar(2)*x(1) + PsnrPar(3)*x(2) + PsnrPar(4)*x(1)*x(2) + PsnrPar(5)*x(1)^2 + PsnrPar(6)*x(2)^2 + PsnrPar(7)*(x(1)^2)*x(2) + ...
        PsnrPar(8)*x(1)*(x(2)^2) + PsnrPar(9)*(x(1)^2)*(x(2)^2) + PsnrPar(10)*x(1)^3);
elseif size(PsnrPar,1)>=8
%     disp(['Warning: The dimension of psnr surface parameters is ' int2str(size(PsnrPar,1)) '. The type of the model will be set to biquadratic']);
    g = SogliaPSNR - (PsnrPar(1) + PsnrPar(2)*x(1) + PsnrPar(3)*x(2) + PsnrPar(4)*x(1)*x(2) + PsnrPar(5)*x(1)^2 + PsnrPar(6)*x(2)^2 + ...
        PsnrPar(7)*x(1)^3 + PsnrPar(8)*x(1)^4);
elseif size(PsnrPar,1)==7
%     disp(['Warning: The dimension of psnr surface parameters is ' int2str(size(PsnrPar,1)) '. The type of the model will be set to cubic']);
    g = SogliaPSNR - (PsnrPar(1) + PsnrPar(2)*x(1) + PsnrPar(3)*x(2) + PsnrPar(4)*x(1)*x(2) + PsnrPar(5)*x(1)^2 + PsnrPar(6)*x(2)^2 + ...
        PsnrPar(7)*x(1)^3);
elseif size(PsnrPar,1)==6
%     disp(['Warning: The dimension of psnr surface parameters is ' int2str(size(PsnrPar,1)) '. The type of the model will be set to quadratic']);
    g = SogliaPSNR - (PsnrPar(1) + PsnrPar(2)*x(1) + PsnrPar(3)*x(2) + PsnrPar(4)*x(1)*x(2) + PsnrPar(5)*x(1)^2 + PsnrPar(6)*x(2)^2);
elseif size(PsnrPar,1)==5 || size(PsnrPar,1)==4 
%     disp(['Warning: The dimension of psnr surface parameters is ' int2str(size(PsnrPar,1)) '. The type of the model will be set to loglinear']);
    g = SogliaPSNR - (PsnrPar(1) + PsnrPar(2)*log(x(1)) + PsnrPar(3)*log(x(2)) + PsnrPar(4)*log(x(1)).*log(x(2)));
elseif size(CostPar,1)<4
    error(['The dimension of psnr surface parameters is ' int2str(size(PsnrPar,1)) '. There isn''t a suitable type of interpolation.']);
end

