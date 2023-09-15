sound.Add({
    name = "ZippyGore3OnRootBoneGib",
    sound = {
        "physics/body/body_medium_break2.wav",
        "physics/body/body_medium_break3.wav",
    },
    level = 90,
    volume = 1,
    pitch = { 88, 92 },
    channel = CHAN_STATIC,
})

sound.Add({
    name = "ZippyGore3OnGib",
    sound = {
        "physics/flesh/flesh_squishy_impact_hard3.wav",
        "physics/flesh/flesh_squishy_impact_hard4.wav",
        "physics/body/body_medium_break4.wav",
    },
    level = 80,
    volume = 0.8,
    pitch = { 95, 105 },
    channel = CHAN_STATIC,
})

sound.Add({
    name = "ZippyGore3GibCollision",
    sound = {
        "physics/flesh/flesh_squishy_impact_hard1.wav",
        "physics/flesh/flesh_squishy_impact_hard2.wav",
        "physics/flesh/flesh_squishy_impact_hard3.wav",
        "physics/flesh/flesh_squishy_impact_hard4.wav",
    },
    level = 70,
    volume = 0.6,
    pitch = { 110, 120 },
    channel = CHAN_BODY,
})