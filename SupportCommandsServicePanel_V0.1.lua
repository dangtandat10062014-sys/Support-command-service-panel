local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RunCommandLine")

local LANG = {
    vi = {
        title = "Support Commands Service Panel",
        version = "Phiên bản V.0.1",
        loading = "Đang tải...",
        choose = "CHỌN NGÔN NGỮ",
        add = "+ Tạo lệnh mới",
        name = "Tên lệnh",
        command = "Nhập lệnh, ví dụ /text",
        manual = "Thủ công",
        repeatTrigger = "Lặp lại mỗi N giây",
        selfRespawn = "Khi bản thân hồi sinh",
        allRespawn = "Khi bất kỳ người chơi hồi sinh",
        targetRespawn = "Khi người chơi chỉ định hồi sinh",
        allDead = "Khi bất kỳ người chơi chết",
        targetDead = "Khi người chơi chỉ định chết",
        cycle = "Chu kỳ (giây)",
        target = "Tên người chơi",
        run = "Chạy",
        delete = "Xóa",
        on = "BẬT",
        off = "TẮT",
        minimize = "Thu nhỏ",
        restore = "Mở",
        close = "Đóng",
        noName = "Chưa nhập tên",
        mainTab = "Main Menu",
        commandsTab = "Commands",
        search = "Tìm lệnh",
        searchPlaceholder = "Tìm theo tên, lệnh hoặc nhóm...",
        catalogTitle = "Danh mục lệnh G&B",
        catalogHint = "Chọn một lệnh để thêm vào danh sách và cuộn tới thẻ lệnh",
        addFromCatalog = "+ Thêm lệnh",
        noResults = "Không tìm thấy lệnh",
    },
    en = {
        title = "Support Commands Service Panel",
        version = "Version V.0.1",
        loading = "Loading...",
        choose = "SELECT LANGUAGE",
        add = "+ New Command",
        name = "Command name",
        command = "Enter command, e.g. /text",
        manual = "Manual",
        repeatTrigger = "Repeat every N seconds",
        selfRespawn = "When I respawn",
        allRespawn = "When any player respawns",
        targetRespawn = "When selected player respawns",
        allDead = "When any player dies",
        targetDead = "When selected player dies",
        cycle = "Interval (seconds)",
        target = "Player name",
        run = "Run",
        delete = "Delete",
        on = "ON",
        off = "OFF",
        minimize = "Minimize",
        restore = "Open",
        close = "Close",
        noName = "Name required",
        mainTab = "Main Menu",
        commandsTab = "Commands",
        search = "Search Commands",
        searchPlaceholder = "Search by name, command, or category...",
        catalogTitle = "G&B Command Catalog",
        catalogHint = "Select a command to add it and scroll to its command card",
        addFromCatalog = "+ Add Command",
        noResults = "No commands found",
    },
    zh = {
        title = "Support Commands Service Panel",
        version = "版本 V.0.1",
        loading = "正在加载...",
        choose = "选择语言",
        add = "+ 新建命令",
        name = "命令名称",
        command = "输入命令，例如 /text",
        manual = "手动",
        repeatTrigger = "每 N 秒重复",
        selfRespawn = "自己重生时",
        allRespawn = "任何玩家重生时",
        targetRespawn = "指定玩家重生时",
        allDead = "任何玩家死亡时",
        targetDead = "指定玩家死亡时",
        cycle = "间隔（秒）",
        target = "玩家名称",
        run = "执行",
        delete = "删除",
        on = "开启",
        off = "关闭",
        minimize = "最小化",
        restore = "打开",
        close = "关闭",
        noName = "请输入名称",
        mainTab = "主菜单",
        commandsTab = "命令",
        search = "搜索命令",
        searchPlaceholder = "按名称、命令或类别搜索...",
        catalogTitle = "G&B 命令目录",
        catalogHint = "选择命令以添加并滚动到对应命令卡片",
        addFromCatalog = "+ 添加命令",
        noResults = "没有找到命令",
    }
}

local selectedLanguage = "vi"
local commands = {}
local nextId = 0
local watched = {}
local minimized = false
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SupportCommandsServicePanel"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local function tr(key)
    return LANG[selectedLanguage][key] or key
end

local function create(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function corner(obj, radius)
    create("UICorner", {CornerRadius = UDim.new(0, radius or 8)}, obj)
end

local function styleButton(button, color)
    button.BackgroundColor3 = color or Color3.fromRGB(60, 67, 80)
    button.TextColor3 = Color3.fromRGB(245, 247, 250)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 12
    button.BorderSizePixel = 0
    corner(button, 6)
end

local loading = create("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(17, 19, 24),
    BorderSizePixel = 0
}, screenGui)

local loadingTitle = create("TextLabel", {
    Size = UDim2.new(1, -30, 0, 50),
    Position = UDim2.new(0, 15, 0.38, 0),
    BackgroundTransparency = 1,
    Text = "Support Commands Service Panel",
    TextColor3 = Color3.fromRGB(240, 243, 248),
    TextScaled = true,
    Font = Enum.Font.GothamBold
}, loading)

local loadingStatus = create("TextLabel", {
    Size = UDim2.new(1, -30, 0, 30),
    Position = UDim2.new(0, 15, 0.48, 0),
    BackgroundTransparency = 1,
    Text = LANG.vi.loading .. " 0%",
    TextColor3 = Color3.fromRGB(170, 180, 195),
    TextSize = 15,
    Font = Enum.Font.Gotham
}, loading)

local barBack = create("Frame", {
    Size = UDim2.new(0.7, 0, 0, 8),
    Position = UDim2.new(0.15, 0, 0.56, 0),
    BackgroundColor3 = Color3.fromRGB(48, 53, 64),
    BorderSizePixel = 0
}, loading)
corner(barBack, 5)

local barFill = create("Frame", {
    Size = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = Color3.fromRGB(75, 160, 120),
    BorderSizePixel = 0
}, barBack)
corner(barFill, 5)

local languageFrame = create("Frame", {
    Size = UDim2.new(0.82, 0, 0.38, 0),
    Position = UDim2.new(0.09, 0, 0.31, 0),
    BackgroundColor3 = Color3.fromRGB(28, 31, 38),
    BorderSizePixel = 0,
    Visible = false
}, screenGui)
corner(languageFrame, 12)

local languageTitle = create("TextLabel", {
    Size = UDim2.new(1, -20, 0, 46),
    Position = UDim2.fromOffset(10, 8),
    BackgroundTransparency = 1,
    Text = LANG.vi.choose,
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 17,
    Font = Enum.Font.GothamBold
}, languageFrame)

local panel
local list
local addButton
local panelTitle
local versionLabel
local minimizedButton
local renderCommands

local function fireCommand(command)
    if command.enabled and command.text ~= "" then
        remote:FireServer(command.text)
    end
end

local function dispatch(triggerType, targetPlayer)
    for _, command in ipairs(commands) do
        if command.enabled then
            if command.trigger == triggerType then
                fireCommand(command)
            elseif triggerType == "allRespawn"
                and command.trigger == "targetRespawn"
                and targetPlayer
                and targetPlayer.Name:lower() == command.target:lower() then
                fireCommand(command)
            elseif triggerType == "allDead"
                and command.trigger == "targetDead"
                and targetPlayer
                and targetPlayer.Name:lower() == command.target:lower() then
                fireCommand(command)
            end
        end
    end
end

local function watchCharacter(targetPlayer, character)
    if not character then
        return
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
        or character:WaitForChild("Humanoid", 8)
    if not humanoid then
        return
    end
    humanoid.Died:Connect(function()
        dispatch("allDead", targetPlayer)
    end)
end

local function watchPlayer(targetPlayer)
    if watched[targetPlayer] then
        return
    end
    watched[targetPlayer] = true
    targetPlayer.CharacterAdded:Connect(function(character)
        dispatch("allRespawn", targetPlayer)
        if targetPlayer == player then
            dispatch("selfRespawn", targetPlayer)
        end
        task.spawn(watchCharacter, targetPlayer, character)
    end)
    if targetPlayer.Character then
        task.spawn(watchCharacter, targetPlayer, targetPlayer.Character)
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    watchPlayer(p)
end
Players.PlayerAdded:Connect(watchPlayer)
Players.PlayerRemoving:Connect(function(p)
    watched[p] = nil
end)

local catalogCommands = {
    {category="Class Commands", command="/emperor {username}", description="Change a player into an emperor"},
    {category="Class Commands", command="/changemperor {username} {emperor}", description="Change a player's emperor"},
    {category="Class Commands", command="/ruler {username} {emperor}", description="Change a player's ruler"},
    {category="Class Commands", command="/class {class} {username}", description="Change player class"},
    {category="Class Commands", command="/changeclass {class} {username}", description="Change player class"},
    {category="Class Commands", command="/classlimit", description="Toggle class limit"},
    {category="Class Commands", command="/nation {nation}", description="Change nation"},
    {category="Class Commands", command="/changenation {nation}", description="Change nation"},
    {category="Class Commands", command="/knight {username}", description="Turn player into a Knight"},
    {category="Equipment Commands", command="/give {username} {tool} {amount#}", description="Give an item"},
    {category="Equipment Commands", command="/item {username} {tool} {amount#}", description="Give an item"},
    {category="Equipment Commands", command="/giveitem {username} {tool} {amount#}", description="Give an item"},
    {category="Equipment Commands", command="/give all {username}", description="Give nearly all items"},
    {category="Equipment Commands", command="/minigun {username}", description="Give a minigun"},
    {category="Equipment Commands", command="/armor {username}", description="Give siege engineer armour"},
    {category="Equipment Commands", command="/armour {username}", description="Give siege engineer armour"},
    {category="Equipment Commands", command="/givekit {username}", description="Give extended surgeon kit effect"},
    {category="Equipment Commands", command="/surgeonkit {username}", description="Give extended surgeon kit effect"},
    {category="Equipment Commands", command="/spawn ham", description="Spawn ham"},
    {category="Equipment Commands", command="/givesupplybox {username} {item}", description="Give a supply box"},
    {category="Round-Effecting Commands", command="/clear", description="Delete text logs"},
    {category="Round-Effecting Commands", command="/spawn {zombietype} {amount} {round multiplier#} {delay} {wanderer?}", description="Spawn zombies"},
    {category="Round-Effecting Commands", command="/summon {zombietype} {amount} {round multiplier#} {delay} {wanderer?}", description="Spawn zombies"},
    {category="Round-Effecting Commands", command="/forcemap {map} {gamemode}", description="Force a map and gamemode"},
    {category="Round-Effecting Commands", command="/changemap {map} {gamemode}", description="Force a map and gamemode"},
    {category="Round-Effecting Commands", command="/map {map} {gamemode}", description="Force a map and gamemode"},
    {category="Round-Effecting Commands", command="/killz", description="Kill cannibals and bots"},
    {category="Round-Effecting Commands", command="/regional", description="Restrict nation selection"},
    {category="Round-Effecting Commands", command="/togglez", description="Toggle zombie and bot spawning"},
    {category="Round-Effecting Commands", command="/togglefreezing", description="Toggle cold effect"},
    {category="Round-Effecting Commands", command="/enablecoat", description="Enable greatcoats"},
    {category="Round-Effecting Commands", command="/hardcore", description="Enable Hardcore Mode"},
    {category="Round-Effecting Commands", command="/preparetodie", description="Enable Hardcore Mode"},
    {category="Round-Effecting Commands", command="/skipobj {obj#}", description="Skip objective"},
    {category="Round-Effecting Commands", command="/skipwave {wave#}", description="Skip to wave"},
    {category="Round-Effecting Commands", command="/worldwide", description="Enable all nation choices"},
    {category="Round-Effecting Commands", command="/addnation {nation}", description="Add a nation to the map"},
    {category="Round-Effecting Commands", command="/removenation {nation}", description="Remove a nation from the map"},
    {category="Round-Effecting Commands", command="/callescape", description="Trigger Berezina escape objective"},
    {category="Round-Effecting Commands", command="/sethround {wave#}", description="Set Saint Petersburg wave"},
    {category="Round-Effecting Commands", command="/togglethinking", description="Toggle zombie and bot AI"},
    {category="Round-Effecting Commands", command="/toggleblind", description="Toggle zombie damage protection"},
    {category="Round-Effecting Commands", command="/bot {class} {amount} {weapon} n={nation} r={regiment}", description="Spawn bots"},
    {category="Player Commands", command="/bring {username}", description="Teleport player to you"},
    {category="Player Commands", command="/teleport {username}", description="Teleport player to you"},
    {category="Player Commands", command="/getoverhere {username}", description="Teleport player to you"},
    {category="Player Commands", command="/grab {username}", description="Teleport player to you"},
    {category="Player Commands", command="/cannontk", description="Toggle cannon teamkilling"},
    {category="Player Commands", command="/cannonfight", description="Toggle cannon teamkilling"},
    {category="Player Commands", command="/breaklegs {username}", description="Break player's legs"},
    {category="Player Commands", command="/break {username}", description="Break player's legs"},
    {category="Player Commands", command="/immobilize {username}", description="Immobilize player"},
    {category="Player Commands", command="/ff", description="Toggle friendly fire"},
    {category="Player Commands", command="/fighting", description="Toggle friendly fire"},
    {category="Player Commands", command="/fight", description="Toggle friendly fire"},
    {category="Player Commands", command="/friendlyfire", description="Toggle friendly fire"},
    {category="Player Commands", command="/kill {username}", description="Kill designated player"},
    {category="Player Commands", command="/to {username}", description="Teleport to another player"},
    {category="Player Commands", command="/gooverto {username}", description="Teleport to another player"},
    {category="Player Commands", command="/respawn {username}", description="Respawn a player"},
    {category="Player Commands", command="/restore {username}", description="Respawn a player in place"},
    {category="Player Commands", command="/sethealth {username} {hp#} {n}", description="Set player health"},
    {category="Player Commands", command="/addstatus {username} {effect}", description="Apply a status effect"},
    {category="Player Commands", command="/setblemlish", description="Listed in supplied command list"},
    {category="Player Commands", command="/refill", description="Refill items"},
    {category="Player Commands", command="/chaplain", description="Unlock Chaplain class (listed as nonfunctional)"},
    {category="Player Commands", command="/chaplainunlock", description="Unlock Chaplain class (listed as nonfunctional)"},
    {category="Player Commands", command="/chaplainlock", description="Lock Chaplain class (listed as nonfunctional)"},
    {category="Player Commands", command="/buildlimit", description="Disable building limit"},
    {category="Player Commands", command="/ragdollcleaner {true, false, clean}", description="Manage ragdolls"},
    {category="Player Commands", command="/warp", description="Teleport toward mouse direction"},
    {category="Player Commands", command="/goto", description="Teleport toward mouse direction"},
    {category="Player Commands", command="/infect {#}", description="Set infection stage"},
    {category="Player Commands", command="/explosion", description="Trigger Bomber explosion"},
    {category="Player Commands", command="/impaled {username}", description="Impale a player"},
    {category="Player Commands", command="/incapacitate {username}", description="Impale a player"},
    {category="Miscellaneous/Fun Commands", command="/bigserver", description="Increase server player limit (restricted)"},
    {category="Miscellaneous/Fun Commands", command="/avatar {user id}", description="Equip avatar by user ID"},
    {category="Miscellaneous/Fun Commands", command="/toggleaprilfools 2023", description="Toggle 2023 April Fools theme"},
    {category="Miscellaneous/Fun Commands", command="/toggleaprilfools 2024", description="Toggle 2024 April Fools theme"},
    {category="Miscellaneous/Fun Commands", command="/clearinventory {username}", description="Clear player inventory"},
    {category="Miscellaneous/Fun Commands", command="/console", description="Open console"},
    {category="Miscellaneous/Fun Commands", command="/cmd", description="Show server info command hint"},
    {category="Miscellaneous/Fun Commands", command="/info", description="Show server information"},
    {category="Miscellaneous/Fun Commands", command="/hide", description="Disguise player name (restricted)"},
    {category="Miscellaneous/Fun Commands", command="/ping", description="Show current ping"},
    {category="Miscellaneous/Fun Commands", command="/help", description="Show Roblox commands"},
    {category="Miscellaneous/Fun Commands", command="/mute {username}", description="Mute a player"},
    {category="Miscellaneous/Fun Commands", command="/unmute {username}", description="Unmute a player"},
    {category="Miscellaneous/Fun Commands", command="/rejoin", description="Rejoin current server"},
    {category="Miscellaneous/Fun Commands", command="/Abduct {username}", description="Alien abduction joke command"},
    {category="Miscellaneous/Fun Commands", command="/Zeep {username}", description="Alien abduction joke command"},
    {category="Miscellaneous/Fun Commands", command="/Smite {username}", description="Strike player with lightning"},
    {category="Miscellaneous/Fun Commands", command="/getownednoob {username}", description="Strike player with lightning"},
    {category="Miscellaneous/Fun Commands", command="/Arthur {username}", description="Transform chosen player"},
    {category="Miscellaneous/Fun Commands", command="/Marston {username}", description="Transform chosen player"},
    {category="Miscellaneous/Fun Commands", command="/alien {username}", description="Transform player into an alien (restricted)"},
    {category="Miscellaneous/Fun Commands", command="/serverbrowser", description="Open server browser"},
    {category="Miscellaneous/Fun Commands", command="/playersalive", description="Show number of living players"},
    {category="Miscellaneous/Fun Commands", command="/createcustomserver", description="Open custom server creation"},
    {category="Miscellaneous/Fun Commands", command="/ghostrain", description="Rain grenades on chosen player"},
    {category="Miscellaneous/Fun Commands", command="/mortarstrike {amount}", description="Call a mortar strike"},
}

local function buildPanel()
    panel = create("Frame", {
        Size = UDim2.new(0.90, 0, 0.82, 0),
        Position = UDim2.new(0.05, 0, 0.08, 0),
        BackgroundColor3 = Color3.fromRGB(24, 27, 33),
        BorderSizePixel = 0,
        Visible = false
    }, screenGui)
    corner(panel, 10)

    panelTitle = create("TextLabel", {
        Size = UDim2.new(1, -88, 0, 34),
        Position = UDim2.fromOffset(10, 5),
        BackgroundTransparency = 1,
        Text = tr("title"),
        TextColor3 = Color3.fromRGB(245, 247, 250),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd
    }, panel)

    minimizedButton = create("TextButton", {
        Size = UDim2.fromOffset(32, 28),
        Position = UDim2.new(1, -72, 0, 7),
        Text = "−"
    }, panel)
    styleButton(minimizedButton)

    local closeButton = create("TextButton", {
        Size = UDim2.fromOffset(32, 28),
        Position = UDim2.new(1, -36, 0, 7),
        Text = "×"
    }, panel)
    styleButton(closeButton, Color3.fromRGB(125, 55, 60))

    versionLabel = create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 18),
        Position = UDim2.fromOffset(10, 36),
        BackgroundTransparency = 1,
        Text = tr("version"),
        TextColor3 = Color3.fromRGB(155, 165, 180),
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    }, panel)

    local catalogFrame
    local tabs = create("ScrollingFrame", {
        Position = UDim2.fromOffset(10, 56),
        Size = UDim2.new(1, -20, 0, 30),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        CanvasSize = UDim2.new(),
        ClipsDescendants = true
    }, panel)
    local tabLayout = create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, tabs)

    local mainTab = create("TextButton", {
        Size = UDim2.fromOffset(112, 28),
        Text = tr("mainTab"),
        LayoutOrder = 1
    }, tabs)
    styleButton(mainTab, Color3.fromRGB(49, 115, 88))

    local commandsTab = create("TextButton", {
        Size = UDim2.fromOffset(112, 28),
        Text = tr("commandsTab"),
        LayoutOrder = 2
    }, tabs)
    styleButton(commandsTab, Color3.fromRGB(60, 67, 80))

    addButton = create("TextButton", {
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.fromOffset(10, 92),
        Text = tr("add")
    }, panel)
    styleButton(addButton, Color3.fromRGB(45, 105, 80))

    list = create("ScrollingFrame", {
        Position = UDim2.fromOffset(10, 130),
        Size = UDim2.new(1, -20, 1, -140),
        BackgroundColor3 = Color3.fromRGB(32, 36, 44),
        BorderSizePixel = 0,
        ScrollBarThickness = 6,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        ClipsDescendants = true
    }, panel)
    corner(list, 6)

    local grid = create("UIGridLayout", {
        CellSize = UDim2.new(0.5, -7, 0, 154),
        CellPadding = UDim2.fromOffset(6, 6),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, list)

    create("UIPadding", {
        PaddingTop = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6)
    }, list)

    minimizedButton.Activated:Connect(function()
        minimized = not minimized
        list.Visible = not minimized
        addButton.Visible = not minimized
        versionLabel.Visible = not minimized
        tabs.Visible = not minimized
        if catalogFrame then
            catalogFrame.Visible = not minimized and catalogFrame.Visible
        end
        panel.Size = minimized
            and UDim2.new(0.90, 0, 0, 44)
            or UDim2.new(0.90, 0, 0.82, 0)
        minimizedButton.Text = minimized and "+" or "−"
    end)

    closeButton.Activated:Connect(function()
        panel.Visible = false
        languageFrame.Visible = true
    end)

    addButton.Activated:Connect(function()
        nextId += 1
        table.insert(commands, {
            id = nextId,
            name = tr("name") .. " " .. nextId,
            text = "/text",
            enabled = false,
            trigger = "manual",
            interval = 5,
            target = ""
        })
        renderCommands()
        list.CanvasPosition = Vector2.new(0, math.max(0, list.AbsoluteCanvasSize.Y))
    end)

    renderCommands = function()
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end

        local triggerKeys = {
            "manual", "repeat", "selfRespawn", "allRespawn",
            "targetRespawn", "allDead", "targetDead"
        }
        local triggerLabels = {
            manual = tr("manual"),
            ["repeat"] = tr("repeatTrigger"),
            selfRespawn = tr("selfRespawn"),
            allRespawn = tr("allRespawn"),
            targetRespawn = tr("targetRespawn"),
            allDead = tr("allDead"),
            targetDead = tr("targetDead")
        }

        for _, data in ipairs(commands) do
            local card = create("Frame", {
                Name = "CommandCard_" .. data.id,
                BackgroundColor3 = Color3.fromRGB(49, 54, 64),
                BorderSizePixel = 0,
                LayoutOrder = data.id
            }, list)
            corner(card, 7)

            local nameBox = create("TextBox", {
                Position = UDim2.fromOffset(5, 5),
                Size = UDim2.new(1, -10, 0, 24),
                Text = data.name,
                PlaceholderText = tr("name"),
                ClearTextOnFocus = false,
                BackgroundColor3 = Color3.fromRGB(35, 39, 47),
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 11,
                Font = Enum.Font.Gotham,
                BorderSizePixel = 0
            }, card)
            corner(nameBox, 4)
            nameBox.FocusLost:Connect(function()
                data.name = nameBox.Text
            end)

            local commandBox = create("TextBox", {
                Position = UDim2.fromOffset(5, 33),
                Size = UDim2.new(1, -10, 0, 24),
                Text = data.text,
                PlaceholderText = tr("command"),
                ClearTextOnFocus = false,
                BackgroundColor3 = Color3.fromRGB(35, 39, 47),
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 10,
                Font = Enum.Font.Gotham,
                BorderSizePixel = 0
            }, card)
            corner(commandBox, 4)
            commandBox.FocusLost:Connect(function()
                data.text = commandBox.Text
            end)

            local toggle = create("TextButton", {
                Position = UDim2.fromOffset(5, 61),
                Size = UDim2.new(0.34, -3, 0, 23),
                Text = data.enabled and tr("on") or tr("off")
            }, card)
            styleButton(toggle, data.enabled
                and Color3.fromRGB(42, 130, 82)
                or Color3.fromRGB(104, 63, 67))
            toggle.Activated:Connect(function()
                data.enabled = not data.enabled
                toggle.Text = data.enabled and tr("on") or tr("off")
                toggle.BackgroundColor3 = data.enabled
                    and Color3.fromRGB(42, 130, 82)
                    or Color3.fromRGB(104, 63, 67)
            end)

            local triggerButton = create("TextButton", {
                Position = UDim2.new(0.34, 3, 0, 61),
                Size = UDim2.new(0.66, -8, 0, 23),
                Text = triggerLabels[data.trigger],
                TextTruncate = Enum.TextTruncate.AtEnd
            }, card)
            styleButton(triggerButton, Color3.fromRGB(65, 76, 96))
            triggerButton.Activated:Connect(function()
                local current = 1
                for i, key in ipairs(triggerKeys) do
                    if key == data.trigger then current = i break end
                end
                current = current % #triggerKeys + 1
                data.trigger = triggerKeys[current]
                triggerButton.Text = triggerLabels[data.trigger]
            end)

            local detail = create("TextBox", {
                Position = UDim2.fromOffset(5, 88),
                Size = UDim2.new(1, -10, 0, 23),
                Text = data.trigger == "targetRespawn" or data.trigger == "targetDead"
                    and data.target or tostring(data.interval),
                PlaceholderText = (data.trigger == "targetRespawn" or data.trigger == "targetDead")
                    and tr("target") or tr("cycle"),
                ClearTextOnFocus = false,
                BackgroundColor3 = Color3.fromRGB(35, 39, 47),
                TextColor3 = Color3.new(1, 1, 1),
                TextSize = 10,
                Font = Enum.Font.Gotham,
                BorderSizePixel = 0
            }, card)
            corner(detail, 4)
            detail.Text = (data.trigger == "targetRespawn" or data.trigger == "targetDead")
                and data.target or tostring(data.interval)
            detail.FocusLost:Connect(function()
                if data.trigger == "targetRespawn" or data.trigger == "targetDead" then
                    data.target = detail.Text
                else
                    data.interval = math.clamp(tonumber(detail.Text) or 5, 1, 3600)
                end
            end)

            local runButton = create("TextButton", {
                Position = UDim2.fromOffset(5, 116),
                Size = UDim2.new(0.58, -4, 0, 25),
                Text = tr("run")
            }, card)
            styleButton(runButton, Color3.fromRGB(53, 104, 137))
            runButton.Activated:Connect(function()
                data.text = commandBox.Text
                data.name = nameBox.Text
                fireCommand(data)
            end)

            local deleteButton = create("TextButton", {
                Position = UDim2.new(0.58, 2, 0, 116),
                Size = UDim2.new(0.42, -7, 0, 25),
                Text = tr("delete")
            }, card)
            styleButton(deleteButton, Color3.fromRGB(125, 55, 60))
            deleteButton.Activated:Connect(function()
                for i, command in ipairs(commands) do
                    if command == data then
                        table.remove(commands, i)
                        break
                    end
                end
                renderCommands()
            end)
        end
    end

    renderCommands()

    catalogFrame = create("Frame", {
        Position = UDim2.fromOffset(10, 92),
        Size = UDim2.new(1, -20, 1, -102),
        BackgroundColor3 = Color3.fromRGB(32, 36, 44),
        BorderSizePixel = 0,
        Visible = false
    }, panel)
    corner(catalogFrame, 6)

    local catalogTitleLabel = create("TextLabel", {
        Position = UDim2.fromOffset(8, 5),
        Size = UDim2.new(1, -16, 0, 22),
        BackgroundTransparency = 1,
        Text = tr("catalogTitle"),
        TextColor3 = Color3.fromRGB(245, 247, 250),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    }, catalogFrame)

    local searchBox = create("TextBox", {
        Position = UDim2.fromOffset(8, 31),
        Size = UDim2.new(1, -16, 0, 30),
        Text = "",
        PlaceholderText = tr("searchPlaceholder"),
        ClearTextOnFocus = false,
        BackgroundColor3 = Color3.fromRGB(35, 39, 47),
        TextColor3 = Color3.new(1, 1, 1),
        PlaceholderColor3 = Color3.fromRGB(160, 168, 180),
        TextSize = 12,
        Font = Enum.Font.Gotham,
        BorderSizePixel = 0
    }, catalogFrame)
    corner(searchBox, 5)

    local catalogList = create("ScrollingFrame", {
        Position = UDim2.fromOffset(8, 68),
        Size = UDim2.new(1, -16, 1, -76),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 6,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        ClipsDescendants = true
    }, catalogFrame)
    create("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, catalogList)
    create("UIPadding", {
        PaddingTop = UDim.new(0, 3),
        PaddingBottom = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 2),
        PaddingRight = UDim.new(0, 2)
    }, catalogList)

    local function addCatalogCommand(item)
        local existing
        for _, data in ipairs(commands) do
            if data.text:lower() == item.command:lower() then
                existing = data
                break
            end
        end

        if not existing then
            nextId += 1
            existing = {
                id = nextId,
                name = item.command,
                text = item.command,
                enabled = false,
                trigger = "manual",
                interval = 5,
                target = ""
            }
            table.insert(commands, existing)
        end

        catalogFrame.Visible = false
        list.Visible = true
        addButton.Visible = true
        mainTab.BackgroundColor3 = Color3.fromRGB(49, 115, 88)
        commandsTab.BackgroundColor3 = Color3.fromRGB(60, 67, 80)
        renderCommands()

        task.defer(function()
            local card = list:FindFirstChild("CommandCard_" .. existing.id)
            if card then
                list.CanvasPosition = Vector2.new(0, math.max(0, card.AbsolutePosition.Y - list.AbsolutePosition.Y + list.CanvasPosition.Y))
                local commandBox = card:FindFirstChildWhichIsA("TextBox")
                if commandBox then
                    commandBox:CaptureFocus()
                    commandBox.CursorPosition = #commandBox.Text + 1
                end
            end
        end)
    end

    local function refreshCatalog()
        for _, child in ipairs(catalogList:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then
                child:Destroy()
            end
        end

        local query = searchBox.Text:lower():gsub("^%s+", ""):gsub("%s+$", "")
        local count = 0
        for index, item in ipairs(catalogCommands) do
            local searchable = (item.command .. " " .. item.category .. " " .. item.description):lower()
            if query == "" or searchable:find(query, 1, true) then
                count += 1
                local result = create("TextButton", {
                    Name = "CatalogResult_" .. index,
                    Size = UDim2.new(1, -4, 0, 56),
                    BackgroundColor3 = Color3.fromRGB(49, 54, 64),
                    BorderSizePixel = 0,
                    Text = "",
                    LayoutOrder = index,
                    AutoButtonColor = true
                }, catalogList)
                corner(result, 6)

                create("TextLabel", {
                    Position = UDim2.fromOffset(8, 4),
                    Size = UDim2.new(1, -16, 0, 22),
                    BackgroundTransparency = 1,
                    Text = item.command,
                    TextColor3 = Color3.fromRGB(245, 247, 250),
                    TextSize = 11,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd
                }, result)
                create("TextLabel", {
                    Position = UDim2.fromOffset(8, 26),
                    Size = UDim2.new(1, -16, 0, 24),
                    BackgroundTransparency = 1,
                    Text = item.category .. " · " .. item.description,
                    TextColor3 = Color3.fromRGB(170, 181, 196),
                    TextSize = 9,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd
                }, result)
                result.Activated:Connect(function()
                    addCatalogCommand(item)
                end)
            end
        end

        if count == 0 then
            create("TextLabel", {
                Size = UDim2.new(1, -4, 0, 36),
                BackgroundTransparency = 1,
                Text = tr("noResults"),
                TextColor3 = Color3.fromRGB(170, 181, 196),
                TextSize = 12,
                Font = Enum.Font.Gotham,
                LayoutOrder = 1
            }, catalogList)
        end
    end

    searchBox:GetPropertyChangedSignal("Text"):Connect(refreshCatalog)
    refreshCatalog()

    mainTab.Activated:Connect(function()
        catalogFrame.Visible = false
        list.Visible = true
        addButton.Visible = true
        mainTab.BackgroundColor3 = Color3.fromRGB(49, 115, 88)
        commandsTab.BackgroundColor3 = Color3.fromRGB(60, 67, 80)
    end)

    commandsTab.Activated:Connect(function()
        list.Visible = false
        addButton.Visible = false
        catalogFrame.Visible = true
        mainTab.BackgroundColor3 = Color3.fromRGB(60, 67, 80)
        commandsTab.BackgroundColor3 = Color3.fromRGB(49, 115, 88)
    end)

end

local function chooseLanguage(code)
    selectedLanguage = code
    languageFrame.Visible = false
    buildPanel()
    panel.Visible = true
end

local languages = {
    {code = "vi", label = "🇻🇳  Tiếng Việt"},
    {code = "en", label = "🇬🇧  English"},
    {code = "zh", label = "🇨🇳  中文"}
}

for i, item in ipairs(languages) do
    local button = create("TextButton", {
        Size = UDim2.new(1, -28, 0, 42),
        Position = UDim2.fromOffset(14, 58 + (i - 1) * 50),
        Text = item.label
    }, languageFrame)
    styleButton(button, Color3.fromRGB(55, 70, 89))
    button.Activated:Connect(function()
        chooseLanguage(item.code)
    end)
end

task.spawn(function()
    for i = 0, 100 do
        loadingStatus.Text = LANG.vi.loading .. " " .. i .. "%"
        TweenService:Create(
            barFill,
            TweenInfo.new(0.09),
            {Size = UDim2.new(i / 100, 0, 1, 0)}
        ):Play()
        task.wait(0.1)
    end
    loading:Destroy()
    languageFrame.Visible = true
end)

task.spawn(function()
    while screenGui.Parent do
        for _, data in ipairs(commands) do
            if data.enabled and data.trigger == "repeat" then
                data._nextRun = data._nextRun or (os.clock() + data.interval)
                if os.clock() >= data._nextRun then
                    fireCommand(data)
                    data._nextRun = os.clock() + math.max(1, data.interval)
                end
            else
                data._nextRun = nil
            end
        end
        task.wait(0.2)
    end
end)
