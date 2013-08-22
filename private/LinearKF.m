% Filtro di Kalman per modelli lineari
function [x_stima,P_stima] = LinearKF(x_stima,P_stima,y,A,C,Q,R)

% Stime a priori
x_predizione = A*x_stima;
P_predizione = A*P_stima*A' + Q;

% Stime a posteriori
Lambda = C*P_predizione*C' + R;
Lambda = inv(Lambda);
L = P_predizione*C'*Lambda;
x_stima = x_predizione + L*(y - C*x_predizione);
P_stima = P_predizione - P_predizione*C'*Lambda*C*P_predizione;
