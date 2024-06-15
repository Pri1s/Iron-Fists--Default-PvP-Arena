local Attributes = {}

local staminaRegenDenom = 10000

Attributes.LeKing = {
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
	headVigor = 425,
	bodyVigor = 125,
	maxSpeed = 8,
	lowSpeed = 4,
	Damage = 15,
	ofStamina = 150,
	dvStamina = 75,
	ofStaminaDrain = 10,
	dvStaminaDrain = 35,
	headshotStaminaDrainMultiplier = 2,
	ofStaminaRegen = 50 / staminaRegenDenom,
	dvStaminaRegen = 15 / staminaRegenDenom,

	Damage = {
		Jab = 15,
		Hook = 25,
		Uppercut = 30
	}

}

return Attributes