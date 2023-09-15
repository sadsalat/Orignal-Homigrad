table.insert(LevelList,"darkrp")
darkrp = darkrp or {}
darkrp.Name = "DarkRP"
darkrp.NoSelectRandom = true

darkrp.limits = {
    vehicle = false,
    ragdoll = 1,
    prop = 10,
    effect = 5,
    npc = false,
    swep = false,
}

darkrp.DeathWait = 15

NOTIFY_GENERIC = 0
NOTIFY_ERROR = 1
NOTIFY_UNDO = 2
NOTIFY_HINT = 3
NOTIFY_CLEANUP = 4--lmao

function darkrp.StartRound()
    game.CleanUpMap(false)

    if CLEINT then return end

    darkrp.StartRoundSV()
end