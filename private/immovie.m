function mov = immovie(varargin)
%IMMOVIE Make movie from multiframe image.
%   MOV = IMMOVIE(X,MAP) returns an array of movie frame structures MOV
%   containing the images in the multiframe indexed image X with the
%   colormap MAP. X is an M-by-N-by-1-by-K array, where K is the number of
%   images. All the images in X must have the same size and must use the
%   same colormap MAP.  
%
%   IMMOVIE displays a preview of the movie as it creates it. To play the 
%   movie, call the MATLAB MOVIE function.
%
%   MOV = IMMOVIE(RGB) returns an array of movie frame structures MOV from
%   the images in the multiframe truecolor image RGB. RGB is an
%   M-by-N-by-3-by-K array, where K is the number of images. All the images
%   in RGB must have the same size.
%
%   Class Support
%   -------------
%   An indexed image can be uint8, uint16, single, double, or logical. A
%   truecolor image can be uint8, uint16, single, or double. MOV is a
%   MATLAB movie frame. For details about the movie frame structure,
%   see the reference page for GETFRAME. 
%
%   Example
%   -------
%        load mri
%        mov = immovie(D,map);
%        movie(mov,3)
%
%   Remark
%   ------
%   You can also make movies from images by using the MATLAB function
%   AVIFILE, which creates AVI files.  In addition, you can convert an
%   existing MATLAB movie into an AVI file by using the MOVIE2AVI
%   function.
%
%   See also AVIFILE, GETFRAME, MONTAGE, MOVIE, MOVIE2AVI, IMPLAY.

%   Copyright 1993-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2007/06/04 21:10:59 $

[X,map] = parse_inputs(varargin{:});

numframes = size(X,4);
mov = repmat(struct('cdata',[],'colormap',[]),[1 numframes]);

isIndexed = size(X,3) == 1;

% showing each movie frame even though we are not using this data because
% users are used to seeing their movies being displayed (albeit quickly)
% when the movie object is created
%figure(gcf);
%set(gcf,'doublebuffer','on');

for k = 1 : numframes
  %imshow(X(:,:,:,k),map);
  if isIndexed
      mov(k).cdata = iptgate('ind2rgb8',X(:,:,:,k),map);
  else
      mov(k).cdata = X(:,:,:,k);      
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Function: parse_inputs
%

function [X,map] = parse_inputs(varargin)
% Outputs: X    multiframe indexed or RGB image
%          map  colormap (:,3)

iptchecknargin(1, 2, nargin,mfilename);

switch nargin
case 1                      % immovie(RGB)
    X = varargin{1};
    map = [];
case 2                      % immovie(X,map)
    X = varargin{1};
    map = varargin{2};
    % immovie(D,size) OBSOLETE
    if (isequal(size(map), [1 3]) && (prod(map) == numel(X)))
        wid = sprintf('Images:%s:obsoleteSyntax',mfilename);
        msg = ['IMMOVIE(D,size) is an obsolete syntax. Using current colormap. ',...
                 'For different colormap use IMMOVIE(X,map).'];
        warning(wid, '%s',msg);
        X = reshape(X,[map(1) map(2) 1 map(3)]);
        map = colormap;
    end
end

% Check parameter validity 

if isempty(map) %RGB image
  iptcheckinput(X, {'uint8','uint16','single','double'},{},'RGB', mfilename, 1);
  if size(X,3)~=3
    msgId = sprintf('Images:%s:invalidTruecolorImage', mfilename);
    msg = 'Truecolor RGB image has to be an M-by-N-by-3-by-K array.';
    error(msgId,'%s',msg);
  end
  if ~isa(X,'uint8')
    X = im2uint8(X);
  end

else % indexed image
    iptcheckinput(X, {'uint8','uint16','double','single','logical'},{},'X', ...
                  mfilename, 1);
    if size(X,3)~=1
        msgId = sprintf('Images:%s:invalidIndexedImage', mfilename);
        msg = 'Indexed image has to be an M-by-N-by-1-by-K array.';
        error(msgId,'%s',msg);
    end
    if (~isreal(map) || any(map(:) > 1) || any(map(:) < 0) || ...
                ~isequal(size(map,2), 3) || size(map,1) < 2)
        msgId = sprintf('Images:%s:invalidColormap', mfilename);
        msg1 = 'MAP has to be a 2D array with at least 2 rows and ';
        msg2 = 'exactly 3 columns with array values between 0 and 1.';
        error(msgId,'%s\n%s',msg1,msg2);
    end
    if ~isa(X,'uint8')
      X = im2uint8(X,'indexed');
    end
end
