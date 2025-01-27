%   Puncta analysis
% 
%   Takes in image of human cerebellum and identifies cells or puncta
%
%   Alex Fanning, 4/14/23
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; close all

% Import max intensity image
file = uigetfile('*.tif');
rawImg = imread(file);

% Increase contrast
grayImage = rgb2gray(rawImg);
imgAdj = imadjust(grayImage);

tiledlayout(1,2)
ax1 = nexttile;
imshow(imgAdj)

% % Rotate image
% prompt = "Rotate image? (y/n): "  ;
% rotateBinary = inputdlg(prompt,"s");
% rotateBinary = rotateBinary{1}(1);
% while rotateBinary == 'y'
%     close all
%     dlgtitle = 'Rotate image';
%     heading = 'Degrees to rotate (negative is clockwise)';
%     rotate = inputdlg(heading, dlgtitle);
%     imgAdj = imrotate(imgAdj,str2double(rotate{1}));
%     imshow(imgAdj)
%     rotateBinary = inputdlg(prompt,"s");
%     rotateBinary = rotateBinary{1}(1);
% end

%% Draw boundaries

% % Draw pial surface boundary
% [surfX, surfY, surf] = improfile;
% hold on
% plot(surfX,surfY,'LineWidth',2)
% 
% % Draw PC layer boundary
% [pcX, pcY, pc] = improfile;
% plot(pcX,pcY, 'LineWidth', 2)
% 
% % Eliminate difference between boundary lengths
% bndryDiff = length(surfX) - length(pcX);
% 
% if bndryDiff > 0
%     pcX = upsamp(pcX,surfX)';
%     pcY = upsamp(pcY,surfY)';
% else
%     surfX = upsamp(surfX,pcX)';
%     surfY = upsamp(surfY,pcY)';
% end
% 
% % Compute upper 20% boundary of molecular layer 
% mlDist = pcY - surfY;
% mlDistX = pcX - surfX;
% 
% ml20pct = .2 * mlDist;
% ml20pctX = .2 * mlDistX;
% 
% upperMLbndry = surfY + ml20pct;
% upperMLbndryX = surfX + ml20pctX;
% 
% plot(upperMLbndryX,upperMLbndry,'LineWidth',2)
% 
% % Computer upper and lower 50% boundary of ML
% ml50pct = .5 * mlDist;
% ml50pctX = .5 * mlDistX;
% 
% halfMLbndry = surfY + ml50pct;
% halfMLbndryX = surfX + ml50pctX;
% 
% plot(halfMLbndryX,halfMLbndry,'LineWidth',2)

%% Draw ROIs

% % Create upper 20% ROI
% surface = [surfX surfY];
% surface = roiBuilder(surface,upperMLbndryX,upperMLbndry,surfX);
% upper20roi = drawpolygon('Position',surface);
% 
% % Create lower 80% ROI
% lower = [upperMLbndryX upperMLbndry];
% lower = roiBuilder(lower,pcX,pcY,upperMLbndryX);
% lower80roi = drawpolygon('Position',lower);
% 
% % Create upper 50% ROI
% upHalf = [surfX surfY];
% upHalf  = roiBuilder(upHalf,halfMLbndryX,halfMLbndry,surfX);
% %upper50roi = drawpolygon('Position',upHalf);
% 
% % Create lower 50% ROI
% lowerHalf = [halfMLbndryX halfMLbndry];
% lowerHalf = roiBuilder(lowerHalf,pcX,pcY,halfMLbndryX);
% %lowerHalf80roi = drawpolygon('Position',lowerHalf);
% 
% % Create entire molecular layer ROI
% wholeML = [surfX surfY];
% wholeML = roiBuilder(wholeML,pcX,pcY,surfX);
% %wholeMLroi = drawpolygon('Position',wholeML);

%% Identify puncta

prompt = "Good puncta identification? (y/n): "  ;
punctaID = 'n';

while punctaID == 'n'

    % Extract diameter of typical puncta
    punctaSize = drawline;
    pos = punctaSize.Position;
    diffPos = diff(pos);
    diameter = hypot(diffPos(1),diffPos(2))

    % Parameters used for identifying puncta
    paramInput = xlsread('punctaParams.xlsx');
    thresh = paramInput(1);
    edgeThresh = paramInput(3);
    radiiLowThresh = paramInput(5);
    radiiHighThresh = paramInput(6);
    
    % Identify puncta that meet criteria
    [centers,radii,intensity] = imfindcircles(imgAdj,[radiiLowThresh radiiHighThresh],"Sensitivity",thresh, "EdgeThreshold",edgeThresh,"ObjectPolarity","Bright");
    
    % Visualize puncta
    showPuncta = viscircles(centers,radii);

    ax2 = nexttile;
    imshow(imgAdj)
    linkaxes([ax1 ax2], 'xy')

    % Check if puncta identification looks good
    punctaID = input(prompt,"s");

    if punctaID == 'n'
        close all

        tiledlayout(1,2)
        ax1 = nexttile;
        imshow(imgAdj)
    end

end

saveas(1,[file '.fig'])

%% Count puncta in each ROI

% Count puncta in upper 20% ROI
% upMLcount = punctaCounter(centers,surfX,upperMLbndry,surfY);
% 
% % Count puncta in lower 80% ROI
% lowMLcount = punctaCounter(centers,pcX,pcY,upperMLbndry);
% 
% % Count puncta in upper 50% ROI
% upHalfCount = punctaCounter(centers,surfX,halfMLbndry,surfY);
% 
% % Count puncta in lower 50% ROI
% lowerHalfCount = punctaCounter(centers,pcX,pcY,halfMLbndry);
% 
% % Count puncta in entire molecular layer ROI
% wholeMLcount = punctaCounter(centers,pcX,pcY,surfY);
% 
% %% Export counts to excel
% 
% up20pct = upMLcount / wholeMLcount * 100;
% low80pct = lowMLcount/wholeMLcount * 100;
% 
% up50pct = upHalfCount / wholeMLcount * 100;
% low50pct = lowerHalfCount / wholeMLcount * 100;
% 
% excelDoc = [file '_counts.xlsx'];
% dataExport = table(up20pct,low80pct,up50pct,low50pct);
% writetable(dataExport,excelDoc,'Sheet',1)
% 
% filename = [file '.mat'];
% save(filename)
