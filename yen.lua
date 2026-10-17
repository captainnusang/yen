--[[
	YEN UI Library  v1.0.0
	โทนสีเหลือง | API สไตล์ CreateWindow > CreateTab > CreateSection > AddXxx
	- ใช้เป็น ModuleScript (require) หรือโฮสต์ไว้แล้ว loadstring ก็ได้ (ไฟล์ return YEN)
	- Elements: Toggle (+Keybind), Slider (+Textbox/Format), Button, Keybind, Dropdown (Multi),
	            Textbox, Label, Divider
	- มี Flags / Options / Callback / Notify / Config (save/load) / Theme / CreateSettingsTab
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local YEN = {
	Version = "1.0.0",
	Windows = {},
	Flags = {},
	Options = {},
	ConfigStore = {}, -- fallback เมื่อไม่มี writefile
	Unloaded = false,
	subs = {},
}
YEN.__index = YEN

---------------------------------------------------------------------
-- Utilities
---------------------------------------------------------------------
local function ext(name)
	local ok, value = pcall(function()
		return getfenv()[name]
	end)
	return ok and value or nil
end

local function safeCall(fn, ...)
	if type(fn) ~= "function" then
		return
	end
	local ok, err = pcall(fn, ...)
	if not ok then
		warn("[YEN] callback error: " .. tostring(err))
	end
end

local function C(r, g, b)
	return Color3.fromRGB(r, g, b)
end

local function tween(obj, props, instant, t)
	if instant then
		for k, v in pairs(props) do
			obj[k] = v
		end
	else
		TweenService:Create(obj, TweenInfo.new(t or 0.12, Enum.EasingStyle.Quad), props):Play()
	end
end

local function darken(color, amount)
	amount = amount or 0.78
	return Color3.new(color.R * amount, color.G * amount, color.B * amount)
end

function YEN.subs.Wait()
	RunService.Heartbeat:Wait()
	return not YEN.Unloaded
end

---------------------------------------------------------------------
-- Theme
---------------------------------------------------------------------
local BaseTheme = {
	Background = C(14, 13, 9),
	Surface = C(22, 20, 13),
	Surface2 = C(31, 28, 17),
	Surface3 = C(44, 39, 21),
	Line = C(60, 54, 30),
	Text = C(246, 242, 229),
	Muted = C(168, 160, 130),
	Faint = C(118, 111, 86),
	Accent = C(255, 214, 64),
	AccentDark = C(204, 158, 18),
	OnAccent = C(24, 19, 4),
	Good = C(142, 216, 176),
	Bad = C(240, 120, 110),
}

local Presets = {
	Yellow = { Accent = C(255, 214, 64), AccentDark = C(204, 158, 18) },
	Amber = { Accent = C(255, 170, 50), AccentDark = C(204, 120, 15) },
	Lime = { Accent = C(205, 240, 80), AccentDark = C(150, 184, 36) },
	Rose = { Accent = C(246, 160, 186), AccentDark = C(205, 98, 133) },
}
YEN.Presets = Presets

---------------------------------------------------------------------
-- Keys
---------------------------------------------------------------------
local KeyAlias = {
	MouseButton1 = "M1", MouseButton2 = "M2", MouseButton3 = "M3",
	LeftControl = "LCtrl", RightControl = "RCtrl",
	LeftShift = "LShift", RightShift = "RShift",
	LeftAlt = "LAlt", RightAlt = "RAlt",
	Backspace = "Bksp", Return = "Enter",
}

local function keyText(key)
	if not key then
		return "None"
	end
	return KeyAlias[key.Name] or key.Name
end

local function normalizeKey(k)
	if k == nil then
		return nil
	end
	if typeof(k) == "EnumItem" then
		if k.EnumType == Enum.KeyCode or k.EnumType == Enum.UserInputType then
			if k == Enum.KeyCode.Unknown then
				return nil
			end
			return k
		end
		return nil
	end
	if type(k) == "number" then
		if k == 1 then return Enum.UserInputType.MouseButton1 end
		if k == 2 then return Enum.UserInputType.MouseButton2 end
		if k == 3 then return Enum.UserInputType.MouseButton3 end
		return nil
	end
	if type(k) == "string" then
		if k == "" or k == "None" then
			return nil
		end
		local m = k:upper():match("^M[B]?(%d)$")
		if m then
			return normalizeKey(tonumber(m))
		end
		local ok, v = pcall(function() return Enum.KeyCode[k] end)
		if ok and v and v ~= Enum.KeyCode.Unknown then
			return v
		end
		ok, v = pcall(function() return Enum.UserInputType[k] end)
		if ok and v then
			return v
		end
	end
	return nil
end

local function matches(input, key)
	return input.KeyCode == key or input.UserInputType == key
end

---------------------------------------------------------------------
-- Classes
---------------------------------------------------------------------
local Window = {}
Window.__index = Window
local Tab = {}
Tab.__index = Tab
local Section = {}
Section.__index = Section
local Element = {}
Element.__index = Element

function Element:Get()
	return self.Value
end
function Element:SetVisible(v)
	if self.Frame then
		self.Frame.Visible = v and true or false
	end
end

local function commit(el, silent)
	if el.Flag then
		YEN.Flags[el.Flag] = el.Value
	end
	if not silent then
		safeCall(el.Callback, el.Value)
	end
end

---------------------------------------------------------------------
-- Window helpers
---------------------------------------------------------------------
function Window:_new(class, props, parent, binds)
	local obj = Instance.new(class)
	for k, v in pairs(props or {}) do
		obj[k] = v
	end
	if binds then
		for prop, key in pairs(binds) do
			obj[prop] = self.Theme[key]
			table.insert(self._bindings, { obj = obj, prop = prop, key = key })
		end
	end
	obj.Parent = parent
	return obj
end

function Window:_onTheme(obj, fn)
	table.insert(self._bindings, { obj = obj, fn = fn })
end

function Window:_corner(parent, radius)
	return self:_new("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, parent)
end

function Window:_stroke(parent, key, transparency)
	return self:_new("UIStroke", {
		Thickness = 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, parent, { Color = key or "Line" })
end

function Window:_text(parent, text, size, key, bold, props)
	local p = {
		BackgroundTransparency = 1,
		Text = text or "",
		TextSize = size or 12,
		Font = bold and Enum.Font.GothamMedium or Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, 0, 0, 18),
	}
	for k, v in pairs(props or {}) do
		p[k] = v
	end
	return self:_new("TextLabel", p, parent, { TextColor3 = key or "Text" })
end

function Window:_connect(signal, fn)
	local c = signal:Connect(fn)
	table.insert(self._conns, c)
	return c
end

function Window:SetTheme(t)
	if type(t) == "string" then
		t = Presets[t]
	end
	if type(t) ~= "table" then
		return
	end
	for k, v in pairs(t) do
		if typeof(v) == "Color3" and self.Theme[k] ~= nil then
			self.Theme[k] = v
		end
	end
	local alive = {}
	for _, b in ipairs(self._bindings) do
		if b.obj and b.obj:IsDescendantOf(self.Gui) then
			table.insert(alive, b)
			if b.fn then
				pcall(b.fn)
			else
				b.obj[b.prop] = self.Theme[b.key]
			end
		end
	end
	self._bindings = alive
end

function Window:SetAccent(color)
	if typeof(color) == "Color3" then
		self:SetTheme({ Accent = color, AccentDark = darken(color) })
	end
end

function Window:Toggle(state)
	if state == nil then
		state = not self.Frame.Visible
	end
	self.Frame.Visible = state and true or false
end

function Window:Notify(opts)
	if type(opts) == "string" then
		opts = { Text = opts }
	end
	opts = opts or {}
	local duration = tonumber(opts.Duration) or 4
	self._notifyOrder += 1
	local card = self:_new("CanvasGroup", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		GroupTransparency = 1,
		LayoutOrder = self._notifyOrder,
	}, self._notifyHolder, { BackgroundColor3 = "Surface" })
	self:_corner(card, 10)
	self:_stroke(card, "AccentDark", 0.2)
	self:_new("UIPadding", {
		PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
	}, card)
	self:_new("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, card)
	self:_text(card, opts.Title or self.Name, 12, "Accent", true, { Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 1 })
	if opts.Text and opts.Text ~= "" then
		self:_text(card, tostring(opts.Text), 11, "Text", false, {
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			TextWrapped = true, TextTruncate = Enum.TextTruncate.None, LayoutOrder = 2,
		})
	end
	tween(card, { GroupTransparency = 0 }, false, 0.18)
	task.delay(duration, function()
		if card and card.Parent then
			tween(card, { GroupTransparency = 1 }, false, 0.25)
			task.wait(0.3)
			if card and card.Parent then
				card:Destroy()
			end
		end
	end)
end

function Window:Destroy()
	for _, c in ipairs(self._conns) do
		pcall(function() c:Disconnect() end)
	end
	table.clear(self._conns)
	if self.Gui then
		self.Gui:Destroy()
	end
	local i = table.find(YEN.Windows, self)
	if i then
		table.remove(YEN.Windows, i)
	end
	if #YEN.Windows == 0 then
		YEN.Unloaded = true
	end
end

---------------------------------------------------------------------
-- Config
---------------------------------------------------------------------
local CONFIG_FOLDER = "YEN/configs"

local function fsReady()
	return type(ext("writefile")) == "function" and type(ext("readfile")) == "function"
		and type(ext("isfolder")) == "function" and type(ext("makefolder")) == "function"
end

local function cleanName(name)
	name = tostring(name or ""):gsub("[^%w_%- ]", "")
	return name
end

function Window:GetConfigData()
	local data = {}
	for flag, value in pairs(YEN.Flags) do
		local t = type(value)
		if t == "boolean" or t == "number" or t == "string" or t == "table" then
			data[flag] = value
		end
	end
	return data
end

function Window:SaveConfig(name)
	name = cleanName(name)
	if name == "" then
		return nil
	end
	local ok, json = pcall(HttpService.JSONEncode, HttpService, self:GetConfigData())
	if not ok then
		return nil
	end
	if fsReady() then
		pcall(function()
			if not ext("isfolder")("YEN") then ext("makefolder")("YEN") end
			if not ext("isfolder")(CONFIG_FOLDER) then ext("makefolder")(CONFIG_FOLDER) end
			ext("writefile")(CONFIG_FOLDER .. "/" .. name .. ".json", json)
		end)
	else
		YEN.ConfigStore[name] = json
	end
	return json
end

function Window:LoadConfig(nameOrJson)
	local json
	if type(nameOrJson) == "string" and nameOrJson:sub(1, 1) == "{" then
		json = nameOrJson
	else
		local name = cleanName(nameOrJson)
		if name == "" then
			return false
		end
		if fsReady() then
			local ok, res = pcall(function()
				local path = CONFIG_FOLDER .. "/" .. name .. ".json"
				if ext("isfile") and ext("isfile")(path) then
					return ext("readfile")(path)
				end
			end)
			json = ok and res or nil
		end
		json = json or YEN.ConfigStore[name]
	end
	if not json then
		return false
	end
	local ok, data = pcall(HttpService.JSONDecode, HttpService, json)
	if not ok or type(data) ~= "table" then
		return false
	end
	for flag, value in pairs(data) do
		local opt = YEN.Options[flag]
		if opt and opt.Set then
			pcall(opt.Set, opt, value)
		end
	end
	return true
end

function Window:DeleteConfig(name)
	name = cleanName(name)
	if name == "" then
		return false
	end
	YEN.ConfigStore[name] = nil
	if fsReady() and ext("delfile") and ext("isfile") then
		pcall(function()
			local path = CONFIG_FOLDER .. "/" .. name .. ".json"
			if ext("isfile")(path) then
				ext("delfile")(path)
			end
		end)
	end
	return true
end

function Window:ListConfigs()
	local list, seen = {}, {}
	if fsReady() and ext("listfiles") and ext("isfolder") then
		pcall(function()
			if ext("isfolder")(CONFIG_FOLDER) then
				for _, path in ipairs(ext("listfiles")(CONFIG_FOLDER)) do
					local n = tostring(path):match("([^/\\]+)%.json$")
					if n and not seen[n] then
						seen[n] = true
						table.insert(list, n)
					end
				end
			end
		end)
	end
	for n in pairs(YEN.ConfigStore) do
		if not seen[n] then
			seen[n] = true
			table.insert(list, n)
		end
	end
	table.sort(list)
	return list
end

---------------------------------------------------------------------
-- Keybind core (ใช้ร่วมกันระหว่าง Toggle keybind และ AddKeybind)
---------------------------------------------------------------------
function Window:_createKeybind(row, cfg, getState, setState, rightOffset)
	local kb = setmetatable({
		Type = "Keybind",
		Mode = cfg.Mode or "Toggle", -- Toggle | Hold | Dynamic | Off
		Flag = cfg.Flag,
		KeyChanged = cfg.KeyChanged,
		_held = false,
		_listening = false,
	}, Element)

	local button = self:_new("TextButton", {
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -(rightOffset or 0), 0.5, 0),
		Size = UDim2.fromOffset(44, 22),
		Font = Enum.Font.GothamMedium,
		TextSize = 10,
		Text = "None",
	}, row, { BackgroundColor3 = "Surface2", TextColor3 = "Muted" })
	self:_corner(button, 6)
	self:_stroke(button, "Line", 0.2)
	kb.Button = button

	local function refresh()
		local t = kb._listening and "..." or keyText(kb.Key)
		button.Text = t
		button.Size = UDim2.fromOffset(math.clamp(#t * 7 + 14, 40, 96), 22)
		button.TextColor3 = kb._listening and self.Theme.Accent or self.Theme.Muted
	end
	self:_onTheme(button, refresh)

	function kb:SetKey(key, silent)
		key = normalizeKey(key)
		self.Key = key
		self.Value = key and key.Name or "None"
		if self.Flag then
			YEN.Flags[self.Flag] = self.Value
		end
		refresh()
		if not silent then
			safeCall(self.KeyChanged, key)
		end
	end
	function kb:Set(v, silent)
		self:SetKey(v, silent)
	end
	function kb.StopListen()
		kb._listening = false
		if self._listeningKb == kb then
			self._listeningKb = nil
		end
		refresh()
	end
	function kb:Press()
		if self.Mode == "Off" then
			return
		end
		if self.Mode == "Hold" then
			self._held = true
			setState(true)
		elseif self.Mode == "Dynamic" then
			self._held = true
			self._t = tick()
			self._prev = getState()
			setState(true)
		else
			setState(not getState())
		end
	end
	function kb:Release()
		if not self._held then
			return
		end
		self._held = false
		if self.Mode == "Hold" then
			setState(false)
		elseif self.Mode == "Dynamic" then
			if tick() - (self._t or 0) > 0.65 then
				setState(false)
			else
				setState(not self._prev)
			end
		end
	end

	button.Activated:Connect(function()
		if kb._listening then
			kb.StopListen()
			return
		end
		if self._listeningKb then
			self._listeningKb.StopListen()
		end
		kb._listening = true
		self._listeningKb = kb
		refresh()
	end)

	table.insert(self._keybinds, kb)
	kb:SetKey(cfg.Key, true)
	if kb.Flag then
		YEN.Options[kb.Flag] = kb
		YEN.Flags[kb.Flag] = kb.Value
	end
	return kb
end

---------------------------------------------------------------------
-- Section elements
---------------------------------------------------------------------
function Section:_row(height)
	self._order += 1
	return self.Window:_new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, height),
		LayoutOrder = self._order,
	}, self.Frame)
end

function Section:_register(el, frame)
	el.Frame = frame
	el.Section = self
	table.insert(self.Elements, { Name = el.Name or "", Frame = frame })
	self.Tab._load[self.Column] += 1
	if el.Flag then
		YEN.Flags[el.Flag] = el.Value
		YEN.Options[el.Flag] = el
	end
	return el
end

function Section:AddLabel(opts)
	if type(opts) ~= "table" then
		opts = { Name = tostring(opts or "") }
	end
	local win = self.Window
	local el = setmetatable({ Type = "Label", Name = opts.Name or opts.Text or "" }, Element)
	local row = self:_row(22)
	local lbl = win:_text(row, el.Name, 11, opts.Color or "Muted", false, {
		Size = UDim2.new(1, 0, 1, 0), TextWrapped = false,
	})
	el.Value = el.Name
	function el:Set(text)
		self.Value = tostring(text)
		lbl.Text = self.Value
	end
	return self:_register(el, row)
end

function Section:AddDivider()
	local win = self.Window
	local el = setmetatable({ Type = "Divider", Name = "" }, Element)
	local row = self:_row(8)
	win:_new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0,
	}, row, { BackgroundColor3 = "Line" })
	return self:_register(el, row)
end

function Section:AddButton(opts)
	opts = opts or {}
	local win = self.Window
	local el = setmetatable({ Type = "Button", Name = opts.Name or "Button", Callback = opts.Callback }, Element)
	local row = self:_row(30)
	local btn = win:_new("TextButton", {
		AutoButtonColor = false, Size = UDim2.new(1, 0, 1, 0), Text = "",
	}, row, { BackgroundColor3 = "Surface2" })
	win:_corner(btn, 8)
	win:_stroke(btn, "Line", 0.2)
	local lbl = win:_text(btn, el.Name, 12, "Text", true, {
		Size = UDim2.new(1, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Center,
	})
	btn.MouseEnter:Connect(function() tween(btn, { BackgroundColor3 = win.Theme.Surface3 }) end)
	btn.MouseLeave:Connect(function() tween(btn, { BackgroundColor3 = win.Theme.Surface2 }) end)
	btn.Activated:Connect(function()
		lbl.TextColor3 = win.Theme.Accent
		task.delay(0.15, function()
			if lbl.Parent then lbl.TextColor3 = win.Theme.Text end
		end)
		safeCall(el.Callback)
	end)
	function el:SetText(t)
		self.Name = tostring(t)
		lbl.Text = self.Name
	end
	function el:Fire()
		safeCall(self.Callback)
	end
	return self:_register(el, row)
end

function Section:AddToggle(opts)
	opts = opts or {}
	local win = self.Window
	local el = setmetatable({
		Type = "Toggle", Name = opts.Name or "Toggle", Flag = opts.Flag, Callback = opts.Callback,
		Value = (opts.Value == true or opts.Default == true),
	}, Element)
	local row = self:_row(30)

	local click = win:_new("TextButton", {
		BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 1, 0),
	}, row)
	local hasKey = opts.Keybind ~= nil
	local lbl = win:_text(row, el.Name, 12, "Text", false, {
		Size = UDim2.new(1, hasKey and -140 or -50, 1, 0), Active = false,
	})
	local switch = win:_new("Frame", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(36, 18),
	}, row)
	win:_corner(switch, 9)
	local knob = win:_new("Frame", { Size = UDim2.fromOffset(12, 12) }, switch)
	win:_corner(knob, 6)

	local function render(instant)
		local on = el.Value
		tween(switch, { BackgroundColor3 = on and win.Theme.Accent or win.Theme.Surface3 }, instant)
		tween(knob, {
			Position = on and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6),
			BackgroundColor3 = on and win.Theme.OnAccent or win.Theme.Muted,
		}, instant)
	end
	render(true)
	win:_onTheme(switch, function() render(true) end)

	function el:Set(v, silent)
		v = v and true or false
		if v == self.Value then
			return
		end
		self.Value = v
		render(false)
		commit(self, silent)
	end

	click.Activated:Connect(function()
		el:Set(not el.Value)
	end)

	if hasKey then
		local cfg = opts.Keybind
		if type(cfg) ~= "table" then
			cfg = { Key = cfg }
		end
		el.Keybind = win:_createKeybind(row, {
			Key = cfg.Key or cfg.Value, Mode = cfg.Mode or "Toggle",
			Flag = opts.Flag and (opts.Flag .. "_Key") or nil,
		}, function() return el.Value end, function(s) el:Set(s) end, 44)
	end

	return self:_register(el, row)
end

function Section:AddSlider(opts)
	opts = opts or {}
	local win = self.Window
	local min = tonumber(opts.Min) or 0
	local max = tonumber(opts.Max) or 100
	if min > max then
		min, max = max, min
	end
	local precise = math.clamp(math.floor(tonumber(opts.Precise) or 0), 0, 6)
	local mult = 10 ^ precise
	local function clampv(v)
		return math.clamp(math.floor(v * mult + 0.5) / mult, min, max)
	end
	local el = setmetatable({
		Type = "Slider", Name = opts.Name or "Slider", Flag = opts.Flag, Callback = opts.Callback,
		Min = min, Max = max, Format = opts.Format,
	}, Element)
	el.Value = clampv(tonumber(opts.Value) or tonumber(opts.Default) or min)

	local row = self:_row(46)
	local hasBox = opts.Textbox == true
	local hasFormat = type(opts.Format) == "function"

	local lbl = win:_text(row, el.Name, 12, "Text", false, {
		Size = UDim2.new(1, hasBox and -64 or (hasFormat and 0 or -76), 0, 20),
	})
	local valueLbl, box
	if hasBox then
		box = win:_new("TextBox", {
			AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(56, 20),
			Font = Enum.Font.GothamMedium, TextSize = 11, ClearTextOnFocus = false, Text = "",
		}, row, { BackgroundColor3 = "Surface2", TextColor3 = "Accent" })
		win:_corner(box, 6)
		win:_stroke(box, "Line", 0.2)
	elseif not hasFormat then
		valueLbl = win:_text(row, "", 11, "Accent", true, {
			AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.fromOffset(72, 20), TextXAlignment = Enum.TextXAlignment.Right,
		})
	end

	local track = win:_new("Frame", {
		Position = UDim2.new(0, 0, 0, 30), Size = UDim2.new(1, 0, 0, 6), BorderSizePixel = 0,
	}, row, { BackgroundColor3 = "Surface3" })
	win:_corner(track, 3)
	local fill = win:_new("Frame", { Size = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0 }, track, { BackgroundColor3 = "Accent" })
	win:_corner(fill, 3)
	local knob = win:_new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(12, 12), Position = UDim2.new(0, 0, 0.5, 0),
	}, track, { BackgroundColor3 = "Text" })
	win:_corner(knob, 6)
	local hit = win:_new("TextButton", {
		BackgroundTransparency = 1, Text = "", Position = UDim2.new(0, 0, 0, 22), Size = UDim2.new(1, 0, 0, 22),
	}, row)

	local function display()
		local alpha = (max == min) and 0 or (el.Value - min) / (max - min)
		fill.Size = UDim2.new(alpha, 0, 1, 0)
		knob.Position = UDim2.new(alpha, 0, 0.5, 0)
		if hasFormat then
			local ok, res = pcall(opts.Format, el.Value)
			lbl.Text = ok and tostring(res) or el.Name
		else
			lbl.Text = el.Name
		end
		if valueLbl then valueLbl.Text = tostring(el.Value) end
		if box then box.Text = tostring(el.Value) end
	end
	display()

	function el:Set(v, silent)
		v = clampv(tonumber(v) or self.Value)
		local changed = v ~= self.Value
		self.Value = v
		display()
		if changed then
			commit(self, silent)
		end
	end

	local dragging = false
	local function fromX(x)
		local a = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		el:Set(min + (max - min) * a)
	end
	local function setScroll(enabled)
		local page = self.Tab and self.Tab.Page
		if page then page.ScrollingEnabled = enabled end
	end
	hit.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			setScroll(false)
			fromX(input.Position.X)
		end
	end)
	win:_connect(UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			fromX(input.Position.X)
		end
	end)
	win:_connect(UserInputService.InputEnded, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			dragging = false
			setScroll(true)
		end
	end)
	if box then
		box.FocusLost:Connect(function()
			local n = tonumber(box.Text)
			if n then el:Set(n) else display() end
		end)
	end

	return self:_register(el, row)
end

function Section:AddTextbox(opts)
	opts = opts or {}
	local win = self.Window
	local el = setmetatable({
		Type = "Textbox", Name = opts.Name or "Textbox", Flag = opts.Flag, Callback = opts.Callback,
		Value = tostring(opts.Value or opts.Default or ""),
	}, Element)
	local row = self:_row(30)
	win:_text(row, el.Name, 12, "Text", false, { Size = UDim2.new(0.4, -6, 1, 0) })
	local box = win:_new("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0.6, 0, 0, 26),
		Font = Enum.Font.Gotham, TextSize = 11, ClearTextOnFocus = false, Text = el.Value,
		PlaceholderText = opts.Placeholder or "Enter text...", TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, row, { BackgroundColor3 = "Surface2", TextColor3 = "Text", PlaceholderColor3 = "Faint" })
	win:_corner(box, 6)
	win:_stroke(box, "Line", 0.2)
	win:_new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, box)

	function el:Set(v, silent)
		v = tostring(v == nil and "" or v)
		local changed = v ~= self.Value
		self.Value = v
		box.Text = v
		if changed then commit(self, silent) end
	end
	box.FocusLost:Connect(function()
		el:Set(box.Text)
	end)
	return self:_register(el, row)
end

function Section:AddKeybind(opts)
	opts = opts or {}
	local win = self.Window
	local row = self:_row(30)
	local name = opts.Name or "Keybind"
	win:_text(row, name, 12, "Text", false, { Size = UDim2.new(1, -110, 1, 0) })
	local kb
	local active = false
	kb = win:_createKeybind(row, {
		Key = opts.Key or opts.Value or opts.Default, Mode = opts.Mode or "Toggle",
		Flag = opts.Flag, KeyChanged = opts.KeyChanged,
	}, function() return active end, function(state)
		if state == active then return end
		active = state
		kb.Active = state
		safeCall(opts.Callback, state)
	end, 0)
	kb.Name = name
	kb.Active = false
	function kb:GetState()
		return active
	end
	-- Flag/Options ถูก register ใน _createKeybind แล้ว
	opts.Flag = nil
	return self:_register(kb, row)
end

function Section:AddDropdown(opts)
	opts = opts or {}
	local win = self.Window
	local el = setmetatable({
		Type = "Dropdown", Name = opts.Name or "Dropdown", Flag = opts.Flag, Callback = opts.Callback,
		Multi = opts.Multi == true, Options = {},
	}, Element)
	for _, o in ipairs(opts.Options or opts.List or {}) do
		table.insert(el.Options, tostring(o))
	end

	local function normalize(v)
		if el.Multi then
			local set = {}
			if type(v) == "table" then
				for _, x in pairs(v) do set[tostring(x)] = true end
			elseif v ~= nil then
				set[tostring(v)] = true
			end
			local out = {}
			for _, o in ipairs(el.Options) do
				if set[o] then table.insert(out, o) end
			end
			return out
		end
		if type(v) == "table" then v = v[1] end
		if v == nil then return nil end
		v = tostring(v)
		return table.find(el.Options, v) and v or nil
	end

	self._order += 1
	local box = win:_new("Frame", {
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30),
		AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = self._order,
	}, self.Frame)
	win:_new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, box)
	local header = win:_new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), LayoutOrder = 1 }, box)
	win:_text(header, el.Name, 12, "Text", false, { Size = UDim2.new(1, -160, 1, 0) })
	local valueBtn = win:_new("TextButton", {
		AutoButtonColor = false, Text = "", AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(150, 26),
	}, header, { BackgroundColor3 = "Surface2" })
	win:_corner(valueBtn, 6)
	win:_stroke(valueBtn, "Line", 0.2)
	local valueText = win:_text(valueBtn, "", 11, "Text", false, {
		Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -26, 1, 0),
	})
	local arrow = win:_text(valueBtn, "▾", 12, "Muted", false, {
		Position = UDim2.new(1, -18, 0, 0), Size = UDim2.fromOffset(14, 26), TextXAlignment = Enum.TextXAlignment.Center,
	})
	local list = win:_new("ScrollingFrame", {
		Visible = false, BorderSizePixel = 0, ScrollBarThickness = 3, AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(), Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 2,
	}, box, { BackgroundColor3 = "Surface2", ScrollBarImageColor3 = "AccentDark" })
	win:_corner(list, 8)
	win:_stroke(list, "Line", 0.2)
	win:_new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, list)
	win:_new("UIPadding", {
		PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
		PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4),
	}, list)

	local items = {}
	local function has(o)
		if el.Multi then return table.find(el.Value, o) ~= nil end
		return el.Value == o
	end
	local function render()
		if el.Multi then
			valueText.Text = #el.Value == 0 and "None" or table.concat(el.Value, ", ")
		else
			valueText.Text = el.Value or "Select..."
		end
		for _, item in ipairs(items) do
			item.btn.TextColor3 = has(item.name) and win.Theme.Accent or win.Theme.Muted
		end
	end
	local function rebuild()
		for _, item in ipairs(items) do item.btn:Destroy() end
		table.clear(items)
		for i, o in ipairs(el.Options) do
			local btn = win:_new("TextButton", {
				AutoButtonColor = false, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), Text = o,
				TextSize = 11, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = i,
			}, list)
			win:_new("UIPadding", { PaddingLeft = UDim.new(0, 6) }, btn)
			btn.Activated:Connect(function()
				if el.Multi then
					local cur = {}
					for _, v in ipairs(el.Value) do cur[v] = true end
					cur[o] = not cur[o] or nil
					local arr = {}
					for k in pairs(cur) do table.insert(arr, k) end
					el:Set(arr)
				else
					el:Set(o)
					list.Visible = false
					arrow.Text = "▾"
				end
			end)
			table.insert(items, { name = o, btn = btn })
		end
		list.Size = UDim2.new(1, 0, 0, math.min(#el.Options, 6) * 26 + 8)
	end

	el.Value = normalize(opts.Value or opts.Default)
	rebuild()
	render()
	win:_onTheme(list, render)

	function el:Set(v, silent)
		local nv = normalize(v)
		local changed
		if self.Multi then
			changed = table.concat(nv, "\n") ~= table.concat(self.Value, "\n")
		else
			changed = nv ~= self.Value
		end
		self.Value = nv
		render()
		if changed then commit(self, silent) end
	end
	function el:Refresh(options)
		self.Options = {}
		for _, o in ipairs(options or {}) do table.insert(self.Options, tostring(o)) end
		rebuild()
		self.Value = normalize(self.Value)
		render()
		if self.Flag then YEN.Flags[self.Flag] = self.Value end
	end

	valueBtn.Activated:Connect(function()
		list.Visible = not list.Visible
		arrow.Text = list.Visible and "▴" or "▾"
	end)

	return self:_register(el, box)
end

---------------------------------------------------------------------
-- Tab / Section
---------------------------------------------------------------------
function Tab:CreateSection(opts)
	if type(opts) ~= "table" then
		opts = { Name = tostring(opts or "Section") }
	end
	local win = self.Window
	local side = tostring(opts.Side or ""):lower()
	local column
	if side == "right" then
		column = "Right"
	elseif side == "left" then
		column = "Left"
	else
		column = (self._load.Left <= self._load.Right) and "Left" or "Right"
	end
	local parent = column == "Left" and self.Left or self.Right

	local sec = setmetatable({
		Window = win, Tab = self, Name = opts.Name or "Section", Column = column, Elements = {}, _order = 0,
	}, Section)
	sec.Frame = win:_new("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = #self.Sections + 1,
	}, parent, { BackgroundColor3 = "Surface" })
	win:_corner(sec.Frame, 12)
	win:_stroke(sec.Frame, "Line")
	win:_new("UIPadding", {
		PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 12),
		PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
	}, sec.Frame)
	win:_new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, sec.Frame)
	sec.Title = win:_text(sec.Frame, sec.Name, 13, "Accent", true, { Size = UDim2.new(1, 0, 0, 20), LayoutOrder = -2 })
	win:_new("Frame", { Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0, LayoutOrder = -1 }, sec.Frame, { BackgroundColor3 = "Line" })

	table.insert(self.Sections, sec)
	return sec
end

function Window:_applySearch(query)
	local tab = self.ActiveTab
	if not tab then
		return
	end
	query = tostring(query or ""):lower()
	for _, sec in ipairs(tab.Sections) do
		local secMatch = query == "" or sec.Name:lower():find(query, 1, true) ~= nil
		local any = secMatch
		for _, e in ipairs(sec.Elements) do
			local m = secMatch or e.Name:lower():find(query, 1, true) ~= nil
			if e.Frame then e.Frame.Visible = m end
			any = any or m
		end
		sec.Frame.Visible = any
	end
end

function Window:SelectTab(tab)
	if not tab or self.ActiveTab == tab then
		return
	end
	self.ActiveTab = tab
	for _, t in ipairs(self.Tabs) do
		t:_render()
	end
	self.PageTitle.Text = tab.Name
	if self.Search.Text ~= "" then
		self.Search.Text = ""
	end
	self:_applySearch("")
	tab.Page.CanvasPosition = Vector2.zero
end

function Window:CreateTab(opts)
	if type(opts) ~= "table" then
		opts = { Name = tostring(opts or "Tab") }
	end
	local tab = setmetatable({
		Window = self, Name = opts.Name or "Tab", Icon = opts.Icon or "◆", Sections = {},
		_load = { Left = 0, Right = 0 },
	}, Tab)

	-- ปุ่มใน sidebar
	tab.Button = self:_new("TextButton", {
		AutoButtonColor = false, Text = "", Size = UDim2.new(1, 0, 0, 36),
		LayoutOrder = #self.Tabs + 1, BackgroundTransparency = 1,
	}, self.Nav, { BackgroundColor3 = "Surface3" })
	self:_corner(tab.Button, 9)
	tab.Bar = self:_new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(3, 16), BorderSizePixel = 0, Visible = false,
	}, tab.Button, { BackgroundColor3 = "Accent" })
	self:_corner(tab.Bar, 2)
	tab.IconLabel = self:_text(tab.Button, tab.Icon, 15, "Muted", true, {
		Position = self.Compact and UDim2.new(0, 0, 0, 0) or UDim2.fromOffset(12, 0),
		Size = self.Compact and UDim2.new(1, 0, 1, 0) or UDim2.fromOffset(22, 36),
		TextXAlignment = Enum.TextXAlignment.Center, TextTruncate = Enum.TextTruncate.None,
	})
	if not self.Compact then
		tab.NameLabel = self:_text(tab.Button, tab.Name, 12, "Muted", false, {
			Position = UDim2.fromOffset(40, 0), Size = UDim2.new(1, -46, 1, 0),
		})
	end

	-- หน้า content
	tab.Page = self:_new("ScrollingFrame", {
		BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0),
		ScrollBarThickness = 4, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y, Visible = false,
	}, self.Pages, { ScrollBarImageColor3 = "AccentDark" })
	local holder = self:_new("Frame", {
		BackgroundTransparency = 1, Size = UDim2.new(1, -10, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
	}, tab.Page)
	self:_new("UIListLayout", {
		FillDirection = self.Compact and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Top,
	}, holder)
	self:_new("UIPadding", { PaddingBottom = UDim.new(0, 12) }, holder)
	local colSize = self.Compact and UDim2.new(1, 0, 0, 0) or UDim2.new(0.5, -6, 0, 0)
	for index, name in ipairs({ "Left", "Right" }) do
		local col = self:_new("Frame", {
			BackgroundTransparency = 1, Size = colSize, AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = index,
		}, holder)
		self:_new("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder }, col)
		tab[name] = col
	end

	function tab:_render()
		local active = self.Window.ActiveTab == self
		self.Button.BackgroundTransparency = active and 0 or 1
		self.Bar.Visible = active
		self.Page.Visible = active
		self.IconLabel.TextColor3 = active and self.Window.Theme.Accent or self.Window.Theme.Muted
		if self.NameLabel then
			self.NameLabel.TextColor3 = active and self.Window.Theme.Text or self.Window.Theme.Muted
			self.NameLabel.Font = active and Enum.Font.GothamMedium or Enum.Font.Gotham
		end
	end
	self:_onTheme(tab.Button, function() tab:_render() end)

	tab.Button.MouseEnter:Connect(function()
		if self.ActiveTab ~= tab then tab.Button.BackgroundTransparency = 0.6 end
	end)
	tab.Button.MouseLeave:Connect(function()
		if self.ActiveTab ~= tab then tab.Button.BackgroundTransparency = 1 end
	end)
	tab.Button.Activated:Connect(function()
		self:SelectTab(tab)
	end)

	table.insert(self.Tabs, tab)
	if not self.ActiveTab then
		self:SelectTab(tab)
	else
		tab:_render()
	end
	return tab
end

---------------------------------------------------------------------
-- Settings tab (ใช้งานได้จริง: Toggle key, Theme, Config)
---------------------------------------------------------------------
function Window:CreateSettingsTab(opts)
	opts = opts or {}
	local tab = self:CreateTab({ Name = opts.Name or "Settings", Icon = "⚙" })

	local menu = tab:CreateSection({ Name = "Menu", Side = "Left" })
	menu:AddKeybind({
		Name = "Toggle UI", Key = self.ToggleKey, Mode = "Off",
		KeyChanged = function(key) self.ToggleKey = key end,
	})
	menu:AddButton({ Name = "Unload UI", Callback = function() self:Destroy() end })

	local themes = tab:CreateSection({ Name = "Theme", Side = "Left" })
	local presetNames = {}
	for name in pairs(Presets) do table.insert(presetNames, name) end
	table.sort(presetNames)
	themes:AddDropdown({
		Name = "Preset", Options = presetNames, Value = "Yellow",
		Callback = function(v) if v then self:SetTheme(v) end end,
	})
	themes:AddTextbox({
		Name = "Accent (hex)", Placeholder = "#FFD640",
		Callback = function(text)
			local ok, color = pcall(Color3.fromHex, tostring(text))
			if ok and color then
				self:SetAccent(color)
			end
		end,
	})

	local cfg = tab:CreateSection({ Name = "Configs", Side = "Right" })
	local nameBox = cfg:AddTextbox({ Name = "Config name", Placeholder = "default" })
	local dropdown = cfg:AddDropdown({ Name = "Saved configs", Options = self:ListConfigs() })
	local function refresh()
		dropdown:Refresh(self:ListConfigs())
	end
	local function target()
		local n = dropdown.Value
		if not n or n == "" then n = nameBox.Value end
		return n
	end
	cfg:AddButton({ Name = "Save", Callback = function()
		local n = nameBox.Value ~= "" and nameBox.Value or dropdown.Value
		if n and self:SaveConfig(n) then
			refresh()
			self:Notify({ Title = "Config", Text = "Saved: " .. cleanName(n) })
		else
			self:Notify({ Title = "Config", Text = "Enter a config name first" })
		end
	end })
	cfg:AddButton({ Name = "Load", Callback = function()
		local n = target()
		local ok = n and self:LoadConfig(n)
		self:Notify({ Title = "Config", Text = ok and ("Loaded: " .. cleanName(n)) or "Config not found" })
	end })
	cfg:AddButton({ Name = "Delete", Callback = function()
		local n = target()
		if n and self:DeleteConfig(n) then
			refresh()
			self:Notify({ Title = "Config", Text = "Deleted: " .. cleanName(n) })
		end
	end })
	cfg:AddButton({ Name = "Refresh list", Callback = refresh })
	return tab
end

---------------------------------------------------------------------
-- CreateWindow
---------------------------------------------------------------------
function YEN:CreateWindow(opts)
	opts = opts or {}
	local self = setmetatable({}, Window)
	self.Library = YEN
	self.Name = tostring(opts.Name or "YEN")
	self.Theme = {}
	for k, v in pairs(BaseTheme) do self.Theme[k] = v end
	local preset = Presets[opts.Preset or "Yellow"]
	if preset then
		for k, v in pairs(preset) do self.Theme[k] = v end
	end
	if typeof(opts.Accent) == "Color3" then
		self.Theme.Accent = opts.Accent
		self.Theme.AccentDark = darken(opts.Accent)
	end
	self._bindings, self._conns, self._keybinds = {}, {}, {}
	self._notifyOrder = 0
	self.Tabs = {}
	self.ToggleKey = normalizeKey(opts.ToggleKey or Enum.KeyCode.RightControl)

	-- ที่วาง ScreenGui
	local parentGui
	local okHui, hui = pcall(function() return ext("gethui")() end)
	if okHui and typeof(hui) == "Instance" then
		parentGui = hui
	else
		parentGui = LocalPlayer:WaitForChild("PlayerGui")
	end
	local guiName = "YEN_UI_" .. self.Name
	for _, w in ipairs({ table.unpack(YEN.Windows) }) do
		if w.Name == self.Name then w:Destroy() end
	end
	for _, p in ipairs({ parentGui, LocalPlayer:FindFirstChild("PlayerGui") }) do
		local old = p and p:FindFirstChild(guiName)
		if old then old:Destroy() end
	end
	YEN.Unloaded = false

	self.Gui = Instance.new("ScreenGui")
	self.Gui.Name = guiName
	self.Gui.ResetOnSpawn = false
	self.Gui.IgnoreGuiInset = true
	self.Gui.DisplayOrder = 50
	self.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.Gui.Parent = parentGui

	-- ขนาด
	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
	local want = typeof(opts.Size) == "Vector2" and opts.Size or Vector2.new(780, 520)
	local w = math.clamp(want.X, 300, math.max(vp.X - 20, 300))
	local h = math.clamp(want.Y, 260, math.max(vp.Y - 20, 260))
	self.Compact = w < 600
	local sw = self.Compact and 56 or 190

	self.Frame = self:_new("Frame", {
		Name = "Window", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(w, h), ClipsDescendants = true,
	}, self.Gui, { BackgroundColor3 = "Background" })
	self:_corner(self.Frame, 14)
	self:_stroke(self.Frame, "AccentDark", 0.45)

	-- Sidebar
	local sidebar = self:_new("Frame", { Size = UDim2.new(0, sw, 1, 0) }, self.Frame, { BackgroundColor3 = "Surface" })
	self:_new("Frame", { Position = UDim2.new(1, -1, 0, 0), Size = UDim2.new(0, 1, 1, 0), BorderSizePixel = 0 }, sidebar, { BackgroundColor3 = "Line" })
	local mark = self:_new("Frame", {
		Position = self.Compact and UDim2.new(0.5, -16, 0, 14) or UDim2.fromOffset(14, 14), Size = UDim2.fromOffset(32, 32),
	}, sidebar, { BackgroundColor3 = "Accent" })
	self:_corner(mark, 10)
	self:_text(mark, "Y", 17, "OnAccent", true, {
		Size = UDim2.new(1, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.GothamBold,
	})
	if not self.Compact then
		self:_text(sidebar, self.Name, 13, "Text", true, { Position = UDim2.fromOffset(54, 13), Size = UDim2.new(1, -62, 0, 18) })
		self:_text(sidebar, opts.Subtitle or "UI Library", 10, "Muted", false, { Position = UDim2.fromOffset(54, 31), Size = UDim2.new(1, -62, 0, 14) })
	end

	self.Nav = self:_new("ScrollingFrame", {
		BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0,
		Position = UDim2.fromOffset(8, 62), Size = UDim2.new(1, -16, 1, -126),
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, sidebar)
	self:_new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, self.Nav)

	local account = self:_new("Frame", { Position = UDim2.new(0, 8, 1, -56), Size = UDim2.new(1, -16, 0, 46) }, sidebar, { BackgroundColor3 = "Surface2" })
	self:_corner(account, 10)
	self:_stroke(account, "Line", 0.2)
	local avatar = self:_new("Frame", {
		Position = self.Compact and UDim2.new(0.5, -16, 0, 7) or UDim2.fromOffset(7, 7), Size = UDim2.fromOffset(32, 32),
	}, account, { BackgroundColor3 = "Surface3" })
	self:_corner(avatar, 9)
	local display = LocalPlayer and (LocalPlayer.DisplayName or LocalPlayer.Name) or "Player"
	self:_text(avatar, display:sub(1, 2):upper(), 11, "Accent", true, {
		Size = UDim2.new(1, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Center,
	})
	if not self.Compact then
		local info = type(opts.Themeable) == "table" and opts.Themeable.Info or nil
		self:_text(account, display, 11, "Text", true, { Position = UDim2.fromOffset(46, 6), Size = UDim2.new(1, -52, 0, 16) })
		self:_text(account, info or ("@" .. (LocalPlayer and LocalPlayer.Name or "player")), 9, "Muted", false, {
			Position = UDim2.fromOffset(46, 23), Size = UDim2.new(1, -52, 0, 14),
		})
	end

	-- Content
	local content = self:_new("Frame", {
		BackgroundTransparency = 1, Position = UDim2.new(0, sw + 1, 0, 0), Size = UDim2.new(1, -(sw + 1), 1, 0),
	}, self.Frame)
	local topbar = self:_new("Frame", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 10), Size = UDim2.new(1, -32, 0, 38), Active = true,
	}, content)
	local searchW = self.Compact and 96 or 150
	self.PageTitle = self:_text(topbar, "", 17, "Text", true, { Size = UDim2.new(1, -(searchW + 46), 1, 0) })
	self.Search = self:_new("TextBox", {
		Position = UDim2.new(1, -(searchW + 38), 0, 3), Size = UDim2.fromOffset(searchW, 32),
		Font = Enum.Font.Gotham, TextSize = 11, ClearTextOnFocus = false, Text = "", PlaceholderText = "Search",
		TextXAlignment = Enum.TextXAlignment.Left,
	}, topbar, { BackgroundColor3 = "Surface", TextColor3 = "Text", PlaceholderColor3 = "Faint" })
	self:_corner(self.Search, 8)
	self:_stroke(self.Search, "Line", 0.2)
	self:_new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 8) }, self.Search)
	self.Search:GetPropertyChangedSignal("Text"):Connect(function()
		self:_applySearch(self.Search.Text)
	end)
	local minimize = self:_new("TextButton", {
		AutoButtonColor = false, Position = UDim2.new(1, -30, 0, 3), Size = UDim2.fromOffset(30, 32),
		Font = Enum.Font.GothamMedium, TextSize = 16, Text = "–",
	}, topbar, { BackgroundColor3 = "Surface", TextColor3 = "Muted" })
	self:_corner(minimize, 8)
	self:_stroke(minimize, "Line", 0.2)
	minimize.Activated:Connect(function() self:Toggle(false) end)

	self.Pages = self:_new("Frame", {
		BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 58), Size = UDim2.new(1, -32, 1, -70), ClipsDescendants = true,
	}, content)

	-- Notifications
	self._notifyHolder = self:_new("Frame", {
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 14),
		Size = UDim2.new(0, 270, 1, -28),
	}, self.Gui)
	self:_new("UIListLayout", {
		Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Top,
	}, self._notifyHolder)

	-- Drag window
	local dragging, dragStart, startCenter = false, nil, nil
	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startCenter = self.Frame.AbsolutePosition + self.Frame.AbsoluteSize / 2
		end
	end)
	self:_connect(UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			local screen = self.Gui.AbsoluteSize
			local x = math.clamp(startCenter.X + delta.X, 40, math.max(screen.X - 40, 40))
			local y = math.clamp(startCenter.Y + delta.Y, 30, math.max(screen.Y - 30, 30))
			self.Frame.Position = UDim2.fromOffset(x, y)
		end
	end)
	self:_connect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			for _, k in ipairs(self._keybinds) do
				if k._held and k.Key and matches(input, k.Key) then
					k:Release()
				end
			end
		end
		if input.UserInputType == Enum.UserInputType.Keyboard then
			for _, k in ipairs(self._keybinds) do
				if k._held and k.Key and matches(input, k.Key) then
					k:Release()
				end
			end
		end
	end)

	-- Keybind / toggle key dispatcher
	self:_connect(UserInputService.InputBegan, function(input, gpe)
		local kb = self._listeningKb
		if kb then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == Enum.KeyCode.Escape then
					kb.StopListen()
				elseif input.KeyCode == Enum.KeyCode.Backspace then
					kb:SetKey(nil)
					kb.StopListen()
				else
					kb:SetKey(input.KeyCode)
					kb.StopListen()
				end
			elseif input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.MouseButton2
				or input.UserInputType == Enum.UserInputType.MouseButton3 then
				kb:SetKey(input.UserInputType)
				kb.StopListen()
			end
			return
		end
		if gpe then
			return
		end
		if self.ToggleKey and matches(input, self.ToggleKey) then
			self:Toggle()
		end
		for _, k in ipairs(self._keybinds) do
			if k.Key and k.Mode ~= "Off" and matches(input, k.Key) then
				k:Press()
			end
		end
	end)

	-- ปุ่มเปิด/ปิดสำหรับมือถือ
	if opts.MobileButton ~= false and UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		local b = self:_new("TextButton", {
			AutoButtonColor = false, Position = UDim2.fromOffset(12, 70), Size = UDim2.fromOffset(42, 42),
			Font = Enum.Font.GothamBold, TextSize = 16, Text = "Y",
		}, self.Gui, { BackgroundColor3 = "Accent", TextColor3 = "OnAccent" })
		self:_corner(b, 12)
		b.Activated:Connect(function() self:Toggle() end)
	end

	table.insert(YEN.Windows, self)
	return self
end

function YEN:Notify(opts)
	local w = YEN.Windows[#YEN.Windows]
	if w then
		w:Notify(opts)
	end
end

function YEN:Destroy()
	for _, w in ipairs({ table.unpack(YEN.Windows) }) do
		w:Destroy()
	end
end

return YEN
