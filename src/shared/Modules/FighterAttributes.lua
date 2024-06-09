local Attributes = {}

local staminaRegenDenom = 10000

Attributes.LeKing = {
	headVigor = 250,
	bodyVigor = 150,
	MaxSpeed = 4.5,
	LowSpeed = 1.5,
	Damage = 15,
	ofStamina = 115,
	dvStamina = 50,
	ofStaminaDrain = 15,
	dvStaminaDrain = 25,
	ofStaminaRegen = 35 / staminaRegenDenom,
	dvStaminaRegen = 25 / staminaRegenDenom
}

Attributes.Paul = {
	headVigor = 200,
	bodyVigor = 115,
	maxSpeed = 6,
	lowSpeed = 3,
	Damage = 12.5,
	ofStamina = 150,
	dvStamina = 100,
	ofStaminaDrain = 15,
	dvStaminaDrain = 25,
	ofStaminaRegen = 35 / staminaRegenDenom,
	dvStaminaRegen = 25 / staminaRegenDenom
}

Attributes.Righty = {
	headVigor = 215,
	bodyVigor = 125,
	maxSpeed = 8,
	lowSpeed = 3,
	Damage = 15,
	ofStamina = 150,
	dvStamina = 100,
	ofStaminaDrain = 15,
	dvStaminaDrain = 25,
	ofStaminaRegen = 35 / staminaRegenDenom,
	dvStaminaRegen = 25 / staminaRegenDenom
}

return Attributes