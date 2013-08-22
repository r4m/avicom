function psnr = compute_psnr(frame, fr_dec)

% Calcolo dell'indice di qualità PSNR (si veda la presentazione finale)
% Input: la sequenza di frame originali "frame", quella compressa "fr_dec"
% Output: indice

mse = sum(reshape((single(frame) - fr_dec).^2,1,size(frame,1)*size(frame,2)*size(frame,3),1))/(size(frame,1)*size(frame,2)*size(frame,3));

psnr = 20*log10(255/sqrt(mse));