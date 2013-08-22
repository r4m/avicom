function [u,f] = optimizationRoutine(costPar,qualityPar,thresh,handles)

% routine that computes the optimal control "u" and the related function
% value "f" by trying out several starting guesses and by choosing the best
% possible solution

eMin = get(handles.energyMinSlider, 'Value');
eMax = get(handles.energyMaxSlider, 'Value');
dMin = get(handles.blkdimMinSlider, 'Value');
dMax = get(handles.blkdimMaxSlider, 'Value');

% generation of the six starting guesses
x0 = repmat([eMin;dMin],1,6) + repmat([eMax-eMin;dMax-dMin],1,6).*rand(2,6);

% initialization
u = zeros(size(x0));
f = zeros(1,size(x0,2));

% solution computation
options = optimset('TolFun',1e-10,'TolCon',1e-10,'MaxFunEvals',10000,'LargeScale','off','MaxIter',10000,'GradObj','on','Display','off');
for i = 1:size(x0,2)
    [u(:,i),f(i)] = fmincon(@(x) CostFunction(x,costPar,'fpe'),x0(:,i),[eye(2);-eye(2)],[eMax;dMax;-eMin;-dMin],[],[],[],[],...
                            @(x) PsnrConstrain(x,qualityPar,thresh,'fpe'),options);
    if PsnrConstrain(u(:,i),qualityPar,thresh,'fpe') > 0 && abs(PsnrConstrain(u(:,i),qualityPar,thresh,'fpe')) > 1e-8
        f(i) = Inf;
    end
end

% choice
[f,fIndex] = min(f);
u = u(:,fIndex);


