function about(varargin)
%ABOUT About the Avicom Toolbox.
%   ABOUT displays the version number of the Avicom Toolbox
%  and the copyright notice in a modal dialog box.
 
tlbxName = 'Avicom';
tlbxVersion = '1.0 beta';
str = sprintf('%s %s\nCopyright 2009 DEI, Unipd.\nDeveloped by Filippo Zanella.', ...
              tlbxName, tlbxVersion);
msgbox(str,tlbxName,'help','modal');

