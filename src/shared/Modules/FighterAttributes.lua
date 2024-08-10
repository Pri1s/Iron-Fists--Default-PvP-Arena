local staminaRegenDenom = 100

local Attributes = {}

Attributes.LeKing = {
    Amputation = "None",
    headVigor = 500,
    bodyVigor = 150,
    MaxSpeed = 4.5,
    LowSpeed = 1.5,
    ofStamina = 115,
    dvStamina = 50,
    ofStaminaDrain = 20,
    dvStaminaDrain = 25,
    headshotStaminaDrainMultiplier = 2,
    ofStaminaRegen = 25 / staminaRegenDenom,
    dvStaminaRegen = 25 / staminaRegenDenom,

    Damage = {
        Jab = 15,
        Hook = 25,
        Uppercut = 30
    }

}

Attributes.Paul = {
    Amputation = "None",
    headVigor = 425,
    bodyVigor = 115,
    maxSpeed = 6,
    lowSpeed = 3,
    ofStamina = 150,
    dvStamina = 100,
    ofStaminaDrain = 15,
    dvStaminaDrain = 25,
    headshotStaminaDrainMultiplier = 2,
    ofStaminaRegen = 35 / staminaRegenDenom,
    dvStaminaRegen = 25 / staminaRegenDenom,

    Damage = {
        Jab = 12.5,
        Hook = 20,
        Uppercut = 25
    }

}

Attributes.Righty = {
    Amputation = "LeftArm",
    headVigor = 425,
    bodyVigor = 125,
    maxSpeed = 8,
    lowSpeed = 4,
    ofStamina = 125,
    dvStamina = 75,
    ofStaminaDrain = 17.5,
    dvStaminaDrain = 35,
    headshotStaminaDrainMultiplier = 2,
    ofStaminaRegen = 35 / staminaRegenDenom,
    dvStaminaRegen = 15 / staminaRegenDenom,

    Damage = {
        Jab = 15,
        Hook = 25,
        Uppercut = 30
    }

}

return Attributes