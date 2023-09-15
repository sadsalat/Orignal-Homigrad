if SERVER then
local ranks = {
	["superadmin"] = true,
}
hook.Add("PrePACConfigApply", "PACRankRestrict", function(ply)
	if not ranks[ply:GetUserGroup()] then
              return false,"Insufficient rank to use PAC."
        end
end)

hook.Add( "PrePACEditorOpen", "RestrictToSuperadmin", function( ply )
	if not ranks[ply:GetUserGroup()] then
        return false
  end
end )
end