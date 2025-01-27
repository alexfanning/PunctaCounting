% Visualizing climbing fiber innervation of distal parallel fiber territory
% 
% Calculates the % of VGluT2 in the outer 20% of the molecular layer
%
%   Alex Fanning, 10/11/2022
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; close all

% Import max intensity image
params = struct(); img = {};
params.file = uigetfile('*.tif');
img{1} = imread(params.file);

% Increase contrast
img{2} = imadjust(img{1});
imshow(img{2})

% Rotate image
prompt = "Rotate image or change contrast? (y/n): ";
rotateBinary = inputdlg(prompt,"s");
rotateBinary = rotateBinary{1}(1);
while rotateBinary == 'y'
    close all
    dlgtitle = 'Rotate image, modify contrast';
    heading = {'Degrees to rotate (negative is clockwise): ','Contrast low: ','Contrast high: '};
    defaults = {'0'; '0';'1'};
    params.values = str2double(inputdlg(heading, dlgtitle, 1, defaults));
    params.rotate = params.values(1);
    params.contrast = [params.values(2) params.values(3)];
    img{2} = imadjust(img{1},params.contrast);
    img{2} = imrotate(img{2},params.rotate);
    imshow(img{2})
    rotateBinary = inputdlg(prompt,"s");
    rotateBinary = rotateBinary{1}(1);
end
clear dlgtitle heading prompt rotateBinary

%% Draw boundaries

% Draw pial surface boundary
bndry = {}; bndryMag = {};
[bndry{1}(:,1), bndry{1}(:,2), bndryMag{1}] = improfile;
hold on
plot(bndry{1}(:,1),bndry{1}(:,2),'LineWidth',2)

% Draw PC layer boundary
[bndry{4}(:,1), bndry{4}(:,2), bndryMag{2}] = improfile;
plot(bndry{4}(:,1),bndry{4}(:,2), 'LineWidth', 2)

% Eliminate difference between boundary lengths
params.bndryDiff = length(bndry{1}(:,1)) - length(bndry{4}(:,1));

if params.bndryDiff > 0
    temp(:,1) = upsamp(bndry{4}(:,1),bndry{1}(:,1))';
    temp(:,2) = upsamp(bndry{4}(:,2),bndry{1}(:,2))';
    bndry{4} = temp;
else
    temp(:,1) = upsamp(bndry{1}(:,1),bndry{4}(:,1))';
    temp(:,2) = upsamp(bndry{1}(:,2),bndry{4}(:,2))';
    bndry{1} = temp;
end

% Compute upper 20% boundary of molecular layer
mlDist(:,1) = bndry{4}(:,1) - bndry{1}(:,1);
mlDist(:,2) = bndry{4}(:,2) - bndry{1}(:,2);
mMLdist = mean(mlDist(:,2)) / 3.0843;

bndry{2}(:,2) = bndry{1}(:,2) + .2 * mlDist(:,2);
bndry{2}(:,1) = bndry{1}(:,1) + .2 * mlDist(:,1);

plot(bndry{2}(:,1),bndry{2}(:,2),'LineWidth',2)

% Computer upper and lower 50% boundary of ML
bndry{3}(:,1) = bndry{1}(:,1) + .5 * mlDist(:,1);
bndry{3}(:,2) = bndry{1}(:,2) + .5 * mlDist(:,2);

plot(bndry{3}(:,1),bndry{3}(:,2),'LineWidth',2)

%% Draw ROIs

% Create upper 20% ROI
surface = roiBuilder(bndry{1},bndry{2}(:,1),bndry{2}(:,2),bndry{1}(:,1));
%upper20roi = drawpolygon('Position',surface);

% Create lower 80% ROI
lower = roiBuilder(bndry{2},bndry{4}(:,1),bndry{4}(:,2),bndry{2}(:,1));
%lower80roi = drawpolygon('Position',lower);

% Create upper 50% ROI
upHalf = roiBuilder(bndry{1},bndry{3}(:,1),bndry{3}(:,2),bndry{1}(:,1));
%upper50roi = drawpolygon('Position',upHalf);

% Create lower 50% ROI
lowerHalf = roiBuilder(bndry{3},bndry{4}(:,1),bndry{4}(:,2),bndry{3}(:,1));
%lowerHalf80roi = drawpolygon('Position',lowerHalf);

% Create entire molecular layer ROI
wholeML = roiBuilder(bndry{1},bndry{4}(:,1),bndry{4}(:,2),bndry{1}(:,1));
%wholeMLroi = drawpolygon('Position',wholeML);

%% Identify puncta

prompt = "Good puncta identification? (y/n): "  ;
punctaID = 'n';

while punctaID == 'n'

    % Extract diameter of typical puncta
    punctaSize = drawline;
    pos = punctaSize.Position;
    diffPos = diff(pos);
    params.diameter = hypot(diffPos(1),diffPos(2))

    % Parameters used for identifying puncta
    paramInput = xlsread('punctaParams.xlsx');
    params.thresh = paramInput(1);
    params.edgeThresh = paramInput(3);
    params.radiiLowThresh = paramInput(5);
    params.radiiHighThresh = paramInput(6);
    
    % Identify puncta that meet criteria
    [centers,radii,intensity] = imfindcircles(img{2},[params.radiiLowThresh params.radiiHighThresh],"Sensitivity",params.thresh, "EdgeThreshold",params.edgeThresh);
    
    % Visualize puncta
    showPuncta = viscircles(centers,radii);

    % Check if puncta identification looks good
    punctaID = input(prompt,"s");

    if punctaID == 'n'
        close all

        imshow(img{2})
        hold on
        plot(bndry{2}(:,1),bndry{2}(:,2),'LineWidth',2)
        plot(bndry{3}(:,1),bndry{3}(:,2),'LineWidth',2)
    end

end

wholeMLroi = drawpolygon('Position',wholeML);

saveas(1,[params.file '.fig'])
clear pos diffPos paramInput showPuncta punctaID

%% Create ROI arrays for puncta analysis

[roiUp20] = createROI(bndry{1},bndry{2});
[roiLower80] = createROI(bndry{2},bndry{4});
[roiUp50] = createROI(bndry{1},bndry{3});
[roiLower50] = createROI(bndry{3},bndry{4});
[wholeROI] = createROI(bndry{1},bndry{4});

%% Count puncta in ROIs

[mlCounts(1),goodCircs{1},~] = punctaCounts(centers,roiUp20);
[mlCounts(2),goodCircs{2},~] = punctaCounts(centers,roiLower80);
[mlCounts(3),goodCircs{3},~] = punctaCounts(centers,roiUp50);
[mlCounts(4),goodCircs{4},~] = punctaCounts(centers,roiLower50);
[mlCounts(5),goodCircs{5},punctaDist] = punctaCounts(centers,wholeROI);

punctaDistPct = ((prctile(punctaDist,95) / 3.0843) / mMLdist) * 100;
mlDistActual(:,2) = bndry{1}(:,2) + (1 - punctaDistPct/100) * mlDist(:,2);
mlDistActual(:,1) = bndry{1}(:,1) + (1- punctaDistPct/100) * mlDist(:,1);

plot(mlDistActual(:,1),mlDistActual(:,2),'LineWidth',4)

%% Export counts to excel

up20pct = mlCounts(1) / mlCounts(5) * 100;
low80pct = mlCounts(2) / mlCounts(5) * 100;

up50pct = mlCounts(3) / mlCounts(5) * 100;
low50pct = mlCounts(4) / mlCounts(5) * 100;

polyin20 = polyshape(surface);
up20roiArea = area(polyin20);

polyin80 = polyshape(lower);
low80roiArea = area(polyin80);

polyinUp50 = polyshape(upHalf);
up50roiArea = area(polyinUp50);

polyinLow50 = polyshape(lowerHalf);
low50roiArea = area(polyinLow50);

polyin = polyshape(wholeML);
wholeMLroiArea = area(polyin);

up20ct = size(goodCircs{1},1) / up20roiArea * 100;
low80ct = size(goodCircs{2},1) / low80roiArea * 100;
up50ct = size(goodCircs{3},1) / up50roiArea * 100;
low50ct = size(goodCircs{4},1) / low50roiArea * 100;
wholeMLct = size(goodCircs{5},1) / wholeMLroiArea * 100;

excelDoc = [params.file '_counts.xlsx'];
dataExport = table(up20pct,low80pct,up50pct,low50pct,mMLdist,punctaDistPct);
data2exportRow2 = table(up20ct,low80ct,up50ct,low50ct,wholeMLct);
writetable(dataExport,excelDoc,'Sheet',1)
writetable(data2exportRow2,excelDoc,'Sheet',1,'Range','A4')

filename = [params.file '.mat'];
save(filename)
