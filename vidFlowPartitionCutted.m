function [partitions maxFramesForPackets numPackets] = vidFlowPartitionCutted(mmrobj, resVidHeight, resVidWidth)

%--------------------------------------------------------------------------
% SUDDIVISIONE DEL FLUSSO VIDEO
% A partire dalle macrosequenze video consecutive "frames(i).mat" si creano
% delle sottosequenze "subFramesGray(t).mat" al variare dell'indice temporale t
%--------------------------------------------------------------------------

if(~exist('DATA/originalFrames','dir'))
    if(~mkdir('DATA/originalFrames'));
        error('Unable to create directory DATA/originalFrames');
    end
else
   delete('DATA/originalFrames/*.mat');
end

partitions = 0;
numFrames = get(mmrobj, 'NumberOfFrames');

done = 0;
while(~done)
    prompt = {'Enter number of frames for sequence:'};
    dlg_title = 'Input for sequence frames';
    num_lines = 1;
    def = {'50'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    [maxFramesForPackets status] = str2num(char(answer));
    if(status)
        maxFramesForPackets = single(maxFramesForPackets);
        if(numFrames >= maxFramesForPackets)
            done = 1;
        else
            warndlg('The number of frames for sequence MUST be grater than total frames.','Warning');
            uiwait;
        end
    else
        warndlg('The number of frames for sequence MUST be a number.','Warning');
        uiwait;
    end
end

numPackets = floor(numFrames/maxFramesForPackets);
h = waitbar(0,'Read in all the video frames...');
for i = 0 : numPackets-1
    %waitbar(i/(numPackets-1));
    StartIndex = i*maxFramesForPackets+1;
    StopIndex = (i+1)*maxFramesForPackets;
    tmpFrames = [];
    subFramesGray = [];
    for k = StartIndex : StopIndex
        waitbar(k/(maxFramesForPackets*numPackets));
        currentFrame = read(mmrobj, k);
        tmpFrames = cat(4,tmpFrames, currentFrame);
        subFramesGray = cat(3,subFramesGray, rgb2gray(currentFrame));  
    end
    subFramesGray = imresize(subFramesGray, [resVidHeight resVidWidth]);
    eval(['frames' int2str(i) ' = tmpFrames;']);
%             save(['DATA/packet' int2str(i) '.mat'], ['frames' int2str(i)]);
%             clear(['frames' int2str(i)]);
    save(['DATA/originalFrames/framesGrayPack' int2str(i) '.mat'], 'subFramesGray');        
    clear subFramesGray;
    partitions=partitions+1;
end 
close(h);
% h = waitbar(0,'Cat all the video frames...');
% frames = [];
% for i = 0 : numPackets-1
%     waitbar(i+1/numPackets);
%     s = ['frames = cat(4, frames, frames' int2str(i) ');'];
%     eval(s);
% end
% close(h);   

% save DATA/originalVideoPartitions.mat frames partitions maxFramesForPackets numPackets

save DATA/originalVideoPartitions.mat partitions maxFramesForPackets numPackets
