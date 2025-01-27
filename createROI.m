function [dataOut] = createROI(xLine1,xLine2)

leftLine = linspace(xLine1(1,1),xLine2(1,1),1000);
leftLine(2,:) = linspace(xLine1(1,2),xLine2(1,2),1000);

rightLine = linspace(xLine1(end,1),xLine2(end,1),1000);
rightLine(2,:) = linspace(xLine1(end,2),xLine2(end,2),1000);

dataOut = {xLine1, leftLine',xLine2,rightLine'};