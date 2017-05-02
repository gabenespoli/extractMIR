function featureFormat = getfeatureformat(feature)
featureName = parseFeature(feature);
featureFormat = '%16.12f';
stringFeatures = {...
    'filename',...
    'dateExtracted',...
    'filetype',...
    'artist',...
    'album',...
    'title',...
    'track',...
    'genre',...
    'date'};
if ismember(featureName,stringFeatures),
    featureFormat = '"%s"';
end
end
