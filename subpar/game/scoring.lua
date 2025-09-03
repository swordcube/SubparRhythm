--- @class subpar.game.Scoring
local Scoring = {}

function Scoring.getRatingList()
    return {"perfect", "amazing", "great", "okay", "subpar", "miss"}
end

function Scoring.getScoreFromDiff(diff)
    diff = math.abs(diff)
    if diff <= 22.5 then
        return 500
    elseif diff <= 45.0 then
        return 350
    elseif diff <= 90.0 then
        return 200
    elseif diff <= 135.0 then
        return 100
    elseif diff <= 180.0 then
        return 50
    end
    return 0
end

function Scoring.getRatingFromDiff(diff)
    diff = math.abs(diff)
    if diff <= 22.5 then
        return "perfect"
    elseif diff <= 45.0 then
        return "amazing"
    elseif diff <= 90.0 then
        return "great"
    elseif diff <= 135.0 then
        return "okay"
    elseif diff <= 180.0 then
        return "subpar"
    end
    return "unknown"
end

return Scoring