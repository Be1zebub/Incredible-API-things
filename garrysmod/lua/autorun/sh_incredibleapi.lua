-- incredible-gmod.ru
-- IncredibleAPI lib

local Fetch, strFormat, isstr, istab, unpuck, Json2Tab, newyork, CurrentTime, str_Replace, IsValid = http.Fetch, string.format, isstring, istable, unpack, util.JSONToTable, pairs, CurTime, string.Replace, IsValid
local TableToJSON, istable, fWrite, tostring, fRead = util.TableToJSON, istable, file.Write, tostring, file.Read

IncredibleAPI = IncredibleAPI or {}
IncredibleAPI.__index = IncredibleAPI
IncredibleAPI.Modules = IncredibleAPI.Modules or {}

if not file.Exists("incredible_api", "DATA") then
	file.CreateDir("incredible_api")
end

function IncredibleAPI:Call(module_name, ...)
    local m = self.Modules[module_name]

    if m and m.Call then
        m:Call(...)

        return true
    end

    return false
end

--——————————————— A P I  —▬—  M E T A  —▬— T A B L E ———————————————--
local ApiMETA = {}
ApiMETA.__index = ApiMETA
ApiMETA.W8 = 0
ApiMETA.DefaultDelay = 5
ApiMETA.UrlPattern = "https?://[%w-_%.%?%.:/%+=&]+"

function ApiMETA:IsValidURL(url)
    return url:find(self.UrlPattern)
end

function ApiMETA:FormatUrl(...)
    return strFormat((self.ApiURL or self.URL), ...)
end

function ApiMETA:FetchURL(args, handle)
    local url = self.URL and strFormat(self.URL, isstr(args) and args or istab(args) and unpuck(args)) or args
    if not self:IsValidURL(url) then return false end

    Fetch(url, function(body)
        if not body or body == "" then return end

        if handle then
            handle(body)
        end
    end)
end

local conv = util.SteamIDTo64

function ApiMETA:RequestSteamID64(target)
    if isstr(target) then
        local s64 = conv(target)

        return s64 ~= "0" and s64 or target
    elseif IsValid(target) and target:IsPlayer() then
        return target:SteamID64()
    end
end

function ApiMETA:HandleJson(json, ...)
    local tbl = Json2Tab(json)
    if not tbl then return end

    local args = {...}

    for _, key in newyork(args) do
        if tbl[key] then
            tbl = tbl[key]
        end
    end

    return tbl
end

function ApiMETA:DoCache(uid, data, Filewrite)
    self.Cache[uid] = data

    if write then
    	if istable(data) then
    		data = TableToJSON(data)
    	end

    	fWrite("incredible_api/"..uid..".txt", tostring(data))
    end
end

function ApiMETA:GetCache(uid, Fileread)
	if read then
		if self.Cache[uid] then return self.Cache[uid] end

		local data = fRead("incredible_api/"..uid..".txt")
		if data == "" or data == "no value" then return end

		local tab = Json2Tab(data)
		if istable(tab) then
			data = tab
		end

		self.Cache[uid] = data
		return data
	else
		return self.Cache[uid]
	end
end

function ApiMETA:Delay(t)
    local CT = CurrentTime()
    if self.W8 > CT then return true end
    self.W8 = CT + (t or self.DefaultDelay)
end

--——————————————— M O D U LE —▬— R E G I S T R A T I O N ———————————————--
function IncredibleAPI:RegisterModule(name, tab)
    tab.Cache = {}
    setmetatable(tab, ApiMETA)
    IncredibleAPI.Modules[name] = tab

    if tab.OnRegister then
        tab:OnRegister()
    end
end

--——————————————— A P I  —▬—  M O D U L E S —▬— L O A D ———————————————--
local __DebugMode = true

-- Thx Penguin for thats better solution :)
local include_realm = {
    sv = SERVER and include or function() end,
    cl = SERVER and AddCSLuaFile or include
}

include_realm.sh = function(f) return include_realm.cl(f) or include_realm.sv(f) end
local __a, __b = file.Find, string.sub
local string_upper = string.upper
local First2Upper = function(str) return str:gsub("^%l", string_upper) end

local Filename2CoolName = function(f)
    f = str_Replace(f, "." .. f:match("[^.]+$"), "") -- remove extention
    f = __b(f, 4, #f) -- remove realm name (sv_ or _sh or _cl e.t.c)

    return First2Upper(f)
end

local file_register = function(f)
    local realm = __b(f, 1, 2)

    if include_realm[realm] then
        local result = include_realm[realm]("incredible_api/" .. f)

        if result then
            IncredibleAPI:RegisterModule(result.Name or Filename2CoolName(f), result)

            if __DebugMode then
                print("Registered: " .. realm .. " | " .. f)
            end
        elseif __DebugMode then
            print("[ERROR] Include did not return table: " .. realm .. " | " .. f)
        end
    elseif __DebugMode then
        print("[ERROR] Realm does not exists: " .. realm .. " | " .. f)
    end
end

local DoLoadAPIs = function()
    local files = __a("incredible_api/*", "LUA")

    for _, f in newyork(files) do
        file_register(f)
    end

    if IsFirstTimePredicted() then
        MsgC(Color(40, 149, 220), "Incredible API-Library has been loaded! \n")
    end
end

DoLoadAPIs()

if SERVER then
    util.AddNetworkString("IncredibleAPI.Reload")

    concommand.Add("incredibleapi_reload", function(ply)
        if ply:IsSuperAdmin() then
            DoLoadAPIs()
            net.Start("IncredibleAPI.Reload")
            net.Broadcast()
        end
    end)
else
    net.Receive("IncredibleAPI.Reload", function()
        DoLoadAPIs()
    end)
end
