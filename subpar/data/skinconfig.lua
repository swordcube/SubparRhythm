--- @class subpar.data.SkinConfig
--- This only exists for documentation purposes
--- It's literally just a table returned from Assets.getSkinConfig
local SkinConfig = {
    Meta = {
        Title = "Default",
        Author = "swordcube"
    },
    Game = {
        MaximumKeyCount = 4
    },
    Notes4K = {
        Scale = 0.5,
        Spacing = 112,

        Strums = {}, --- @type string[]
        PressStrums = {}, --- @type string[]
        HitStrums = {}, --- @type string[]

        Notes = {}, --- @type string[]
        Holds = {}, --- @type string[]
        Tails = {}, --- @type string[]
    }
}
return SkinConfig