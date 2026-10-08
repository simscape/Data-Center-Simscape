function getRatingForPDU(blockPath,blockType)
    rating = getRatingPDU(BlockPath=blockPath,BlockType=blockType);
    ratingUnit = unit(rating);
    ratingVal = value(rating,ratingUnit);
    msgbox([string(ratingVal);string(ratingUnit)],"Rating");
end