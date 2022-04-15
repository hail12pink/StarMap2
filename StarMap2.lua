local StarMap = GetPartFromPort(1, "StarMap")
local Telescope = GetPartFromPort(1, "Telescope")
local Screen = GetPartFromPort(1, "TouchScreen")
local PlanetInfo = GetPartFromPort(2, "Screen")

local systems = {}
local planets = {}

for coord, data in StarMap:GetSystems() do
    systems[coord] = data
end

for coord, data in StarMap:GetBodies() do
    planets[coord] = data
end

--print(JSONEncode(systems))
--print(JSONEncode(planets))
print(string.rep("\n", 5000))

Screen:ClearElements()

local currentMode = "Planets"
local currentSystem = nil

local Scanning = Screen:CreateElement("TextLabel", {
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    Size = UDim2.fromScale(1, 1);
    Text = "Scanning...";
    TextScaled = true;
    TextColor3 = Color3.fromRGB(255, 255, 255);
    Font = "SciFi";
})

for coord, data in pairs(systems) do
    if currentSystem then break end

    for coord2, data2 in pairs(planets) do
        local newCoords = coord .. ", " .. coord2 .. ", true"
        --print(newCoords)

        Telescope.ViewCoordinates = newCoords
        --print(Telescope.ViewCoordinates)

        Telescope:WhenRegionLoads(nil)

        --print("incoming")
        local success, data = pcall(Telescope.GetCoordinate)
        if success then
            print(newCoords)
            print(JSONEncode(data))
            
            if data.Type == "Planet" then
                currentSystem = coord
                break
            end
        else
            print("no region")
            --print("error: " .. tostring(data))
        end

        task.wait()
    end
end

Scanning:Destroy()

local Grid = Screen:CreateElement("ImageLabel", {
    Size = UDim2.fromScale(1, 1);
    BackgroundTransparency = 1;
    Image = "rbxassetid://2600521419";
    ScaleType = "Tile";
    TileSize = UDim2.fromScale(0.1, 0.1);
})

local UsedSpace = Screen:CreateElement("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5);
    Position = UDim2.fromScale(0.5, 0.5);
    Size = UDim2.fromScale(0.8, 0.8);
    BackgroundTransparency = 0.6;
    ClipsDescendants = false;
})

local Mode = Screen:CreateElement("TextButton", {
    AnchorPoint = Vector2.new(1, 1);
    BackgroundColor3 = Color3.fromRGB(0, 134, 206);
    BorderColor3 = Color3.fromRGB(255, 255, 255);
    BorderMode = "Inset";
    BorderSizePixel = 5;
    Size = UDim2.fromScale(0.2, 0.1);
    Position = UDim2.fromScale(1, 1);
    Font = "SciFi";
    Text = "Mode";
    TextColor3 = Color3.fromRGB(255, 255, 255);
    TextScaled = true;
    TextStrokeTransparency = 0.7;
})

local Error = Screen:CreateElement("TextLabel", {
    AnchorPoint = Vector2.new(1, 1);
    BackgroundColor3 = Color3.fromRGB(255, 0, 0);
    BorderColor3 = Color3.fromRGB(255, 255, 255);
    BorderMode = "Inset";
    BorderSizePixel = 5;
    Size = UDim2.fromScale(0.2, 0.1);
    Position = UDim2.fromScale(0.2, 1);
    Font = "SciFi";
    Text = "System not found.";
    TextColor3 = Color3.fromRGB(255, 255, 255);
    TextScaled = true;
    TextStrokeTransparency = 0.7;
})

if not currentSystem then
    print("System not found.")
    currentSystem = "0, 0"
else
    print("System found.")
    Error:Destroy()
end

Grid:AddChild(UsedSpace)

print(currentSystem)

for coord, data in pairs(planets) do
    local coordSplit = coord:gsub(" ", ""):split(",")
    print(coordSplit[1], coordSplit[2])
    --print(JSONEncode(data))

    local circle = Screen:CreateElement("ImageButton", {
        AnchorPoint = Vector2.new(0.5, 0.5);
        Size = UDim2.fromScale(0.05, 0.05);
        Position = UDim2.fromScale(coordSplit[1]/20, -coordSplit[2]/20) + UDim2.fromScale(0.5, 0.5);
    })

    print(circle.Position)
    local coordSplit2 = currentSystem:split(",")

    local fullCoords = {
        coordSplit2[1];
        coordSplit2[2];
        coordSplit[1];
        coordSplit[2];
    }

    local lastPosition = circle.Position + UDim2.fromScale(-0.0625 - 0.01, -0.075);

    for i = 1, 2 do
        local coord = Screen:CreateElement("TextLabel", {
            AnchorPoint = circle.AnchorPoint;
            BackgroundTransparency = 1;
            Size = UDim2.fromScale(0.025, 0.02);
            Position = lastPosition + UDim2.fromScale(0.075);
            ZIndex = 100;
            Text = coordSplit[i];
            TextSize = 30;
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextStrokeTransparency = 0;
        })

        UsedSpace:AddChild(coord)
        lastPosition = coord.Position

        task.wait()
    end

    circle.MouseButton1Click:Connect(function()
        Telescope:Configure{ViewCoordinates = coord}
        local data = Telescope:GetCoordinate()
    end)

    UsedSpace:AddChild(circle)
end