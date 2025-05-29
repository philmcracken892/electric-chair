Config = {}

-- Chair and Generator Spawn Zones
Config.Zones = {
    [1] = { 
        ChairCoord = vector3(-352.20, 820.56, 116.66 -1), 
        GeneratorCoord = vector3(-353.62, 819.98, 116.59 -1), 
        GenHead = 12.3, 
        CharHead = 102.61, 
        ChairId = 0, 
        GeneratorId = 0, 
        SpawnRange = 20, 
        ChairSpawn = false, 
        GenSpawn = false
    },
    [2] = { 
        ChairCoord = vector3(2707.97, -1412.38, 46.62 -1), 
        GeneratorCoord = vector3(2709.06, -1411.61, 46.62 -1), 
        GenHead = 12.3, 
        CharHead = 102.61, 
        ChairId = 0, 
        GeneratorId = 0, 
        SpawnRange = 20, 
        ChairSpawn = false, 
        GenSpawn = false
    },
}

-- Job Configuration
Config.Job = 'vallaw'

-- Prompt Text Configuration
Config.Chair = 'Place in chair'
Config.ChairName = 'Electric Chair'
Config.GeneratorName = 'Electric Generator'
Config.Shock = 'Electrocute'
Config.Increase = 'Increase Power'
Config.Decrease = 'Decrease Power'

-- Notification Configuration
Config.NoPrisoner = 'Electric Chair'
Config.NoPrisonerText = 'No Prisoner Nearby!'
Config.DictNo = 'menu_textures'
Config.IconNo = 'cross'
Config.TimeNo = 5000
Config.ColorNo = 'COLOR_REDLIGHT'