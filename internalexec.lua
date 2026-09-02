-- Zot says hi :>

if not game:IsLoaded() then
   game.Loaded:Wait()
end

local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local TextService=game:GetService("TextService")
local player=Players.LocalPlayer
local TITLE="Internal Executor"
local BG=Color3.fromRGB(0,0,0)
local PANEL=Color3.fromRGB(0,0,0)
local STROKE=Color3.fromRGB(255,255,255)
local BTN=Color3.fromRGB(0,0,0)
local BTN_HOVER=Color3.fromRGB(40,40,40)
local TEXT=Color3.fromRGB(255,255,255)
local DIM=Color3.fromRGB(160,160,160)
local RED=Color3.fromRGB(255,80,80)
local GREEN=Color3.fromRGB(100,210,130)
local FULL_H=360
local BAR_H=44
local LINE_H=18
local GUTTER_W=42
local TOP_PAD=3

local function corner(inst,radius)
	local c=Instance.new("UICorner")
	c.CornerRadius=UDim.new(0,radius or 8)
	c.Parent=inst
end

local function addStroke(inst,color,thickness)
	local s=Instance.new("UIStroke")
	s.Color=color
	s.Thickness=thickness or 1.5
	s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
	s.Parent=inst
	return s
end

local function newFrame(props)
	local f=Instance.new(props.type or "Frame")
	f.BorderSizePixel=0
	for k,v in pairs(props) do
		if k~="type" then
			pcall(function() f[k]=v end)
		end
	end
	return f
end

local function makeBtn(parent,text,size,pos)
	local b=newFrame({
		type="TextButton",
		Parent=parent,
		Size=size,
		Position=pos,
		Text=text,
		Font=Enum.Font.GothamBold,
		TextSize=12,
		AutoButtonColor=false,
		BackgroundColor3=BTN,
		TextColor3=TEXT,
		TextStrokeTransparency=1
	})
	corner(b,8)
	addStroke(b,STROKE,1.5)
	b.MouseEnter:Connect(function()
		TweenService:Create(b,TweenInfo.new(.15),{BackgroundColor3=BTN_HOVER}):Play()
	end)
	b.MouseLeave:Connect(function()
		TweenService:Create(b,TweenInfo.new(.15),{BackgroundColor3=BTN}):Play()
	end)
	return b
end

pcall(function()
	local old=player.PlayerGui:FindFirstChild("InternalExecutor")
	if old then old:Destroy() end
end)

pcall(function()
	local old=game.CoreGui:FindFirstChild("InternalExecutor")
	if old then old:Destroy() end
end)

local gui=Instance.new("ScreenGui")
gui.Name="InternalExecutor"
gui.ResetOnSpawn=false
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.Parent=player.PlayerGui

local main=newFrame({
	type="Frame",
	Parent=gui,
	Size=UDim2.new(0,540,0,FULL_H),
	Position=UDim2.new(.28,0,.25,0),
	BackgroundColor3=BG,
	BackgroundTransparency=0,
	ClipsDescendants=true
})
corner(main,12)
addStroke(main,STROKE,1.5)

local bar=newFrame({
	Parent=main,
	Size=UDim2.new(1,0,0,BAR_H),
	Position=UDim2.new(0,0,0,0),
	BackgroundColor3=PANEL
})
corner(bar,12)

newFrame({
	Parent=bar,
	Size=UDim2.new(1,0,.5,0),
	Position=UDim2.new(0,0,.5,0),
	BackgroundColor3=PANEL
})

local title=newFrame({
	type="TextLabel",
	Parent=bar,
	Size=UDim2.new(0,220,1,0),
	Position=UDim2.new(0,14,0,3),
	Text=TITLE,
	BackgroundTransparency=1,
	TextColor3=TEXT,
	Font=Enum.Font.GothamBold,
	TextSize=20,
	TextXAlignment=Enum.TextXAlignment.Left,
	TextYAlignment=Enum.TextYAlignment.Center,
	TextStrokeTransparency=1,
	ZIndex=5
})

local download=makeBtn(
	bar,"Download",
	UDim2.new(0,82,0,28),
	UDim2.new(1,-154,.5,-14)
)

local kill=makeBtn(
	bar,"Kill",
	UDim2.new(0,62,0,28),
	UDim2.new(1,-68,.5,-14)
)
kill.TextColor3=RED

kill.MouseEnter:Connect(function()
	TweenService:Create(kill,TweenInfo.new(.12),{
		BackgroundColor3=Color3.fromRGB(40,0,0),
		TextColor3=Color3.fromRGB(255,120,120)
	}):Play()
end)

kill.MouseLeave:Connect(function()
	TweenService:Create(kill,TweenInfo.new(.12),{
		BackgroundColor3=BTN,
		TextColor3=RED
	}):Play()
end)

local dragging=false
local dragStart
local dragOrigin

local dragZone=newFrame({
	Parent=bar,
	Size=UDim2.new(1,-155,1,0),
	Position=UDim2.new(0,0,0,0),
	BackgroundTransparency=1,
	ZIndex=10
})

dragZone.InputBegan:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseButton1 then
		dragging=true
		dragStart=input.Position
		dragOrigin=main.Position
	end
end)

UIS.InputChanged:Connect(function(input)
	if not dragging or input.UserInputType~=Enum.UserInputType.MouseMovement then return end
	local delta=input.Position-dragStart
	main.Position=UDim2.new(
		dragOrigin.X.Scale,dragOrigin.X.Offset+delta.X,
		dragOrigin.Y.Scale,dragOrigin.Y.Offset+delta.Y
	)
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseButton1 then
		dragging=false
	end
end)

local content=newFrame({
	Parent=main,
	Size=UDim2.new(1,-20,1,-140),
	Position=UDim2.new(0,10,0,60),
	BackgroundTransparency=1
})

local editorPanel=newFrame({
	Parent=content,
	Size=UDim2.new(1,0,1,0),
	BackgroundColor3=Color3.fromRGB(0,0,0),
	BackgroundTransparency=0,
	ClipsDescendants=true
})
corner(editorPanel,8)
addStroke(editorPanel,STROKE,1.5)

local editorScroll=Instance.new("ScrollingFrame")
editorScroll.Name="EditorScroll"
editorScroll.Parent=editorPanel
editorScroll.Size=UDim2.new(1,-4,1,-4)
editorScroll.Position=UDim2.new(0,2,0,2)
editorScroll.BackgroundTransparency=1
editorScroll.BorderSizePixel=0
editorScroll.ScrollBarThickness=0
editorScroll.ScrollBarImageTransparency=1
editorScroll.ScrollingDirection=Enum.ScrollingDirection.Y
editorScroll.ElasticBehavior=Enum.ElasticBehavior.Never
editorScroll.CanvasPosition=Vector2.new(0,0)
editorScroll.CanvasSize=UDim2.new(0,0,0,0)
corner(editorScroll,7)

local editorContent=Instance.new("Frame")
editorContent.Name="EditorContent"
editorContent.Parent=editorScroll
editorContent.Position=UDim2.new(0,0,0,0)
editorContent.Size=UDim2.new(1,0,0,LINE_H)
editorContent.BackgroundTransparency=1
editorContent.BorderSizePixel=0

local gutter=Instance.new("Frame")
gutter.Name="Gutter"
gutter.Parent=editorContent
gutter.Position=UDim2.new(0,0,0,0)
gutter.Size=UDim2.new(0,GUTTER_W,1,0)
gutter.BackgroundColor3=Color3.fromRGB(5,5,5)
gutter.BorderSizePixel=0
gutter.ZIndex=2
corner(gutter,6)

local lineNumbers=Instance.new("TextLabel")
lineNumbers.Name="LineNumbers"
lineNumbers.Parent=gutter
lineNumbers.Position=UDim2.new(0,0,0,TOP_PAD)
lineNumbers.Size=UDim2.new(1,0,0,LINE_H)
lineNumbers.BackgroundTransparency=1
lineNumbers.Text="1"
lineNumbers.TextColor3=DIM
lineNumbers.Font=Enum.Font.Code
lineNumbers.TextSize=14
lineNumbers.TextXAlignment=Enum.TextXAlignment.Center
lineNumbers.TextYAlignment=Enum.TextYAlignment.Top
lineNumbers.TextWrapped=false
lineNumbers.TextStrokeTransparency=1
lineNumbers.ZIndex=3

local viewport=Instance.new("Frame")
viewport.Name="Viewport"
viewport.Parent=editorContent
viewport.Position=UDim2.new(0,GUTTER_W,0,0)
viewport.Size=UDim2.new(1,-GUTTER_W,1,0)
viewport.BackgroundTransparency=1
viewport.BorderSizePixel=0
viewport.ClipsDescendants=true
viewport.ZIndex=3

local editor=Instance.new("TextBox")
editor.Name="Input"
editor.Parent=viewport
editor.Position=UDim2.new(0,4,0,TOP_PAD)
editor.Size=UDim2.new(1,-8,0,LINE_H)
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
editor.TextStrokeTransparency=1
editor.Text='print("hello")'
editor.ZIndex=4

local lineCount=1
local updating=false
local lastText=editor.Text
local lastCursor=editor.CursorPosition

local function countLines(text)
	local count=1
	for _ in text:gmatch("\n") do count+=1 end
	return count
end

local function getCursorLine(text,cursor)
	if cursor<=0 then return 1 end
	local line=1
	local before=text:sub(1,cursor-1)
	for _ in before:gmatch("\n") do line+=1 end
	return line
end

local function getLineText(text,number)
	local current=1
	for line in (text.."\n"):gmatch("(.-)\n") do
		if current==number then return line end
		current+=1
	end
	return ""
end

local function getTextWidth(text)
	if text=="" then return 0 end
	return TextService:GetTextSize(
		text,editor.TextSize,editor.Font,Vector2.new(1000000,100)
	).X
end

local function getRenderedLineHeight()
	local totalLines=math.max(1,countLines(editor.Text))
	local bounds=editor.TextBounds
	if bounds.Y>0 then
		local measured=bounds.Y/totalLines
		if measured>0 then return measured end
	end
	return LINE_H
end

local function getDocumentHeight()
	local lines=countLines(editor.Text)
	local measuredHeight=editor.TextBounds.Y
	if measuredHeight<=0 then measuredHeight=lines*LINE_H end
	return math.max(editorPanel.AbsoluteSize.Y-4,measuredHeight+TOP_PAD+2)
end

local function updateNumbers()
	lineCount=countLines(editor.Text)
	local numbers=table.create(lineCount)
	for i=1,lineCount do numbers[i]=tostring(i) end
	lineNumbers.Text=table.concat(numbers,"\n")
	lineNumbers.Size=UDim2.new(
		1,0,0,
		math.max(editorPanel.AbsoluteSize.Y-4,lineCount*LINE_H+TOP_PAD)
	)
end

local function updateDocument()
	local height=getDocumentHeight()

	editorContent.Size=UDim2.new(1,0,0,height)
	gutter.Size=UDim2.new(0,GUTTER_W,0,height)
	viewport.Size=UDim2.new(1,-GUTTER_W,0,height)
	editor.Size=UDim2.new(1,-8,0,height)
	editorScroll.CanvasSize=UDim2.new(0,0,0,height)
end

local function updateHorizontal()
	local cursor=editor.CursorPosition
	if cursor<=0 then return end

	local text=editor.Text
	local line=getCursorLine(text,cursor)
	local currentLine=getLineText(text,line)
	local lineStart=1

	for i=cursor-1,1,-1 do
		if text:sub(i,i)=="\n" then
			lineStart=i+1
			break
		end
	end

	local beforeCursor=text:sub(lineStart,cursor-1)
	local cursorX=getTextWidth(beforeCursor)
	local totalX=getTextWidth(currentLine)
	local viewWidth=viewport.AbsoluteSize.X
	local currentOffset=-editor.Position.X.Offset
	local left=currentOffset
	local right=currentOffset+viewWidth-10
	local newOffset

	if cursorX>right then
		newOffset=cursorX-viewWidth+10
	elseif cursorX<left then
		newOffset=math.max(0,cursorX-4)
	elseif totalX<right then
		newOffset=math.max(0,totalX-viewWidth+10)
	end

	if newOffset~=nil then
		newOffset=math.max(0,newOffset)
		editor.Position=UDim2.new(0,4-newOffset,0,TOP_PAD)
	end
end

local function getCurrentLineTop()
	local cursor=editor.CursorPosition
	if cursor<=0 then return TOP_PAD end
	local currentLine=getCursorLine(editor.Text,cursor)
	local lineHeight=getRenderedLineHeight()
	return TOP_PAD+(currentLine-1)*lineHeight
end

local function getCurrentLineBottom()
	return getCurrentLineTop()+getRenderedLineHeight()
end

local function getMaxScroll()
	local viewHeight=editorScroll.AbsoluteSize.Y
	return math.max(0,editorScroll.CanvasSize.Y.Offset-viewHeight)
end

local function scrollToBottom()
	if not editor.Parent then return end
	local maxY=getMaxScroll()
	updating=true
	editorScroll.CanvasPosition=Vector2.new(0,maxY)
	updating=false
end

local function scrollToCurrentLine()
	if not editor.Parent then return end

	local currentY=editorScroll.CanvasPosition.Y
	local viewHeight=editorScroll.AbsoluteSize.Y
	local lineTop=getCurrentLineTop()
	local lineBottom=getCurrentLineBottom()
	local padding=5
	local newY=currentY

	if lineBottom>currentY+viewHeight-padding then
		newY=lineBottom-viewHeight+padding
	elseif lineTop<currentY+padding then
		newY=lineTop-padding
	end

	local maxY=getMaxScroll()
	newY=math.clamp(newY,0,maxY)

	if math.abs(newY-currentY)>.01 then
		updating=true
		editorScroll.CanvasPosition=Vector2.new(0,newY)
		updating=false
	end
end

local function updateEditor()
	if updating then return end
	updating=true
	updateNumbers()
	updateDocument()
	updating=false
	updateHorizontal()
end

local function updateEditorAndFollow(forceBottom)
	if updating then return end

	updating=true
	updateNumbers()
	updateDocument()
	updating=false
	updateHorizontal()

	task.defer(function()
		if not editor.Parent then return end
		if forceBottom then scrollToBottom() else scrollToCurrentLine() end
	end)
end

editor:GetPropertyChangedSignal("Text"):Connect(function()
	if updating then return end

	local oldText=lastText
	local newText=editor.Text
	local difference=math.abs(#newText-#oldText)
	local oldLines=countLines(oldText)
	local newLines=countLines(newText)
	local addedLines=newLines>oldLines
	local largePaste=difference>80
	local multiLinePaste=addedLines and difference>20

	lastText=newText

	if largePaste or multiLinePaste then
		updateEditorAndFollow(true)
	else
		updateEditorAndFollow(false)
	end

	lastCursor=editor.CursorPosition
end)

editor:GetPropertyChangedSignal("CursorPosition"):Connect(function()
	if updating then return end
	updateHorizontal()

	task.defer(function()
		if editor.Parent then scrollToCurrentLine() end
	end)

	lastCursor=editor.CursorPosition
end)

editorPanel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	task.defer(function()
		if editor.Parent then
			updateEditor()
			scrollToCurrentLine()
		end
	end)
end)

UIS.InputChanged:Connect(function(input)
	if input.UserInputType~=Enum.UserInputType.MouseWheel then return end

	local mouse=UIS:GetMouseLocation()
	local pos=editorPanel.AbsolutePosition
	local size=editorPanel.AbsoluteSize

	if mouse.X<pos.X or mouse.X>pos.X+size.X
		or mouse.Y<pos.Y or mouse.Y>pos.Y+size.Y then
		return
	end

	local maxY=getMaxScroll()
	local target=editorScroll.CanvasPosition.Y-input.Position.Z*LINE_H*3
	target=math.clamp(target,0,maxY)

	updating=true
	editorScroll.CanvasPosition=Vector2.new(0,target)
	updating=false
end)

local btnBar=newFrame({
	type="Frame",
	Parent=main,
	BackgroundTransparency=1,
	Size=UDim2.new(1,-20,0,34),
	Position=UDim2.new(0,10,1,-44)
})

local status=Instance.new("TextLabel")
status.Parent=btnBar
status.Size=UDim2.new(1,-330,0,28)
status.Position=UDim2.new(0,330,.5,-14)
status.BackgroundTransparency=1
status.Text="Ready"
status.TextColor3=TEXT
status.Font=Enum.Font.Code
status.TextSize=12
status.TextXAlignment=Enum.TextXAlignment.Right
status.TextYAlignment=Enum.TextYAlignment.Center
status.TextStrokeTransparency=1

local statusVersion=0

local function setStatus(text,color)
	statusVersion+=1
	local thisVersion=statusVersion
	status.Text=text
	status.TextColor3=color

	task.delay(1,function()
		if thisVersion~=statusVersion then return end
		if status.Parent then
			status.Text="Ready"
			status.TextColor3=TEXT
		end
	end)
end

local execute=makeBtn(
	btnBar,"Execute",
	UDim2.new(0,70,0,28),
	UDim2.new(0,0,.5,-14)
)

local clear=makeBtn(
	btnBar,"Clear",
	UDim2.new(0,70,0,28),
	UDim2.new(0,76,.5,-14)
)

local copy=makeBtn(
	btnBar,"Copy",
	UDim2.new(0,70,0,28),
	UDim2.new(0,152,.5,-14)
)

execute.MouseButton1Click:Connect(function()
	local source=editor.Text

	if source=="" then
		setStatus("Nothing to execute",TEXT)
		return
	end

	setStatus("Executed successfully",GREEN)
end)

clear.MouseButton1Click:Connect(function()
	updating=true
	editor.Text=""
	editor.CursorPosition=1
	editorScroll.CanvasPosition=Vector2.new(0,0)
	editor.Position=UDim2.new(0,4,0,TOP_PAD)
	updating=false

	lastText=""
	lastCursor=1

	updateEditor()

	task.defer(function()
		scrollToBottom()
	end)

	setStatus("Cleared",GREEN)
end)

copy.MouseButton1Click:Connect(function()
	if type(setclipboard)~="function" then
		setStatus("Copy unavailable",TEXT)
		return
	end

	local ok=pcall(setclipboard,editor.Text)

	if ok then
		setStatus("Copied to clipboard",GREEN)
	else
		setStatus("Copy failed",TEXT)
	end
end)

download.MouseButton1Click:Connect(function()
	if type(writefile)~="function" then
		setStatus("Download unavailable",TEXT)
		return
	end

	local name="script.lua"

	if type(isfile)=="function" then
		local index=1
		while isfile(name) do
			name="script"..index..".lua"
			index+=1
		end
	end

	local success=pcall(writefile,name,editor.Text)

	if success then
		print('Downloaded into workspace with the name "'..name..'"')
		setStatus("Downloaded as "..name,GREEN)
	else
		setStatus("Download failed",TEXT)
	end
end)

kill.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

updateEditor()

task.defer(function()
	editor.CursorPosition=#editor.Text+1
	updateEditor()

	task.defer(function()
		scrollToBottom()
	end)
end)
