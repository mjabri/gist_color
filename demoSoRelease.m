% Demo, scene recognition
%
% This script illustrates Single-Opponent color Gist features
%



%% ---------------------------------------------------------------
%                                Parameters
% -------------------------------------------------------------------------
imgDir = '/gpfs/home/tserre/work/jzhang/database/Gist/spatial_envelope_256x256_static_8outdoorcategories';
categories = {'tallbuilding','insidecity','street','highway','coast','opencountry','mountain','forest'};
imageSize = 256; 
numberBlocks = 4;
fc_prefilt = 4;
Nclasses = length(categories);

% params for Gabor filters
numPhases = 2;
numChannels = 8;
rot =  0:22.5:22.5*7;
c1ScaleSS = 1:2:8;
RF_siz    = 7:6:39;
c1SpaceSS = 8:4:20;
div = 4:-.05:3.2;
Div       = div(1:3:end);




%% ---------------------------------------------------------------
%                       Compute SO GIST features
%--------------------------------------------------------------------------
% Compute global features
scenes = dir(fullfile(imgDir, '*.jpg'));
scenes = {scenes(:).name};
Nscenes = length(scenes);
%

fprintf(1,'Initializing color gabor filters -- full set...');
%creates the gabor filters use to extract the S1 layer
[fSiz,~,cfilters,c1OL,numOrients] = init_color_gabor(rot, RF_siz, Div,numChannels,numPhases);
fprintf(1,'done\n');

Nfeatures = length(rot)*(length(c1ScaleSS)-1)*numberBlocks^2*numChannels*numPhases;



F = zeros([Nscenes Nfeatures]);
for n = 1:Nscenes
    disp([n Nscenes]);
    img = imread(fullfile(imgDir, scenes{n}));
    if size(img,1) ~= imageSize
        img = imresize(img, [imageSize imageSize], 'bilinear');
    end
    
%     output = prefilt(double(img), fc_prefilt);
   if max(img(:)) > 1
        img = double(img) / 255;
    end
    output = 2 * double(img) - 1;
    F(n,:) = computeSoGist(output,cfilters, fSiz, c1SpaceSS, ...
        c1ScaleSS,c1OL,numPhases,numChannels);
end



outDir = sprintf('../results/0920');
if ~exist(outDir,'dir')
    mkdir(outDir);
end

save(fullfile(outDir,sprintf('Fso_rectify.mat')) ,'F','-v7.3');
exit
%