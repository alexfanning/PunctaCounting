function bndry1 = roiBuilder(bndry1,bndry2,bndry3,bndry4)

bndry1(end+1:end+length(bndry1),1) = flip(bndry2);
bndry1(length(bndry2)+1:end,2) = flip(bndry3);

nanLocs = find(isnan(bndry1));
bndry1(isnan(bndry1)) = [];
bndry1 = reshape(bndry1,2*length(bndry4)-length(nanLocs)/2,2);