function [Qpar,m,q] = normalizeQ(par,E,L)

% normalizza i valori di una superficie da 0 a 1, restituendo i parametri
% corrispondenti
% Input: parametri superficie "par", [E,L] = meshgrid(VettoreEnergia,VettoreBlkDim)
% Output: parametri superficie normalizzata "Qpar", Q_nonNorm = m*Q_Norm+q

Qpar = zeros(size(par));

switch size(par,1)
    case 3
        Qestimate = par(1) + par(2)*E + par(3)*L;
    case 4
        Qestimate = par(1) + par(2)*E + par(3)*L + par(4)*E.*L;
    case 5
        Qestimate = par(1) + par(2)*E + par(3)*L + par(4)*E.*L + par(5)*E.^2;
    case 6
        Qestimate = par(1) + par(2)*E + par(3)*L + par(4)*E.*L + par(5)*E.^2 + par(6)*L.^2;
    case 7
        Qestimate = par(1) + par(2)*E + par(3)*L + par(4)*E.*L + par(5)*E.^2 + par(6)*L.^2 + par(7)*(E.^2).*L;
    case 8
        Qestimate = par(1) + par(2)*E + par(3)*L + par(4)*E.*L + par(5)*E.^2 + par(6)*L.^2 + par(7)*(E.^2).*L + par(8)*E.*(L.^2);
    case 9
        Qestimate = par(1) + par(2)*E + par(3)*L + par(4)*E.*L + par(5)*E.^2 + ...
            par(6)*L.^2 + par(7)*(E.^2).*L + par(8)*E.*(L.^2) + par(9)*(E.^2).*(L.^2);
    case 10
        Qestimate = par(1) + par(2)*E + par(3)*L + par(4)*E.*L + par(5)*E.^2 + ...
            par(6)*L.^2 + par(7)*(E.^2).*L + par(8)*E.*(L.^2) + par(9)*(E.^2).*(L.^2) + ...
            par(10)*E.^3;
    case 11
        Qestimate = par(1) + par(2)*E + par(3)*L + par(4)*E.*L + par(5)*E.^2 + ...
            par(6)*L.^2 + par(7)*(E.^2).*L + par(8)*E.*(L.^2) + par(9)*(E.^2).*(L.^2) + ...
            par(10)*E.^3 + par(10)*L.^3;
    otherwise
        Qestimate = [];
        error('PSNR optimum order not in list');
end

q = min(Qestimate(:));
m = max(Qestimate(:)) - q;
Qpar(1) = (par(1)-q)/m;
Qpar(2:end) = par(2:end)/m;
