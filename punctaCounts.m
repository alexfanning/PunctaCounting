%   Counts puncta within ROI
%
%   Written by Alex Fanning, 12/08/23
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function[output,goodPuncta,circDist] = punctaCounts(circs,roiArray)

% Order of ROI array is top, left, bottom, right of ROI
output = 0; a = 1;
for i = 1:length(circs)
    num2find(1) = circs(i,1);
    num2find(2) = circs(i,2);

    [~, idx(1)] = min(abs(roiArray{1}(:,1) - num2find(1)));
    nearVal(1) = roiArray{1}(idx(1),2);
    [~, idx(2)] = min(abs(roiArray{3}(:,1) - num2find(1)));
    nearVal(2) = roiArray{3}(idx(2),2);
    
    if nearVal(1) == roiArray{1}(1,1) || nearVal(2) == roiArray{3}(1,1) || nearVal(1) == roiArray{1}(end,1) || nearVal(1) == roiArray{3}(end,1)
        continue
    else

        if num2find(2) >= nearVal(1) && num2find(2) <= nearVal(2)

            [~, idx(3)] = min(abs(roiArray{2}(:,2) - num2find(2)));
            nearVal(3) = roiArray{2}(idx(3),1);
            [~, idx(4)] = min(abs(roiArray{4}(:,2) - num2find(2)));
            nearVal(4) = roiArray{4}(idx(4),1);

            %if nearVal(3) == roiArray{2}(1,2) || nearVal(4) == roiArray{4}(1,2) || nearVal(3) == roiArray{2}(end,2) || nearVal(1) == roiArray{4}(end,2)
                %continue
            %else

                if num2find(1) >= nearVal(3) && num2find(1) <= nearVal(4)
                    output = output + 1;
                    goodPuncta(a,:) = circs(i,:);
                    circDist(a,1) = nearVal(2) - num2find(2);
                    a = a + 1;
                end
            %end
        end
    end
end
