--- @class subpar.game.Scoring
local Scoring = {}

function Scoring.getScoreFromDiff(diff)
    diff = math.abs(diff)
    if diff <= 25.0 then
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

return Scoring