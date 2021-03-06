-- incredible-gmod.ru
-- IncredibleAPI lib

local isstr = isstring

local APIModule = {}
APIModule.Name = "SteamFamilyShared"
APIModule.ApiURL = "https://api.steampowered.com/IPlayerService/IsPlayingSharedGame/v1/?key=%s&steamid=%s"
function APIModule:Call(target, steamapi_key, callback)
	target = self:RequestSteamID64(target)
	if not isstr(target) then return end

	local cache = self:GetCache(target)
	if cache and callback then
		callback(cache)
		return
	end

	self:FetchURL(self:FormatUrl(steamapi_key, target), function(body)
		if not body or body == "" then return end
		local result = self:HandleJson(body, "response", "lender_steamid")
		if not result then return end

		result = result == 1

		self:DoCache(target, result)
		if callback then
			callback(result)
		end
	end)
end

return APIModule
