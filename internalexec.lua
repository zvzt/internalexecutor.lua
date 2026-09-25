if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local TextService=game:GetService("TextService")
local Workspace=game:GetService("Workspace")

local player=Players.LocalPlayer
local playerGui=player:WaitForChild("PlayerGui")
local env=getgenv and getgenv() or _G
local targetParent=playerGui

pcall(function()
	if gethui then
		targetParent=gethui()
	end
end)

if env.InternalExecutorCleanup then
	pcall(env.InternalExecutorCleanup)
end

for _,parent in ipairs({targetParent,playerGui}) do
	local old=parent:FindFirstChild("InternalExecutor")
	if old then
		old:Destroy()
	end
end

local WINDOW=Color3.fromRGB(0,0,0)
local WINDOW_STROKE=Color3.fromRGB(45,45,50)
local PANEL=Color3.fromRGB(18,18,22)
local PANEL_STROKE=Color3.fromRGB(32,32,36)
local BUTTON=Color3.fromRGB(24,24,28)
local BUTTON_HOVER=Color3.fromRGB(32,32,38)
local BUTTON_ACTIVE=Color3.fromRGB(48,48,58)
local BUTTON_STROKE=Color3.fromRGB(40,40,48)
local TEXT=Color3.fromRGB(240,240,245)
local BUTTON_TEXT=Color3.fromRGB(225,225,232)
local MUTED=Color3.fromRGB(120,120,130)
local RED=Color3.fromRGB(255,100,100)
local GREEN=Color3.fromRGB(110,220,140)

local FULL_WIDTH=540
local FULL_HEIGHT=360
local COLLAPSED_HEIGHT=38
local LINE_HEIGHT=18
local GUTTER_WIDTH=42
local TOP_PADDING=4

local connections={}
local destroyed=false
local collapsed=false
local sizeTween=nil
local updating=false

local function connect(signal,callback)
	local connection=signal:Connect(callback)
	table.insert(connections,connection)
	return connection
end

local function corner(object,radius)
	local c=Instance.new("UICorner",object)
	c.CornerRadius=UDim.new(0,radius)
	return c
end

local function stroke(object,color,thickness)
	local s=Instance.new("UIStroke",object)
	s.Color=color
	s.Thickness=thickness
	s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
	return s
end

local gui=Instance.new("ScreenGui")
gui.Name="InternalExecutor"
gui.ResetOnSpawn=false
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.Parent=targetParent

local function cleanup()
	if destroyed then
		return
	end

	destroyed=true

	if sizeTween then
		pcall(function()
			sizeTween:Cancel()
		end)
	end

	for _,connection in ipairs(connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end

	table.clear(connections)

	pcall(function()
		gui:Destroy()
	end)

	if env.InternalExecutorCleanup==cleanup then
		env.InternalExecutorCleanup=nil
	end
end

env.InternalExecutorCleanup=cleanup

local function makeButton(parent,text,size,position)
	local button=Instance.new("TextButton",parent)
	button.Size=size
	button.Position=position
	button.BackgroundColor3=BUTTON
	button.BorderSizePixel=0
	button.AutoButtonColor=false
	button.Text=text
	button.TextColor3=BUTTON_TEXT
	button.TextSize=11
	button.Font=Enum.Font.GothamMedium

	corner(button,4)
	stroke(button,BUTTON_STROKE,1)

	connect(button.MouseEnter,function()
		TweenService:Create(
			button,
			TweenInfo.new(.1),
			{BackgroundColor3=BUTTON_HOVER}
		):Play()
	end)

	connect(button.MouseLeave,function()
		TweenService:Create(
			button,
			TweenInfo.new(.1),
			{BackgroundColor3=BUTTON}
		):Play()
	end)

	return button
end

local function makeDraggable(dragHandle,targetFrame)
	targetFrame=targetFrame or dragHandle

	local dragging=false
	local dragStart
	local startPos

	connect(dragHandle.InputBegan,function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1
			or input.UserInputType==Enum.UserInputType.Touch then

			dragging=true
			dragStart=input.Position

			startPos=Vector2.new(
				targetFrame.Position.X.Offset,
				targetFrame.Position.Y.Offset
			)
		end
	end)

	connect(UIS.InputChanged,function(input)
		if not dragging then
			return
		end

		if input.UserInputType~=Enum.UserInputType.MouseMovement
			and input.UserInputType~=Enum.UserInputType.Touch then
			return
		end

		local camera=Workspace.CurrentCamera
		if not camera then
			return
		end

		local delta=input.Position-dragStart
		local size=targetFrame.AbsoluteSize
		local viewport=camera.ViewportSize
		local topOffset=-57
		local bottomOffset=57

		local x=math.clamp(
			startPos.X+delta.X,
			0,
			math.max(0,viewport.X-size.X)
		)

		local y=math.clamp(
			startPos.Y+delta.Y,
			topOffset,
			math.max(
				topOffset,
				viewport.Y-size.Y-bottomOffset
			)
		)

		targetFrame.Position=UDim2.fromOffset(x,y)
	end)

	connect(UIS.InputEnded,function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1
			or input.UserInputType==Enum.UserInputType.Touch then

			dragging=false
		end
	end)
end

local main=Instance.new("Frame",gui)
main.Name="SlateWindow_InternalExecutor"
main.Size=UDim2.fromOffset(FULL_WIDTH,FULL_HEIGHT)
main.BackgroundColor3=WINDOW
main.BorderSizePixel=0
main.ClipsDescendants=true
main.Active=true

corner(main,10)
stroke(main,WINDOW_STROKE,1.2)

local camera=Workspace.CurrentCamera

if camera then
	local viewport=camera.ViewportSize

	main.Position=UDim2.fromOffset(
		math.floor((viewport.X-FULL_WIDTH)/2),
		math.floor((viewport.Y-FULL_HEIGHT)/2)
	)
else
	main.Position=UDim2.new(.5,-270,.5,-180)
end

local header=Instance.new("Frame",main)
header.Name="HeaderBar"
header.Size=UDim2.new(1,0,0,38)
header.BackgroundTransparency=1
header.BorderSizePixel=0
header.Active=true

local title=Instance.new("TextLabel",header)
title.Size=UDim2.new(1,-210,1,0)
title.Position=UDim2.fromOffset(12,0)
title.BackgroundTransparency=1
title.Text="Internal Executor"
title.TextColor3=TEXT
title.TextSize=20
title.TextXAlignment=Enum.TextXAlignment.Left
title.FontFace=Font.new(
	"rbxasset://fonts/families/SourceSansPro.json",
	Enum.FontWeight.Bold,
	Enum.FontStyle.Normal
)

local downloadBtn=makeButton(
	header,
	"Download",
	UDim2.fromOffset(78,24),
	UDim2.new(1,-144,0,7)
)

local minimizeBtn=Instance.new("TextButton",header)
minimizeBtn.Size=UDim2.fromOffset(20,20)
minimizeBtn.Position=UDim2.new(1,-52,0,9)
minimizeBtn.BackgroundTransparency=1
minimizeBtn.BorderSizePixel=0
minimizeBtn.AutoButtonColor=false
minimizeBtn.Text="—"
minimizeBtn.TextSize=16
minimizeBtn.TextColor3=Color3.fromRGB(150,150,160)
minimizeBtn.Font=Enum.Font.GothamBold
minimizeBtn.ZIndex=20

local closeBtn=Instance.new("TextButton",header)
closeBtn.Size=UDim2.fromOffset(20,20)
closeBtn.Position=UDim2.new(1,-28,0,9)
closeBtn.BackgroundTransparency=1
closeBtn.BorderSizePixel=0
closeBtn.AutoButtonColor=false
closeBtn.Text="X"
closeBtn.TextSize=14
closeBtn.TextColor3=Color3.fromRGB(150,150,160)
closeBtn.Font=Enum.Font.GothamBold
closeBtn.ZIndex=20

local function headerHover(button)
	connect(button.MouseEnter,function()
		TweenService:Create(
			button,
			TweenInfo.new(.15),
			{TextColor3=TEXT}
		):Play()
	end)

	connect(button.MouseLeave,function()
		TweenService:Create(
			button,
			TweenInfo.new(.15),
			{TextColor3=Color3.fromRGB(150,150,160)}
		):Play()
	end)
end

headerHover(minimizeBtn)
headerHover(closeBtn)

local dragZone=Instance.new("Frame",header)
dragZone.Size=UDim2.new(1,-155,1,0)
dragZone.BackgroundTransparency=1
dragZone.BorderSizePixel=0
dragZone.Active=true

makeDraggable(dragZone,main)

local content=Instance.new("Frame",main)
content.Name="Content"
content.Position=UDim2.new(0,10,0,42)
content.Size=UDim2.new(1,-20,1,-92)
content.BackgroundTransparency=1

local editorPanel=Instance.new("Frame",content)
editorPanel.Size=UDim2.new(1,0,1,0)
editorPanel.BackgroundColor3=PANEL
editorPanel.BorderSizePixel=0
editorPanel.ClipsDescendants=true

corner(editorPanel,9)
stroke(editorPanel,PANEL_STROKE,1)

local editorScroll=Instance.new("ScrollingFrame",editorPanel)
editorScroll.Name="EditorScroll"
editorScroll.Size=UDim2.new(1,-4,1,-4)
editorScroll.Position=UDim2.fromOffset(2,2)
editorScroll.BackgroundTransparency=1
editorScroll.BorderSizePixel=0
editorScroll.ScrollBarThickness=3
editorScroll.ScrollBarImageTransparency=.25
editorScroll.ScrollingDirection=Enum.ScrollingDirection.Y
editorScroll.ElasticBehavior=Enum.ElasticBehavior.Never
editorScroll.CanvasSize=UDim2.fromOffset(0,0)

local editorContent=Instance.new("Frame",editorScroll)
editorContent.Size=UDim2.new(1,0,0,LINE_HEIGHT)
editorContent.BackgroundTransparency=1
editorContent.BorderSizePixel=0

local gutter=Instance.new("Frame",editorContent)
gutter.Size=UDim2.new(0,GUTTER_WIDTH,1,0)
gutter.BackgroundColor3=Color3.fromRGB(14,14,18)
gutter.BorderSizePixel=0

local lineNumbers=Instance.new("TextLabel",gutter)
lineNumbers.Position=UDim2.fromOffset(0,TOP_PADDING)
lineNumbers.Size=UDim2.new(1,0,0,LINE_HEIGHT)
lineNumbers.BackgroundTransparency=1
lineNumbers.Text="1"
lineNumbers.TextColor3=MUTED
lineNumbers.TextSize=14
lineNumbers.Font=Enum.Font.Code
lineNumbers.TextXAlignment=Enum.TextXAlignment.Center
lineNumbers.TextYAlignment=Enum.TextYAlignment.Top

local viewport=Instance.new("Frame",editorContent)
viewport.Position=UDim2.new(0,GUTTER_WIDTH,0,0)
viewport.Size=UDim2.new(1,-GUTTER_WIDTH,1,0)
viewport.BackgroundTransparency=1
viewport.BorderSizePixel=0
viewport.ClipsDescendants=true

local editor=Instance.new("TextBox",viewport)
editor.Name="Input"
editor.Position=UDim2.fromOffset(6,TOP_PADDING)
editor.Size=UDim2.new(1,-12,0,LINE_HEIGHT)
editor.BackgroundTransparency=1
editor.BorderSizePixel=0
editor.ClearTextOnFocus=false
editor.MultiLine=true
editor.TextWrapped=false
editor.TextXAlignment=Enum.TextXAlignment.Left
editor.TextYAlignment=Enum.TextYAlignment.Top
editor.Font=Enum.Font.Code
editor.TextSize=14
editor.TextColor3=TEXT
editor.Text='print("hello")'

local function countLines(text)
	local count=1

	for _ in text:gmatch("\n") do
		count+=1
	end

	return count
end

local function getCursorLine(text,cursor)
	if cursor<=0 then
		return 1
	end

	local line=1

	for _ in text:sub(1,cursor-1):gmatch("\n") do
		line+=1
	end

	return line
end

local function getLineText(text,number)
	local current=1

	for line in (text.."\n"):gmatch("(.-)\n") do
		if current==number then
			return line
		end

		current+=1
	end

	return ""
end

local function textWidth(text)
	if text=="" then
		return 0
	end

	return TextService:GetTextSize(
		text,
		editor.TextSize,
		editor.Font,
		Vector2.new(1000000,100)
	).X
end

local function documentHeight()
	local lines=countLines(editor.Text)
	local measured=editor.TextBounds.Y

	if measured<=0 then
		measured=lines*LINE_HEIGHT
	end

	return math.max(
		editorPanel.AbsoluteSize.Y-4,
		measured+TOP_PADDING+4
	)
end

local function updateNumbers()
	local count=countLines(editor.Text)
	local numbers=table.create(count)

	for i=1,count do
		numbers[i]=tostring(i)
	end

	lineNumbers.Text=table.concat(numbers,"\n")
	lineNumbers.Size=UDim2.new(
		1,
		0,
		0,
		math.max(
			editorPanel.AbsoluteSize.Y-4,
			count*LINE_HEIGHT+TOP_PADDING
		)
	)
end

local function updateDocument()
	local height=documentHeight()

	editorContent.Size=UDim2.new(1,0,0,height)
	gutter.Size=UDim2.new(0,GUTTER_WIDTH,0,height)
	viewport.Size=UDim2.new(1,-GUTTER_WIDTH,0,height)
	editor.Size=UDim2.new(1,-12,0,height)
	editorScroll.CanvasSize=UDim2.new(0,0,0,height)
end

local function updateHorizontal()
	local cursorPosition=editor.CursorPosition

	if cursorPosition<=0 then
		return
	end

	local text=editor.Text
	local line=getCursorLine(text,cursorPosition)
	local currentLine=getLineText(text,line)
	local lineStart=1

	for i=cursorPosition-1,1,-1 do
		if text:sub(i,i)=="\n" then
			lineStart=i+1
			break
		end
	end

	local beforeCursor=text:sub(
		lineStart,
		cursorPosition-1
	)

	local cursorX=textWidth(beforeCursor)
	local totalX=textWidth(currentLine)
	local viewWidth=viewport.AbsoluteSize.X

	local currentOffset=math.max(
		0,
		6-editor.Position.X.Offset
	)

	local left=currentOffset
	local right=currentOffset+viewWidth-16
	local newOffset=nil

	if cursorX>right then
		newOffset=cursorX-viewWidth+16
	elseif cursorX<left then
		newOffset=math.max(0,cursorX-6)
	elseif totalX<right then
		newOffset=math.max(0,totalX-viewWidth+16)
	end

	if newOffset~=nil then
		editor.Position=UDim2.fromOffset(
			6-math.max(0,newOffset),
			TOP_PADDING
		)
	end
end

local function maxScroll()
	return math.max(
		0,
		editorScroll.CanvasSize.Y.Offset-editorScroll.AbsoluteSize.Y
	)
end

local function scrollToCursor()
	local cursorPosition=editor.CursorPosition

	if cursorPosition<=0 then
		return
	end

	local line=getCursorLine(
		editor.Text,
		cursorPosition
	)

	local top=TOP_PADDING+(line-1)*LINE_HEIGHT
	local bottom=top+LINE_HEIGHT
	local current=editorScroll.CanvasPosition.Y
	local view=editorScroll.AbsoluteSize.Y
	local target=current

	if bottom>current+view-6 then
		target=bottom-view+6
	elseif top<current+6 then
		target=top-6
	end

	target=math.clamp(
		target,
		0,
		maxScroll()
	)

	editorScroll.CanvasPosition=Vector2.new(
		0,
		target
	)
end

local function updateEditor()
	if updating then
		return
	end

	updating=true

	updateNumbers()
	updateDocument()

	updating=false

	updateHorizontal()

	task.defer(function()
		if not destroyed and editor.Parent then
			scrollToCursor()
		end
	end)
end

connect(editor:GetPropertyChangedSignal("Text"),updateEditor)

connect(editor:GetPropertyChangedSignal("CursorPosition"),function()
	if updating then
		return
	end

	updateHorizontal()

	task.defer(function()
		if not destroyed and editor.Parent then
			scrollToCursor()
		end
	end)
end)

connect(editorPanel:GetPropertyChangedSignal("AbsoluteSize"),function()
	task.defer(function()
		if not destroyed and editor.Parent then
			updateEditor()
		end
	end)
end)

connect(UIS.InputChanged,function(input)
	if input.UserInputType~=Enum.UserInputType.MouseWheel then
		return
	end

	local mousePosition=UIS:GetMouseLocation()
	local pos=editorPanel.AbsolutePosition
	local size=editorPanel.AbsoluteSize

	if mousePosition.X<pos.X
		or mousePosition.X>pos.X+size.X
		or mousePosition.Y<pos.Y
		or mousePosition.Y>pos.Y+size.Y then

		return
	end

	local target=editorScroll.CanvasPosition.Y
		-input.Position.Z*LINE_HEIGHT*3

	editorScroll.CanvasPosition=Vector2.new(
		0,
		math.clamp(
			target,
			0,
			maxScroll()
		)
	)
end)

local bottomBar=Instance.new("Frame",main)
bottomBar.Name="BottomBar"
bottomBar.Size=UDim2.new(1,-20,0,32)
bottomBar.Position=UDim2.new(0,10,1,-40)
bottomBar.BackgroundTransparency=1

local executeBtn=makeButton(
	bottomBar,
	"Execute",
	UDim2.fromOffset(72,26),
	UDim2.fromOffset(0,3)
)

local clearBtn=makeButton(
	bottomBar,
	"Clear",
	UDim2.fromOffset(72,26),
	UDim2.fromOffset(80,3)
)

local copyBtn=makeButton(
	bottomBar,
	"Copy",
	UDim2.fromOffset(72,26),
	UDim2.fromOffset(160,3)
)

local status=Instance.new("TextLabel",bottomBar)
status.Size=UDim2.new(1,-246,1,0)
status.Position=UDim2.fromOffset(246,0)
status.BackgroundTransparency=1
status.Text="Ready"
status.TextColor3=MUTED
status.TextSize=11
status.Font=Enum.Font.Code
status.TextXAlignment=Enum.TextXAlignment.Right

local statusVersion=0

local function setStatus(message,color)
	statusVersion+=1

	local version=statusVersion

	status.Text=message
	status.TextColor3=color or MUTED

	task.delay(2,function()
		if destroyed or version~=statusVersion then
			return
		end

		if status.Parent then
			status.Text="Ready"
			status.TextColor3=MUTED
		end
	end)
end

connect(executeBtn.MouseButton1Click,function()
	local source=editor.Text

	if source:match("^%s*$") then
		setStatus("Nothing to execute",MUTED)
		return
	end

	if type(loadstring)~="function" then
		setStatus("Execution unavailable",RED)
		return
	end

	local fn,compileError=loadstring(source)

	if not fn then
		warn(compileError)
		setStatus("Compile error - check console",RED)
		return
	end

	local success,runtimeError=pcall(fn)

	if not success then
		warn(runtimeError)
		setStatus("Runtime error - check console",RED)
		return
	end

	setStatus("Executed successfully",GREEN)
end)

connect(clearBtn.MouseButton1Click,function()
	updating=true

	editor.Text=""
	editor.CursorPosition=1
	editorScroll.CanvasPosition=Vector2.new(0,0)
	editor.Position=UDim2.fromOffset(6,TOP_PADDING)

	updating=false

	updateEditor()
	setStatus("Cleared",GREEN)
end)

connect(copyBtn.MouseButton1Click,function()
	if type(setclipboard)~="function" then
		setStatus("Clipboard unavailable",RED)
		return
	end

	local success=pcall(function()
		setclipboard(editor.Text)
	end)

	setStatus(
		success and "Copied to clipboard" or "Copy failed",
		success and GREEN or RED
	)
end)

connect(downloadBtn.MouseButton1Click,function()
	if type(writefile)~="function" then
		setStatus("Download unavailable",RED)
		return
	end

	local filename="script.lua"

	if type(isfile)=="function" then
		local index=1

		while isfile(filename) do
			filename="script"..index..".lua"
			index+=1
		end
	end

	local success=pcall(function()
		writefile(filename,editor.Text)
	end)

	if success then
		setStatus("Saved as "..filename,GREEN)
	else
		setStatus("Download failed",RED)
	end
end)

local function clampMain(height)
	local camera=Workspace.CurrentCamera

	if not camera then
		return
	end

	local viewport=camera.ViewportSize
	local topOffset=-57
	local bottomOffset=57

	local x=math.clamp(
		main.Position.X.Offset,
		0,
		math.max(
			0,
			viewport.X-FULL_WIDTH
		)
	)

	local y=math.clamp(
		main.Position.Y.Offset,
		topOffset,
		math.max(
			topOffset,
			viewport.Y-height-bottomOffset
		)
	)

	main.Position=UDim2.fromOffset(x,y)
end

local function setCollapsed(state)
	if collapsed==state then
		return
	end

	collapsed=state

	if sizeTween then
		sizeTween:Cancel()
		sizeTween=nil
	end

	if collapsed then
		content.Visible=false
		bottomBar.Visible=false

		sizeTween=TweenService:Create(
			main,
			TweenInfo.new(
				.18,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			),
			{
				Size=UDim2.fromOffset(
					FULL_WIDTH,
					COLLAPSED_HEIGHT
				)
			}
		)

		sizeTween:Play()
	else
		clampMain(FULL_HEIGHT)

		sizeTween=TweenService:Create(
			main,
			TweenInfo.new(
				.18,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			),
			{
				Size=UDim2.fromOffset(
					FULL_WIDTH,
					FULL_HEIGHT
				)
			}
		)

		local thisTween=sizeTween

		connect(thisTween.Completed,function()
			if destroyed then
				return
			end

			if not collapsed
				and sizeTween==thisTween
				and main.Parent then

				content.Visible=true
				bottomBar.Visible=true
				updateEditor()
			end
		end)

		thisTween:Play()
	end
end

connect(minimizeBtn.MouseButton1Click,function()
	setCollapsed(not collapsed)
end)

connect(closeBtn.MouseButton1Click,cleanup)

updateEditor()

task.defer(function()
	if destroyed then
		return
	end

	editor.CursorPosition=#editor.Text+1
	updateEditor()
end)
