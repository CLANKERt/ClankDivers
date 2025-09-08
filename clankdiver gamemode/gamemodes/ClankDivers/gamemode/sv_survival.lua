if SERVER then
    util.AddNetworkString("ClankDivers_SelectGameMode")
    util.AddNetworkString("ClankDivers_PrepareTime")
    util.AddNetworkString("ClankDivers_UpdatePlayersAlive")

    -- Gamemode state
    ClankDivers = ClankDivers or {}
    ClankDivers.Mode = nil
    ClankDivers.Round = 0
    ClankDivers.Wave = 0
    ClankDivers.MaxWaves = 10
    ClankDivers.PlayersAlive = {}
    ClankDivers.Preparing = false
    ClankDivers.SkipPrep = false
    ClankDivers.WaveActive = false

    ------------------------
    -- Helper: broadcast players alive
    ------------------------
    local function SendPlayersAlive()
        net.Start("ClankDivers_UpdatePlayersAlive")
        local aliveIDs = {}
        for _, ply in ipairs(ClankDivers.PlayersAlive) do
            table.insert(aliveIDs, ply:SteamID())
        end
        net.WriteTable(aliveIDs)
        net.Broadcast()
    end

    ------------------------
    -- Mode selection
    ------------------------
    net.Receive("ClankDivers_SelectGameMode", function(len, ply)
        local mode = net.ReadString()
        print(ply:Nick().." selected "..mode)
        ClankDivers.Mode = mode

        if mode == "survival" then
            StartPrepTime()
        end
    end)

    ------------------------
    -- Prep timer
    ------------------------
    function StartPrepTime()
        if ClankDivers.Preparing then return end
        ClankDivers.Preparing = true
        ClankDivers.SkipPrep = false

        local countdown = 30
        net.Start("ClankDivers_PrepareTime")
        net.WriteInt(countdown, 8)
        net.Broadcast()

        timer.Create("ClankDiversPrepTimer", 1, 30, function()
            if ClankDivers.SkipPrep then
                timer.Remove("ClankDiversPrepTimer")
                ClankDivers.Preparing = false
                StartSurvivalRound()
                return
            end

            countdown = countdown - 1
            if countdown <= 0 then
                ClankDivers.Preparing = false
                StartSurvivalRound()
            end
        end)
    end

    hook.Add("PlayerSay", "ClankDiversSkipPrep", function(ply, text)
        if string.lower(text) == "!skip" and ClankDivers.Preparing then
            ClankDivers.SkipPrep = true
            return ""
        end
    end)

    ------------------------
    -- Start survival round
    ------------------------
    function StartSurvivalRound()
        ClankDivers.Round = ClankDivers.Round + 1
        ClankDivers.Wave = 1
        ClankDivers.PlayersAlive = player.GetAll()
        ClankDivers.WaveActive = true

        BroadcastMsg("Survival Round Started!")
        SendPlayersAlive()
        SpawnWave()
    end

    ------------------------
    -- Spawn waves
    ------------------------
    function SpawnWave()
        if ClankDivers.Wave > ClankDivers.MaxWaves then
            SpawnAPC()
            return
        end

        -- Spawn Combine dropships
        for i = 1, 2 do
            local pos = Vector(math.random(-1000,1000), math.random(-1000,1000), 500)
            local dropship = ents.Create("npc_combine_s")
            if IsValid(dropship) then
                dropship:SetPos(pos)
                dropship:Spawn()
            end
        end

        BroadcastMsg("Wave "..ClankDivers.Wave.." has begun!")

        -- Example: 60-second wave timer for next wave
        timer.Create("ClankDiversWaveTimer", 60, 1, function()
            ClankDivers.Wave = ClankDivers.Wave + 1
            SpawnWave()
        end)
    end

    ------------------------
    -- Player death handling
    ------------------------
    hook.Add("PlayerDeath", "ClankDiversPlayerDeath", function(victim)
        if table.HasValue(ClankDivers.PlayersAlive, victim) then
            for i, ply in ipairs(ClankDivers.PlayersAlive) do
                if ply == victim then
                    table.remove(ClankDivers.PlayersAlive, i)
                end
            end
        end

        -- Force spectator mode
        timer.Simple(0.1, function()
            if IsValid(victim) then
                victim:Spectate(OBS_MODE_CHASE)
                if #ClankDivers.PlayersAlive > 0 then
                    victim:SpectateEntity(ClankDivers.PlayersAlive[1])
                end
            end
        end)

        SendPlayersAlive()
    end)

    -- Prevent respawn during wave
    hook.Add("PlayerSpawn", "ClankDivers_PlayerSpawnControl", function(ply)
        if ClankDivers.Mode == "survival" and ClankDivers.WaveActive then
            if not table.HasValue(ClankDivers.PlayersAlive, ply) then
                timer.Simple(0, function()
                    if IsValid(ply) then
                        ply:Spectate(OBS_MODE_CHASE)
                        if #ClankDivers.PlayersAlive > 0 then
                            ply:SpectateEntity(ClankDivers.PlayersAlive[1])
                        end
                    end
                end)
                return false
            end
        end
    end)

    ------------------------
    -- APC spawn and escape
    ------------------------
    function SpawnAPC()
        local pos = Vector(math.random(-1000,1000), math.random(-1000,1000), 0)

        local apc = ents.Create("prop_physics")
        apc:SetModel("models/combine_apc_wheelcollision.mdl")
        apc:SetPos(pos)
        apc:Spawn()
        apc:SetColor(Color(0,255,0))
        apc:SetUseType(SIMPLE_USE)

        function apc:Use(activator, caller)
            if not activator:IsPlayer() then return end
            if table.HasValue(ClankDivers.PlayersAlive, activator) then
                for i, ply in ipairs(ClankDivers.PlayersAlive) do
                    if ply == activator then
                        table.remove(ClankDivers.PlayersAlive, i)
                    end
                end
                activator:ChatPrint("You escaped!")
                activator:Spectate(OBS_MODE_CHASE)
                if #ClankDivers.PlayersAlive > 0 then
                    activator:SpectateEntity(ClankDivers.PlayersAlive[1])
                end
            end

            if #ClankDivers.PlayersAlive == 0 then
                BroadcastMsg("All players have escaped! Round over!")
                EndWave()
            end

            SendPlayersAlive()
        end

        BroadcastMsg("APC has arrived! Press E to escape!")
    end

    ------------------------
    -- End wave and respawn players
    ------------------------
    function EndWave()
        ClankDivers.WaveActive = false
        -- Respawn all dead players
        for _, ply in ipairs(player.GetAll()) do
            if not ply:Alive() then
                ply:Spawn()
            end
        end
        SendPlayersAlive()
        CleanupMap()
        timer.Simple(1, StartPrepTime)
    end

    ------------------------
    -- Cleanup map
    ------------------------
    function CleanupMap()
        for _, ent in ipairs(ents.GetAll()) do
            if ent:IsNPC() or ent:GetClass() == "prop_physics" then
                SafeRemoveEntity(ent)
            end
        end
        BroadcastMsg("Map cleaned!")
    end

    ------------------------
    -- Admin commands
    ------------------------
    concommand.Add("clankdivers_spawn_apc", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsAdmin() then return end
        SpawnAPC()
    end)

    concommand.Add("clankdivers_force_respawn", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsAdmin() then return end
        for _, p in ipairs(player.GetAll()) do
            if not p:Alive() then
                p:Spawn()
            end
        end
        SendPlayersAlive()
    end)

    ------------------------
    -- Broadcast helper
    ------------------------
    function BroadcastMsg(text)
        for _, ply in ipairs(player.GetAll()) do
            ply:ChatPrint(text)
        end
    end
end
-- Add network messages
util.AddNetworkString("ClankDivers_SpectateSwitch")
util.AddNetworkString("ClankDivers_UpdatePlayersAlive")
util.AddNetworkString("ClankDivers_PrepareTime")
util.AddNetworkString("ClankDivers_SelectGameMode")
