-- Force all players to spawn as your Combine model

local CombineModel = "models/clankert/pm/clankert.mdl" -- replace with your model path

hook.Add("PlayerSpawn", "ClankDivers_ForcePlayermodel", function(ply)
    ply:SetModel(CombineModel)
end)
hook.Add("PlayerSetModel", "ClankDivers_BlockModelChange", function(ply)
    return true -- blocks any model changes
end)
