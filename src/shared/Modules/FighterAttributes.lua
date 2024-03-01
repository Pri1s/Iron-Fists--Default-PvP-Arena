local Attributes = {}

local staminaRegenDenom = 10000

Attributes.LeKing = {
	headVigor = 100,
	bodyVigor = 125,
	MaxSpeed = 4.5,
	LowSpeed = 1.5,
	Damage = 17.5,
	ofStamina = 115,
	dvStamina = 50,
	ofStaminaDrain = 15,
	dvStaminaDrain = 25,
	ofStaminaRegen = 35 / staminaRegenDenom,
	dvStaminaRegen = 25 / staminaRegenDenom
}

Attributes.Paul = {
	headVigor = 75,
	bodyVigor = 125,
	maxSpeed = 6,
	lowSpeed = 3,
	Damage = 10,
	ofStamina = 150,
	dvStamina = 75,
	ofStaminaDrain = 15,
	dvStaminaDrain = 25,
	ofStaminaRegen = 35 / staminaRegenDenom,
	dvStaminaRegen = 25 / staminaRegenDenom
}

return Attributes