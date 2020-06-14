--[[——————————————————————————————————————————————--
               Developer: Be1zebub

             Website: incredible-gmod.ru
        EMail: beelzebub@incredible-gmod.ru
        Discord: discord.incredible-gmod.ru
--——————————————————————————————————————————————]]--

local isstr = isstring

local APIModule = {}
APIModule.Name = "GeoIP"
APIModule.ApiURL = "https://freegeoip.app/json/%s" -- http://ip-api.com/json/%s?fields=countryCode  (Another GeoAPI)
function APIModule:Call(target, callback)
	target = self:RequestSteamID64(target)
	if not isstr(target) then return end

	local cache = self:GetCache(target)
	if cache and callback then
		callback(cache)
		return
	end

	self:FetchURL(self.ApiURL:format(target), function(body)
		if not body or body == "" then return end
		local result = self:HandleJson(body, "country_code")
		if not result then return end

		self:DoCache(target, result)
		if callback then
			callback(result)
		end
	end)
end

return APIModule
