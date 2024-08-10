local Settings = {}

Settings.requiredQueuers = 2
Settings.Rounds = 6
Settings.homeId = 15853147715

Settings.Delays = {
    Default = 0.15,
    Transition = 1,
    loadToT = 3,
    initializeMatch = 7,
    introTime = 3
}

Settings.Times = {

    Round = {
        Minutes = 3,
        Seconds = 00
    }

}

Settings.Environment = {

    Camera = {

        Spin = {
            Radius = 75,
            angularSpeed = 0.1
        },

        Dynamic = {
            FOV = 70,
            minOffset = 7.5,
            lerpSpeed = 0.1
        }

    }

}

Settings.Credits = {
    Win = 100,
    Lose = 30
}

return Settings