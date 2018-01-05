% for iSet=1:numel(dataStructure.haukeSets)
%     dataStructure.haukeSets{iSet}.fitSet(dataStructure.center);
%     iSet
% end
% % tic;
for j=4:4
for i = 1:13
 dataStructure.getHaukeSet(i, j).fitSet( dataStructure.center)
end
end
% toc