-- ===========================================================================
--  UI  (redesigned)  |  every automation function above this line is unchanged
-- ===========================================================================
A.Colors={
    Surface=Color3.fromRGB(20,18,29),
    Title=Color3.fromRGB(28,25,40),
    Input=Color3.fromRGB(14,12,22),
    Raised=Color3.fromRGB(30,27,43),
    Field=Color3.fromRGB(46,41,66),
    Line=Color3.fromRGB(58,52,82),
    Text=Color3.fromRGB(244,241,250),
    Muted=Color3.fromRGB(152,146,176),
    Accent=Color3.fromRGB(255,193,69),
    AccentInk=Color3.fromRGB(43,29,2),
    AccentSoft=Color3.fromRGB(70,56,38),
    On=Color3.fromRGB(94,226,170),
    Danger=Color3.fromRGB(255,110,124),
    DangerSoft=Color3.fromRGB(74,34,48),
}
A.Colors.Border=A.Colors.Line
A.Colors.Row=A.Colors.Input
A.Colors.RowAlternate=A.Colors.Raised
A.Colors.Button=A.Colors.Field
A.Colors.Good=A.Colors.On
A.Fonts={Regular=Enum.Font.Gotham,Medium=Enum.Font.GothamMedium,Bold=Enum.Font.GothamBold}
A.Controls={}
A.Pages={}
A.PageNames={"Farm","Collect filters","Eggs","ESP","ESP Filters","Pets","Sell","Food","Settings"}
A.NavGroups={{"Farm","Collect filters","Eggs","Pets","Food","Sell"},{"ESP","ESP Filters"},{"Settings"}}
A.PageActive={Farm={"AutoCollect","AutoPlace","AutoHatch","AutoIndex"},Pets={"AutoBest"},
    Food={"AutoFeed","AutoBuyFood"},Sell={"AutoSell","AutoFavorites"},ESP={"EggESP"}}
A.NavButtons={}
A.Page="Farm"
A.PreviewHeight=140
A.RowHeight=A.UIS.TouchEnabled and 44 or 30
A.TitleHeight=A.UIS.TouchEnabled and 44 or 34
A.StatusHeight=40
A.PanelWidth=420
A.PanelHeight=380
A.BodySize=A.UIS.TouchEnabled and 14 or 13
A.UpdateLabels={}
A.FilterButtons={}
A.Options.MenuKey=Enum.KeyCode.RightControl

function A:RefreshKeybind()
    if not self.KeybindButton then return end
    local name=self.Options.MenuKey.Name:gsub("(%l)(%u)","%1 %2"):gsub("Control","Ctrl")
    self.KeybindButton.Text=self.BindingKey and "Press a key (Esc cancels)" or "Menu key: "..name
    self.KeybindButton.BackgroundColor3=self.BindingKey and self.Colors.Accent or self.Colors.Input
    self.KeybindButton.TextColor3=self.BindingKey and self.Colors.AccentInk or self.Colors.Text
end

function A:CancelKeybind()
    self.BindingKey=false
    self:RefreshKeybind()
end

function A:SetMenuVisible(visible)
    self:CancelKeybind()
    self.Panel.Visible=visible
    self:ClosePopup()
    self:RefreshUI()
end

function A:IsMobileDevice()
    local ok,platform=pcall(function() return self.UIS:GetPlatform() end)
    if ok and platform~=Enum.Platform.None then return platform==Enum.Platform.Android or platform==Enum.Platform.IOS end
    return self.UIS.TouchEnabled and not self.UIS.KeyboardEnabled
end

function A:RefreshMenuButtons()
    local mobile=self.MobileMenu and self.MobileMenu.Parent~=nil
    if self.Menu then self.Menu.Visible=not mobile and not self.Panel.Visible end
    if mobile then
        local shown=self.Panel.Visible
        self.MobileMenu.Visible=true
        self.MobileMenu.Text=shown and "Hide UI" or "Show UI"
        self.MobileMenu.BackgroundColor3=shown and self.Colors.Title or self.Colors.Accent
        self.MobileMenu.TextColor3=shown and self.Colors.Text or self.Colors.AccentInk
    end
end

function A:ClampMobileMenu(pos)
    if not self.MobileMenu then return end
    local area,size=self.Bounds.AbsoluteSize,self.MobileMenu.AbsoluteSize
    if area.X<=0 or area.Y<=0 then return end
    self.MobileMenu.Position=UDim2.fromOffset(math.clamp(pos.X,8,math.max(8,area.X-size.X-8)),
        math.clamp(pos.Y,8,math.max(8,area.Y-size.Y-8)))
end

function A:LayoutMobileMenu()
    if not self.MobileMenu then return end
    self:EndMobileMenuDrag()
    local pos=self.MobileMenuPositioned and Vector2.new(self.MobileMenu.Position.X.Offset,self.MobileMenu.Position.Y.Offset)
        or Vector2.new(self.Bounds.AbsoluteSize.X-80,12)
    self:ClampMobileMenu(pos)
    self.MobileMenuPositioned=true
end

function A:BeginMobileMenuDrag(input)
    if not self.MobileMenu or self.MobileMenuDrag then return end
    if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
    self.MobileMenuSkipTap=false
    self.MobileMenuDrag={Input=input,Start=Vector2.new(input.Position.X,input.Position.Y),
        Position=Vector2.new(self.MobileMenu.Position.X.Offset,self.MobileMenu.Position.Y.Offset),Moved=false}
end

function A:MoveMobileMenuDrag(input)
    local drag=self.MobileMenuDrag
    if not drag then return end
    if input~=drag.Input and not (drag.Input.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseMovement) then return end
    local delta=Vector2.new(input.Position.X,input.Position.Y)-drag.Start
    if delta.Magnitude>=8 then drag.Moved=true self.MobileMenuSkipTap=true end
    if drag.Moved then self:ClampMobileMenu(drag.Position+delta) end
end

function A:EndMobileMenuDrag(input)
    local drag=self.MobileMenuDrag
    if not drag then return end
    if input and input~=drag.Input and not (drag.Input.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseButton1) then return end
    if not input or drag.Moved then self.MobileMenuSkipTap=true end
    self.MobileMenuDrag=nil
end

function A:ActivateMobileMenu()
    if not self.Alive or self.MobileMenuSkipTap then return end
    self:SetMenuVisible(not self.Panel.Visible)
end

function A:BuildMobileMenu()
    if self.MobileMenu or not self:IsMobileDevice() then return end
    self.MobileMenu=self:Button(self.Bounds,"Hide UI",function() self:ActivateMobileMenu() end,self.Colors.Title)
    self.MobileMenu.Name="MobileMenuToggle"
    self.MobileMenu.Size=UDim2.fromOffset(72,44)
    self.MobileMenu.TextSize=13
    self.MobileMenu.ZIndex=30
    self:Connect(self.MobileMenu.InputBegan,function(input) self:BeginMobileMenuDrag(input) end)
    self:Connect(self.UIS.InputChanged,function(input) self:MoveMobileMenuDrag(input) end)
    self:Connect(self.UIS.InputEnded,function(input) self:EndMobileMenuDrag(input) end)
    self:Connect(self.UIS.WindowFocusReleased,function() self:EndMobileMenuDrag() end)
    self:LayoutMobileMenu()
    self:RefreshMenuButtons()
end

function A:HandleMenuInput(input,processed)
    if not self.Alive or input.UserInputType~=Enum.UserInputType.Keyboard then return end
    if self.UIS:GetFocusedTextBox() then self:CancelKeybind() return end
    if self.BindingKey then
        if input.KeyCode==Enum.KeyCode.Escape then self:CancelKeybind()
        elseif input.KeyCode~=Enum.KeyCode.Unknown then
            self.Options.MenuKey=input.KeyCode
            self:CancelKeybind()
        end
        return
    end
    if not processed and input.KeyCode==self.Options.MenuKey then self:SetMenuVisible(not self.Panel.Visible) end
end

-- ---------------------------------------------------------------------------
--  Building blocks
-- ---------------------------------------------------------------------------
function A:Make(class,parent,props)
    local object=Instance.new(class)
    for k,v in pairs(props) do object[k]=v end
    object.Parent=parent
    return object
end

function A:Corner(object,radius)
    return self:Make("UICorner",object,{CornerRadius=UDim.new(0,radius or 8)})
end

function A:Stroke(object,color,transparency)
    return self:Make("UIStroke",object,{Color=color or self.Colors.Line,Thickness=1,Transparency=transparency or 0,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
end

function A:Pad(object,left,top,right,bottom)
    return self:Make("UIPadding",object,{PaddingLeft=UDim.new(0,left or 0),PaddingTop=UDim.new(0,top or 0),
        PaddingRight=UDim.new(0,right or left or 0),PaddingBottom=UDim.new(0,bottom or top or 0)})
end

-- a small "v" drawn from two bars so it never depends on font glyphs; rotation -90 points right
function A:Chevron(parent,color,rotation)
    local holder=self:Make("Frame",parent,{Name="Chevron",AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-10,0.5,0),
        Size=UDim2.fromOffset(12,12),BackgroundTransparency=1,BorderSizePixel=0,Rotation=rotation or 0})
    for _,side in ipairs({-1,1}) do
        self:Make("Frame",holder,{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,side*2.5,0.5,0),
            Size=UDim2.fromOffset(7,2),Rotation=side*-45,BackgroundColor3=color or self.Colors.Muted,BorderSizePixel=0})
    end
    return holder
end

function A:Text(parent,text,height)
    return self:Make("TextLabel",parent,{Name="Label",Size=UDim2.new(1,0,0,height or 22),
        BackgroundTransparency=1,Text=text,TextSize=self.BodySize,Font=self.Fonts.Medium,
        TextColor3=self.Colors.Text,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
end

function A:Hint(parent,text,height)
    local label=self:Text(parent,text,height or 32)
    label.Name="Hint"
    label.TextColor3=self.Colors.Muted
    label.TextSize=12
    label.TextYAlignment=Enum.TextYAlignment.Top
    return label
end

function A:Button(parent,text,callback,color,variant)
    local C=self.Colors
    if not variant then
        if color==C.Accent then variant="primary"
        elseif color==C.Row then variant="field"
        elseif color==C.Danger then variant="danger"
        elseif color==C.Title then variant="float"
        else variant="secondary" end
    end
    local background,foreground,font=C.Field,C.Text,self.Fonts.Bold
    if variant=="primary" then background,foreground=C.Accent,C.AccentInk
    elseif variant=="field" then background,font=C.Input,self.Fonts.Medium
    elseif variant=="danger" then background,foreground=C.DangerSoft,C.Danger
    elseif variant=="float" then background=C.Title end
    local button=self:Make("TextButton",parent,{Name=text:gsub("[^%w]",""),Text=text,
        Size=UDim2.new(1,0,0,self.RowHeight),BackgroundColor3=background,
        BorderSizePixel=0,TextColor3=foreground,Font=font,TextSize=self.BodySize,
        AutoButtonColor=true,TextWrapped=true})
    self:Corner(button,8)
    if variant=="field" or variant=="float" then self:Stroke(button,C.Line) end
    if callback then self:Connect(button.Activated,callback) end
    return button
end

-- a row that holds one full-width button (keeps even spacing inside cards)
function A:Row(parent,name,height)
    return self:Make("Frame",parent,{Name=name or "Row",Size=UDim2.new(1,0,0,height or self.RowHeight+6),
        BackgroundTransparency=1,BorderSizePixel=0})
end

function A:ActionRow(parent,text,callback,variant)
    local row=self:Row(parent,"ActionRow")
    local button=self:Button(row,text,callback,nil,variant)
    button.Position=UDim2.fromOffset(0,3)
    button.Size=UDim2.new(1,0,1,-6)
    return button
end

-- returns the button (its .Text is what the refresh code sets) and the row that holds it
function A:Dropdown(parent,text,callback)
    local row=self:Row(parent,"DropdownRow")
    local button=self:Button(row,text,callback,self.Colors.Row)
    button.Position=UDim2.fromOffset(0,3)
    button.Size=UDim2.new(1,0,1,-6)
    button.TextXAlignment=Enum.TextXAlignment.Left
    button.TextTruncate=Enum.TextTruncate.AtEnd
    self:Pad(button,10,0,32,0)
    self:Chevron(row,self.Colors.Muted,0)
    return button,row
end

function A:Section(parent,text)
    local row=self:Make("Frame",parent,{Name="Section",Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,BorderSizePixel=0})
    local bar=self:Make("Frame",row,{Name="Bar",AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,2,0.5,1),
        Size=UDim2.fromOffset(3,13),BackgroundColor3=self.Colors.Accent,BorderSizePixel=0})
    self:Corner(bar,2)
    self:Make("TextLabel",row,{Name="Label",Position=UDim2.fromOffset(12,0),Size=UDim2.new(1,-12,1,0),
        BackgroundTransparency=1,Text=text,Font=self.Fonts.Bold,TextSize=13,TextColor3=self.Colors.Text,
        TextXAlignment=Enum.TextXAlignment.Left})
    return row
end

-- rounded group of rows; the builder adds rows and this stacks them with thin dividers
function A:Card(parent,build,options)
    options=options or {}
    local card=self:Make("Frame",parent,{Name=options.Name or "Card",Size=UDim2.new(1,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=self.Colors.Raised,BorderSizePixel=0})
    self:Corner(card,10)
    self:Stroke(card,self.Colors.Line,0.4)
    self:Pad(card,8,3,8,3)
    self:Make("UIListLayout",card,{Padding=UDim.new(0,0),SortOrder=Enum.SortOrder.LayoutOrder})
    if build then build(card) end
    local rows={}
    for _,child in ipairs(card:GetChildren()) do
        if child:IsA("GuiObject") then rows[#rows+1]=child end
    end
    for index,row in ipairs(rows) do
        row.LayoutOrder=index*2-1
        if options.Dividers~=false and index<#rows then
            self:Make("Frame",card,{Name="Divider",Size=UDim2.new(1,0,0,1),BackgroundColor3=self.Colors.Line,
                BackgroundTransparency=0.4,BorderSizePixel=0,LayoutOrder=index*2})
        end
    end
    return card
end

function A:StatTiles(parent,captions)
    local count=#captions
    local holder=self:Make("Frame",parent,{Name="Stats",Size=UDim2.new(1,0,0,56),BackgroundTransparency=1,BorderSizePixel=0})
    local values={}
    for index,caption in ipairs(captions) do
        local tile=self:Make("Frame",holder,{Name=caption:gsub(" ",""),
            Position=UDim2.new((index-1)/count,(index-1)*6/count,0,0),
            Size=UDim2.new(1/count,-6*(count-1)/count,1,0),BackgroundColor3=self.Colors.Raised,BorderSizePixel=0})
        self:Corner(tile,10)
        self:Stroke(tile,self.Colors.Line,0.4)
        values[index]=self:Make("TextLabel",tile,{Name="Value",Position=UDim2.fromOffset(0,8),Size=UDim2.new(1,0,0,24),
            BackgroundTransparency=1,Text="-",Font=self.Fonts.Bold,TextSize=18,TextColor3=self.Colors.Text})
        self:Make("TextLabel",tile,{Name="Caption",Position=UDim2.fromOffset(0,32),Size=UDim2.new(1,0,0,16),
            BackgroundTransparency=1,Text=caption,Font=self.Fonts.Medium,TextSize=11,TextColor3=self.Colors.Muted})
    end
    return values
end

function A:ButtonGrid(parent,buttons)
    local grid=self:Make("Frame",parent,{Name="Actions",Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,BorderSizePixel=0})
    self:Make("UIGridLayout",grid,{CellPadding=UDim2.fromOffset(6,6),CellSize=UDim2.new(0.5,-3,0,self.RowHeight+6),
        SortOrder=Enum.SortOrder.LayoutOrder})
    local made={}
    for index,entry in ipairs(buttons) do
        local button=self:Button(grid,entry[1],entry[2],nil,entry[3])
        button.LayoutOrder=index
        made[index]=button
    end
    return made
end

function A:KeyValue(parent,key)
    local row=self:Row(parent,key,28)
    self:Make("TextLabel",row,{Name="Key",Position=UDim2.fromOffset(2,0),Size=UDim2.new(0.4,-2,1,0),
        BackgroundTransparency=1,Text=key,Font=self.Fonts.Medium,TextSize=12,TextColor3=self.Colors.Muted,
        TextXAlignment=Enum.TextXAlignment.Left})
    return self:Make("TextLabel",row,{Name="Value",AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-2,0,0),
        Size=UDim2.new(0.6,-2,1,0),BackgroundTransparency=1,Text="-",Font=self.Fonts.Medium,TextSize=self.BodySize,
        TextColor3=self.Colors.Text,TextXAlignment=Enum.TextXAlignment.Right,TextTruncate=Enum.TextTruncate.AtEnd})
end

-- reusable rows for lists that change while the menu is open (nests, pets, sell list)
function A:RowList(parent,emptyText)
    local frame=self:Make("Frame",parent,{Name="List",Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,BorderSizePixel=0})
    self:Make("UIListLayout",frame,{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder})
    local empty=self:Make("TextLabel",frame,{Name="Empty",Size=UDim2.new(1,0,0,self.RowHeight-4),BackgroundTransparency=1,
        Text=emptyText or "",Font=self.Fonts.Medium,TextSize=12,TextColor3=self.Colors.Muted,
        TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=0})
    return {Frame=frame,Empty=empty,EmptyText=emptyText or "",Rows={}}
end

function A:FillList(list,entries)
    local C=self.Colors
    list.Empty.Visible=#entries==0
    for index,entry in ipairs(entries) do
        local row=list.Rows[index]
        if not row then
            local frame=self:Make("Frame",list.Frame,{Name="Row"..index,Size=UDim2.new(1,0,0,26),
                BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=index})
            row={Frame=frame,
                Left=self:Make("TextLabel",frame,{Name="Left",Size=UDim2.new(0.6,0,0,24),BackgroundTransparency=1,
                    Text="",Font=self.Fonts.Medium,TextSize=self.BodySize,TextColor3=C.Text,
                    TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd}),
                Right=self:Make("TextLabel",frame,{Name="Right",Position=UDim2.fromScale(0.6,0),Size=UDim2.new(0.4,0,0,24),
                    BackgroundTransparency=1,Text="",Font=self.Fonts.Bold,TextSize=12,TextColor3=C.Muted,
                    TextXAlignment=Enum.TextXAlignment.Right,TextTruncate=Enum.TextTruncate.AtEnd}),
                Sub=self:Make("TextLabel",frame,{Name="Sub",Position=UDim2.fromOffset(0,22),Size=UDim2.new(1,0,0,16),
                    BackgroundTransparency=1,Text="",Font=self.Fonts.Medium,TextSize=11,TextColor3=C.Muted,
                    TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})}
            list.Rows[index]=row
        end
        row.Frame.Visible=true
        row.Frame.Size=UDim2.new(1,0,0,entry.Sub and 42 or 26)
        row.Left.Text=entry.Left or ""
        row.Left.TextColor3=entry.Color or C.Text
        row.Right.Text=entry.Right or ""
        row.Right.TextColor3=entry.RightColor or C.Muted
        row.Sub.Text=entry.Sub or ""
        row.Sub.Visible=entry.Sub~=nil
    end
    for index=#entries+1,#list.Rows do list.Rows[index].Frame.Visible=false end
end

-- ---------------------------------------------------------------------------
--  Telegram link (logic unchanged)
-- ---------------------------------------------------------------------------
function A:LoadTelegramText()
    if not self.Alive or self.TelegramLoading then return end
    self.TelegramLoading=true
    if self.TelegramButton then self.TelegramButton.Text="Loading Telegram..." end
    local thread=task.defer(function()
        local ok,body=pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/Bac0nHck/Something/refs/heads/main/telegram",true)
        end)
        if not self.Alive then return end
        self.TelegramLoading=false
        local content=ok and type(body)=="string" and body:match("^%s*(.-)%s*$") or nil
        if content and content~="" then
            self.TelegramText=content
            if self.TelegramButton and self.TelegramButton.Parent then self.TelegramButton.Text=content end
        else
            self.TelegramText=nil
            self.Status="Could not load Telegram text. Click to retry."
            if self.TelegramButton and self.TelegramButton.Parent then self.TelegramButton.Text="Retry loading Telegram" end
        end
    end)
    table.insert(self.Threads,thread)
end

function A:CopyTelegramText()
    if not self.Alive then return false end
    if not self.TelegramText then self:LoadTelegramText() return false end
    local copy=type(setclipboard)=="function" and setclipboard or type(toclipboard)=="function" and toclipboard
    if not copy then self.Status="Clipboard is unavailable in this executor" return false end
    local ok=pcall(copy,self.TelegramText)
    self.Status=ok and "Copied to clipboard" or "Could not copy to clipboard"
    return ok
end

function A:BuildTelegramButton(parent)
    if self.TelegramButton and self.TelegramButton.Parent then return end
    self.TelegramButton=self:Button(parent,"Loading Telegram...",function() self:CopyTelegramText() end,self.Colors.Accent)
    self.TelegramButton.Name="TelegramLink"
    self.TelegramButton.AutomaticSize=Enum.AutomaticSize.Y
    self:Make("UIPadding",self.TelegramButton,{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10),
        PaddingTop=UDim.new(0,8),PaddingBottom=UDim.new(0,8)})
    self:LoadTelegramText()
end

-- ---------------------------------------------------------------------------
--  Controls
-- ---------------------------------------------------------------------------
function A:SwitchRow(parent,name,label,callback)
    local C=self.Colors
    local row=self:Make("TextButton",parent,{Name=name,Text="",AutoButtonColor=false,BackgroundTransparency=1,
        BorderSizePixel=0,Size=UDim2.new(1,0,0,self.RowHeight+6)})
    local text=self:Make("TextLabel",row,{Name="Label",Position=UDim2.fromOffset(2,0),Size=UDim2.new(1,-58,1,0),
        BackgroundTransparency=1,Text=label,Font=self.Fonts.Medium,TextSize=self.BodySize,TextColor3=C.Text,
        TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})
    local track=self:Make("Frame",row,{Name="Switch",AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-2,0.5,0),
        Size=UDim2.fromOffset(40,22),BackgroundColor3=C.Field,BorderSizePixel=0})
    self:Corner(track,11)
    local knob=self:Make("Frame",track,{Name="Knob",AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,3,0.5,0),
        Size=UDim2.fromOffset(16,16),BackgroundColor3=C.Muted,BorderSizePixel=0})
    self:Corner(knob,8)
    self:Connect(row.Activated,callback)
    return {Button=row,Label=label,Text=text,Track=track,Knob=knob}
end

function A:SetSwitch(control,on)
    if control.State==on then return end
    local first=control.State==nil
    control.State=on
    local C=self.Colors
    local position=UDim2.new(0,on and 21 or 3,0.5,0)
    local trackColor=on and C.Accent or C.Field
    local knobColor=on and C.AccentInk or C.Muted
    if first then
        control.Knob.Position=position
        control.Knob.BackgroundColor3=knobColor
        control.Track.BackgroundColor3=trackColor
    else
        local info=TweenInfo.new(0.14,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
        self.TweenService:Create(control.Knob,info,{Position=position,BackgroundColor3=knobColor}):Play()
        self.TweenService:Create(control.Track,info,{BackgroundColor3=trackColor}):Play()
    end
end

function A:Toggle(parent,key,label)
    local control=self:SwitchRow(parent,key,label,function() self:SetOption(key,not self.Options[key]) end)
    control.Toggle=true
    self.Controls[key]=control
    return control
end

function A:NumberInput(parent,key,label,step,minimum,maximum,source,integer)
    source=source or self.Options
    local C=self.Colors
    local height=self.RowHeight-4
    local group=self:Make("Frame",parent,{Name=key,Size=UDim2.new(1,0,0,height+26),BackgroundTransparency=1,BorderSizePixel=0})
    self:Make("TextLabel",group,{Name="Label",Position=UDim2.fromOffset(2,4),Size=UDim2.new(1,-4,0,16),
        BackgroundTransparency=1,Text=label,Font=self.Fonts.Medium,TextSize=12,TextColor3=C.Muted,
        TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})
    local field=self:Make("Frame",group,{Name="Field",Position=UDim2.fromOffset(0,22),Size=UDim2.new(1,0,0,height),
        BackgroundColor3=C.Input,BorderSizePixel=0})
    self:Corner(field,8)
    self:Stroke(field,C.Line)
    local input=self:Make("TextBox",field,{Name="Value",Position=UDim2.fromOffset(height,0),
        Size=UDim2.new(1,-height*2,1,0),BackgroundTransparency=1,BorderSizePixel=0,Text=tostring(source[key]),
        ClearTextOnFocus=false,TextColor3=C.Text,Font=self.Fonts.Bold,TextSize=self.BodySize})
    local function set(value)
        value=tonumber(value)
        if not value or value~=value then input.Text=tostring(source[key]) return end
        value=math.clamp(value,minimum,maximum)
        if integer then value=math.floor(value) end
        source[key]=value
        input.Text=tostring(value)
    end
    local minus=self:Button(field,"-",function() set(source[key]-step) end)
    minus.Position=UDim2.fromOffset(3,3)
    minus.Size=UDim2.fromOffset(height-6,height-6)
    minus.TextSize=18
    local plus=self:Button(field,"+",function() set(source[key]+step) end)
    plus.AnchorPoint=Vector2.new(1,0)
    plus.Position=UDim2.new(1,-3,0,3)
    plus.Size=UDim2.fromOffset(height-6,height-6)
    plus.TextSize=18
    self:Connect(input.FocusLost,function() set(input.Text) end)
    return input
end

function A:Choice(parent,key,label,values)
    local row=self:Row(parent,key.."Choice")
    self:Make("TextLabel",row,{Name="Label",Position=UDim2.fromOffset(2,0),Size=UDim2.new(0.5,-8,1,0),
        BackgroundTransparency=1,Text=label,Font=self.Fonts.Medium,TextSize=self.BodySize,TextColor3=self.Colors.Text,
        TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
    local button,holder
    button,holder=self:Dropdown(row,"",function()
        self:OpenPopup(button,label,values,self.Options[key],false,function(value)
            self:SetOption(key,value)
        end,false)
    end)
    holder.AnchorPoint=Vector2.new(1,0)
    holder.Position=UDim2.fromScale(1,0)
    holder.Size=UDim2.new(0.5,0,1,0)
    self.Controls[key]={Button=button,Choice=true}
end

-- ---------------------------------------------------------------------------
--  Dropdown / picker popup
-- ---------------------------------------------------------------------------
function A:ClosePopup()
    if self.Popup then self.Popup:Destroy() self.Popup=nil end
    self.PopupAnchor=nil
end

function A:OpenPopup(anchor,title,items,selected,multi,onChange,searchable)
    self:ClosePopup()
    self.PopupAnchor=anchor
    local C=self.Colors
    local layer=self:Make("Frame",self.Bounds,{Name="Dropdown",Size=UDim2.fromScale(1,1),
        BackgroundTransparency=1,ZIndex=20})
    self.Popup=layer
    local backdrop=self:Make("TextButton",layer,{Name="Dismiss",Size=UDim2.fromScale(1,1),
        BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.55,Text="",AutoButtonColor=false,
        BorderSizePixel=0,ZIndex=1})
    backdrop.Activated:Connect(function() self:ClosePopup() end)
    local area=self.Bounds.AbsoluteSize
    local width=math.min(320,area.X-16)
    local height=math.min(380,math.max(160,area.Y-16))
    local center=self.Panel.AbsolutePosition-self.Bounds.AbsolutePosition+self.Panel.AbsoluteSize/2
    local x=math.clamp(center.X-width/2,8,math.max(8,area.X-width-8))
    local y=math.clamp(center.Y-height/2,8,math.max(8,area.Y-height-8))
    local box=self:Make("Frame",layer,{Name="Options",Position=UDim2.fromOffset(x,y),
        Size=UDim2.fromOffset(width,height),BackgroundColor3=C.Surface,BorderSizePixel=0,ZIndex=2})
    self:Corner(box,12)
    self:Stroke(box,C.Line)
    self:Make("TextLabel",box,{Name="Title",Position=UDim2.fromOffset(16,0),Size=UDim2.new(1,-32,0,44),
        BackgroundTransparency=1,Text=title,TextSize=15,Font=self.Fonts.Bold,TextColor3=C.Text,
        TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})
    local footerHeight=self.RowHeight
    local top=44
    local search
    if searchable then
        search=self:Make("TextBox",box,{Name="Search",Position=UDim2.fromOffset(10,top),
            Size=UDim2.new(1,-20,0,self.RowHeight-4),Text="",PlaceholderText="Search...",ClearTextOnFocus=false,
            Font=self.Fonts.Medium,TextSize=self.BodySize,TextColor3=C.Text,PlaceholderColor3=C.Muted,
            BackgroundColor3=C.Input,BorderSizePixel=0,TextXAlignment=Enum.TextXAlignment.Left})
        self:Corner(search,8)
        self:Stroke(search,C.Line)
        self:Pad(search,10,0,10,0)
        top=top+self.RowHeight-4+6
    end
    local list=self:Make("ScrollingFrame",box,{Name="List",Position=UDim2.fromOffset(10,top),
        Size=UDim2.new(1,-20,1,-top-footerHeight-18),BackgroundTransparency=1,BorderSizePixel=0,
        CanvasSize=UDim2.fromOffset(0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=3,ScrollBarImageColor3=C.Muted})
    self:Make("UIListLayout",list,{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder})
    if #items==0 then
        local empty=self:Text(list,"No matches",self.RowHeight)
        empty.TextColor3=C.Muted
    end
    local rows={}
    for index,item in ipairs(items) do
        local id,label=type(item)=="table" and item.ID or item,type(item)=="table" and item.Label or item
        local row=self:Make("TextButton",list,{Name="Option"..index,Size=UDim2.new(1,-6,0,self.RowHeight),
            Text="",BackgroundColor3=C.Raised,BorderSizePixel=0,AutoButtonColor=false,LayoutOrder=index})
        self:Corner(row,8)
        local mark=self:Make("Frame",row,{Name="Mark",AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,10,0.5,0),
            Size=UDim2.fromOffset(18,18),BackgroundColor3=C.Input,BorderSizePixel=0})
        self:Corner(mark,multi and 5 or 9)
        local dot=self:Make("Frame",mark,{Name="Dot",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),
            Size=UDim2.fromOffset(multi and 8 or 6,multi and 8 or 6),BackgroundColor3=C.AccentInk,BorderSizePixel=0})
        self:Corner(dot,multi and 2 or 3)
        local text=self:Make("TextLabel",row,{Name="Label",Position=UDim2.fromOffset(38,0),Size=UDim2.new(1,-46,1,0),
            BackgroundTransparency=1,Text=label,TextSize=self.BodySize,Font=self.Fonts.Medium,TextColor3=C.Text,
            TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd})
        local function paint()
            local enabled=multi and selected[id]==true or not multi and selected==id
            text.TextColor3=(type(item)=="table" and item.Color) or C.Text
            row.BackgroundColor3=enabled and C.AccentSoft or C.Raised
            mark.BackgroundColor3=enabled and C.Accent or C.Input
            dot.Visible=enabled
        end
        paint()
        row.Activated:Connect(function()
            if not self.Alive then return end
            if multi then selected[id]=not selected[id] onChange(id,selected[id]) paint()
            else onChange(id) self:ClosePopup() end
        end)
        rows[#rows+1]={Row=row,ID=id,Label=string.lower(label),Paint=paint}
    end
    if search then search:GetPropertyChangedSignal("Text"):Connect(function()
        local query=string.lower(search.Text)
        for _,r in ipairs(rows) do r.Row.Visible=string.find(r.Label,query,1,true)~=nil end
        list.CanvasPosition=Vector2.zero
    end) end
    local footer=self:Make("Frame",box,{Name="Footer",AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,10,1,-10),
        Size=UDim2.new(1,-20,0,footerHeight),BackgroundTransparency=1,BorderSizePixel=0})
    self:Make("UIListLayout",footer,{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,6),
        SortOrder=Enum.SortOrder.LayoutOrder})
    local function action(text,index,count,callback,variant)
        local button=self:Button(footer,text,nil,nil,variant)
        button.Name=text
        button.LayoutOrder=index
        button.Size=UDim2.new(1/count,-6*(count-1)/count,1,0)
        button.Activated:Connect(callback)
    end
    if multi then
        for index,entry in ipairs({{"All",true},{"None",false}}) do
            action(entry[1],index,3,function()
                for _,r in ipairs(rows) do selected[r.ID]=entry[2] onChange(r.ID,entry[2]) r.Paint() end
            end)
        end
        action("Done",3,3,function() self:ClosePopup() end,"primary")
    else action("Close",1,1,function() self:ClosePopup() end) end
end

-- ---------------------------------------------------------------------------
--  Filters
-- ---------------------------------------------------------------------------
function A:FilterPanel(parent,kind)
    local f=self.Filters[kind]
    local function changed()
        if kind=="Eggs" then self:RefreshUI() else self:ControlRefresh() end
    end
    for _,entry in ipairs({{"Rarities",self.RarityNames},{"Types",self.EggNames},{"Mutations",self.MutationNames}}) do
        local group,names=entry[1],entry[2]
        local button
        button=self:Dropdown(parent,"",function()
            self:OpenPopup(button,group,names,f[group],true,changed,group=="Types")
        end)
        button.Name=kind..group.."Filter"
        self.FilterButtons[#self.FilterButtons+1]={Button=button,Group=group,Names=names,Filter=f}
    end
    local mutated=self:SwitchRow(parent,kind.."MutatedOnly","Mutated eggs only",function()
        f.MutatedOnly=not f.MutatedOnly
        changed()
    end)
    self.FilterButtons[#self.FilterButtons+1]={Control=mutated,Mutated=true,Filter=f}
    local searchRow=self:Row(parent,kind.."SearchRow")
    local search=self:Make("TextBox",searchRow,{Name=kind.."Search",Position=UDim2.fromOffset(0,3),Size=UDim2.new(1,0,1,-6),
        BackgroundColor3=self.Colors.Input,BorderSizePixel=0,Text="",PlaceholderText="Search egg names",
        ClearTextOnFocus=false,TextSize=self.BodySize,Font=self.Fonts.Medium,TextColor3=self.Colors.Text,
        PlaceholderColor3=self.Colors.Muted,TextXAlignment=Enum.TextXAlignment.Left})
    self:Corner(search,8)
    self:Stroke(search,self.Colors.Line)
    self:Pad(search,10,0,10,0)
    self:Connect(search:GetPropertyChangedSignal("Text"),function() f.Search=search.Text end)
    self:NumberInput(parent,"MinLuck","Minimum luck",10,0,1e15,f)
    self:NumberInput(parent,"MinWeight","Minimum weight (kg)",1,0,1e9,f)
    if kind=="Eggs" then self:NumberInput(parent,"MaxDistance","Maximum distance (studs)",100,0,100000,f) end
end

function A:BuildEggFilters(card)
    if self.EggFiltersToggle then return end
    local C=self.Colors
    local row=self:Row(card,"FiltersRow")
    local toggle=self:Make("TextButton",row,{Name="EggFiltersToggle",Text="",AutoButtonColor=true,
        Position=UDim2.fromOffset(0,3),Size=UDim2.new(1,0,1,-6),BackgroundColor3=C.Field,BorderSizePixel=0})
    self:Corner(toggle,8)
    self.EggFiltersToggle=toggle
    self.EggFiltersLabel=self:Make("TextLabel",toggle,{Name="Label",Position=UDim2.fromOffset(10,0),
        Size=UDim2.new(0.5,-10,1,0),BackgroundTransparency=1,Text="Filters",Font=self.Fonts.Bold,
        TextSize=self.BodySize,TextColor3=C.Text,TextXAlignment=Enum.TextXAlignment.Left})
    self.EggFiltersCount=self:Make("TextLabel",toggle,{Name="Count",AnchorPoint=Vector2.new(1,0),
        Position=UDim2.new(1,-30,0,0),Size=UDim2.new(0.5,-30,1,0),BackgroundTransparency=1,Text="",
        Font=self.Fonts.Medium,TextSize=12,TextColor3=C.Muted,TextXAlignment=Enum.TextXAlignment.Right})
    self.EggFiltersChevron=self:Chevron(toggle,C.Muted,-90)
    self.EggFiltersBody=self:Card(self.Pages.Eggs,function(body) self:FilterPanel(body,"Eggs") end,{Name="EggFilters"})
    self.EggFiltersBody.Visible=false
    self:Connect(toggle.Activated,function()
        self:ClosePopup()
        self.EggFiltersBody.Visible=not self.EggFiltersBody.Visible
        self:RefreshUI()
    end)
end

function A:OpenEggPicker()
    local rows={}
    for _,egg in ipairs(self:EggList("Eggs")) do rows[#rows+1]={ID=egg.ID,
        Label=egg.Name.." | "..egg.Rarity.." | "..egg.ID:sub(1,5),Color=self.RarityColors[egg.Rarity]} end
    self:OpenPopup(self.EggPicker,"Map eggs ("..#rows..")",rows,self.Options.SelectedEgg,false,
        function(id) self.Options.SelectedEgg=id self:RefreshUI() end,true)
end

function A:CollectSelectedEgg(token)
    for _,egg in ipairs(self:EggList("Eggs")) do
        if egg.ID==self.Options.SelectedEgg then self:CollectEgg(egg,token) return end
    end
    self.Status="Select an available egg that matches your filters"
end

-- ---------------------------------------------------------------------------
--  Pages and navigation
-- ---------------------------------------------------------------------------
function A:CreatePage(name)
    if self.Pages[name] then return self.Pages[name] end
    local page=self:Make("ScrollingFrame",self.Content,{Name=name:gsub(" ",""),Position=UDim2.fromOffset(8,8),
        Size=UDim2.new(1,-8,1,-8),BackgroundTransparency=1,BorderSizePixel=0,
        CanvasSize=UDim2.fromOffset(0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=3,ScrollBarImageColor3=self.Colors.Muted,
        ScrollBarImageTransparency=0.4,Visible=name==self.Page})
    self:Make("UIListLayout",page,{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder})
    self:Make("UIPadding",page,{PaddingRight=UDim.new(0,8),PaddingBottom=UDim.new(0,10)})
    self.Pages[name]=page
    return page
end

function A:BuildNavigation()
    local C=self.Colors
    local order=0
    for groupIndex,group in ipairs(self.NavGroups) do
        if groupIndex>1 then
            order=order+1
            self:Make("Frame",self.Rail,{Name="Divider",Size=UDim2.new(1,-8,0,1),BackgroundColor3=C.Line,
                BackgroundTransparency=0.3,BorderSizePixel=0,LayoutOrder=order})
        end
        for _,name in ipairs(group) do
            order=order+1
            local button=self:Make("TextButton",self.Rail,{Name="Nav"..name:gsub(" ",""),Text="",AutoButtonColor=false,
                Size=UDim2.new(1,0,0,self.RowHeight),BackgroundColor3=C.Raised,BackgroundTransparency=1,
                BorderSizePixel=0,LayoutOrder=order})
            self:Corner(button,8)
            local bar=self:Make("Frame",button,{Name="Bar",AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,0,0.5,0),
                Size=UDim2.fromOffset(3,16),BackgroundColor3=C.Accent,BorderSizePixel=0,Visible=false})
            self:Corner(bar,2)
            local label=self:Make("TextLabel",button,{Name="Label",Position=UDim2.fromOffset(12,0),
                Size=UDim2.new(1,-26,1,0),BackgroundTransparency=1,Text=name,Font=self.Fonts.Medium,TextSize=13,
                TextColor3=C.Muted,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
            local dot=self:Make("Frame",button,{Name="Active",AnchorPoint=Vector2.new(1,0.5),
                Position=UDim2.new(1,-8,0.5,0),Size=UDim2.fromOffset(7,7),BackgroundColor3=C.Accent,
                BorderSizePixel=0,Visible=false})
            self:Corner(dot,4)
            self:Connect(button.Activated,function() self:SwitchPage(name) end)
            self.NavButtons[name]={Button=button,Bar=bar,Label=label,Dot=dot}
        end
    end
end

function A:RefreshNav()
    local C=self.Colors
    for name,nav in pairs(self.NavButtons) do
        local selected=name==self.Page
        nav.Button.BackgroundTransparency=selected and 0 or 1
        nav.Bar.Visible=selected
        nav.Label.TextColor3=selected and C.Text or C.Muted
        nav.Label.Font=selected and self.Fonts.Bold or self.Fonts.Medium
        local active=false
        for _,key in ipairs(self.PageActive[name] or {}) do
            if self.Options[key] then active=true break end
        end
        nav.Dot.Visible=active
    end
end

function A:SwitchPage(name)
    self:CancelKeybind()
    self:ClosePopup()
    self.Page=name
    for key,page in pairs(self.Pages) do page.Visible=key==name end
    self:RefreshNav()
    self:RefreshUI()
end

function A:OpenFoodFeedPicker()
    local rows={}
    for _,pet in ipairs(self:PetList()) do
        rows[#rows+1]={ID=pet.Key,Label=pet.Name.." | age "..pet.Age.." | "..pet.Key:sub(1,5),Color=self.RarityColors[pet.Rarity]}
    end
    self:OpenPopup(self.FoodFeedPetsButton,"Select Pet",rows,self.FoodFeedPets,true,
        function() self:FoodFeedFilterChanged() end,true)
end

function A:OpenFeedingFoodPicker()
    local rows={}
    for _,name in ipairs(self.FoodNames) do
        rows[#rows+1]={ID=name,Label=name.." | owned "..self:FoodCount(name).." | XP "..self:Format(self.Data.Foods[name].XP),
            Color=self.RarityColors[self.Data.Shop.Food[name].Rarity]}
    end
    self:OpenPopup(self.FoodFeedItemsButton,"Feeding foods",rows,self.FoodFeedItems,true,
        function() self:FeedingFoodSelectionChanged() end,true)
end

function A:OpenShoppingFoodPicker()
    local rows={}
    for _,name in ipairs(self.FoodNames) do
        local data=self.Data.Shop.Food[name]
        rows[#rows+1]={ID=name,Label=name.." | $"..self:Format(data.Price).." | stock "..tostring(self:FoodStock(name) or "?"),Color=self.RarityColors[data.Rarity]}
    end
    self:OpenPopup(self.FoodBuyItemsButton,"Food shop",rows,self.FoodBuyItems,true,function() self:RefreshFoodUI() end,true)
end

function A:BuildFoodPage()
    if self.FoodFeedItemsButton then return end
    local page=self:CreatePage("Food")
    self:Section(page,"Feeding")
    self:Card(page,function(card)
        self.FoodFeedItemsButton=self:Dropdown(card,"Food",function() self:OpenFeedingFoodPicker() end)
        self.FoodFeedItemsButton.Name="FeedingFoodsFilter"
        self.FoodFeedPetsButton=self:Dropdown(card,"Select Pet",function() self:OpenFoodFeedPicker() end)
        self.FoodFeedPetsButton.Name="FeedingPetsFilter"
        self.ManualFeedCountBox=self:NumberInput(card,"ManualFeedCount","Feeds per pet (button only)",1,1,1000,nil,true)
    end,{Name="FeedingSetup"})
    self:Card(page,function(card)
        self:ActionRow(card,"Feed Selected Pets",function()
            local amount=self:ClampManualFeedCount(self.ManualFeedCountBox.Text)
            self.Options.ManualFeedCount=amount
            self.ManualFeedCountBox.Text=tostring(amount)
            self:StartJob("Feeding selected pets",function(token) self:FeedSelectedPets(token,amount) end)
        end,"primary")
        self:Toggle(card,"AutoFeed","Auto Feed")
    end,{Name="FeedingActions"})
    self:Section(page,"Food shop")
    self:Card(page,function(card)
        self.FoodBuyItemsButton=self:Dropdown(card,"Food",function() self:OpenShoppingFoodPicker() end)
        self.FoodBuyItemsButton.Name="ShoppingFoodsFilter"
        self:ActionRow(card,"Buy Selected Food",function()
            self:StartJob("Buying selected food",function(token) self:BuySelectedFoods(token) end)
        end,"primary")
        self:Toggle(card,"AutoBuyFood","Auto-buy foods")
    end,{Name="FoodShop"})
end

function A:RefreshFoodUI()
    if not self.FoodFeedItemsButton then return end
    local feeding,buying=0,0
    for _,name in ipairs(self.FoodNames) do
        if self.FoodFeedItems[name] then feeding=feeding+1 end
        if self.FoodBuyItems[name] then buying=buying+1 end
    end
    self.FoodFeedItemsButton.Text="Food: "..feeding.." / "..#self.FoodNames
    self.FoodBuyItemsButton.Text="Food: "..buying.." / "..#self.FoodNames
    local selected,total=0,0
    for _,pet in ipairs(self:PetList()) do
        total=total+1
        if self.FoodFeedPets[pet.Key] then selected=selected+1 end
    end
    self.FoodFeedPetsButton.Text="Select Pet: "..selected.." / "..total
end

function A:ConfirmSellAll()
    if not self.Alive then return end
    if self.Job then self.SellStatus="Finish the current action first" return end
    local pets=self:InventorySellPets()
    if #pets==0 then self.SellStatus="No inventory pets available to sell" return end
    self:ClosePopup()
    local C=self.Colors
    local layer=self:Make("Frame",self.Bounds,{Name="SellConfirmation",Size=UDim2.fromScale(1,1),
        BackgroundTransparency=1,ZIndex=20})
    self.Popup=layer
    local function cancel()
        if self.Popup==layer then self:ClosePopup() end
    end
    local backdrop=self:Make("TextButton",layer,{Name="Dismiss",Size=UDim2.fromScale(1,1),
        BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.55,Text="",AutoButtonColor=false,BorderSizePixel=0})
    backdrop.Activated:Connect(cancel)
    local area=self.Bounds.AbsoluteSize
    local width=math.min(304,area.X-16)
    local height=self.RowHeight+124
    local center=self.Panel.AbsolutePosition-self.Bounds.AbsolutePosition+self.Panel.AbsoluteSize/2
    local x=math.clamp(center.X-width/2,8,math.max(8,area.X-width-8))
    local y=math.clamp(center.Y-height/2,8,math.max(8,area.Y-height-8))
    local box=self:Make("Frame",layer,{Name="Dialog",Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(width,height),
        BackgroundColor3=C.Surface,BorderSizePixel=0,ZIndex=2})
    self:Corner(box,12)
    self:Stroke(box,C.Line)
    self:Make("TextLabel",box,{Name="Title",Position=UDim2.fromOffset(16,14),Size=UDim2.new(1,-32,0,24),
        BackgroundTransparency=1,Text="Confirm Sell All",Font=self.Fonts.Bold,TextSize=16,TextColor3=C.Text,
        TextXAlignment=Enum.TextXAlignment.Left})
    local message=self:Text(box,"Sell "..#pets.." inventory "..(#pets==1 and "pet" or "pets").."?\nFavorites and protected pets will be kept.",56)
    message.Name="Message"
    message.Position=UDim2.fromOffset(16,44)
    message.Size=UDim2.new(1,-32,0,56)
    message.TextYAlignment=Enum.TextYAlignment.Top
    message.TextColor3=C.Muted
    local dismiss=self:Button(box,"Cancel",nil)
    dismiss.Activated:Connect(cancel)
    dismiss.AnchorPoint=Vector2.new(0,1)
    dismiss.Position=UDim2.new(0,16,1,-16)
    dismiss.Size=UDim2.new(0.5,-21,0,self.RowHeight)
    local confirm=self:Button(box,"Sell "..#pets,nil,self.Colors.Accent)
    confirm.Activated:Connect(function()
        if not self.Alive or self.Popup~=layer then return end
        self:ClosePopup()
        if not self:StartJob("Selling all inventory pets",function(token) self:SellAllInventoryPets(token,pets) end) then
            self.SellStatus="Finish the current action first"
        end
    end)
    confirm.Name="Confirm"
    confirm.AnchorPoint=Vector2.new(1,1)
    confirm.Position=UDim2.new(1,-16,1,-16)
    confirm.Size=UDim2.new(0.5,-21,0,self.RowHeight)
end

function A:BuildSellPage()
    if self.SellInfo then return end
    local page=self:CreatePage("Sell")
    self.SellTiles=self:StatTiles(page,{"Available","Sold"})
    self.SellAllButton=self:Button(page,"Sell All",function() self:ConfirmSellAll() end,self.Colors.Accent)
    self.SellAllButton.Size=UDim2.new(1,0,0,self.RowHeight+6)
    self:Card(page,function(card)
        self:Toggle(card,"AutoSell","Auto Sell Inventory Pets")
        self:Hint(card,"Inventory pets only. Favorites are kept.",26)
    end,{Name="AutoSell"})
    self:Section(page,"Inventory pets to sell")
    self:Card(page,function(card)
        self.SellInfo=self:RowList(card,"No inventory pets available")
    end,{Name="SellList"})
    self:Section(page,"Auto favorites")
    self:Card(page,function(card)
        self:Toggle(card,"AutoFavorites","Auto Favorites")
        self.FavoriteFilterButtons={}
        for _,entry in ipairs({{"Rarities",self.RarityNames},{"Types",self.FavoritePetNames}}) do
            local group,names=entry[1],entry[2]
            local button
            button=self:Dropdown(card,"",function()
                local rows={}
                for _,name in ipairs(names) do
                    local rarity=group=="Rarities" and name or self.Data.Pets[name].Rarity
                    rows[#rows+1]={ID=name,Label=name,Color=self.RarityColors[rarity]}
                end
                self:OpenPopup(button,group=="Types" and "Pet types" or "Rarities",rows,self.FavoriteFilters[group],true,
                    function() self:RefreshSellUI() end,group=="Types")
            end)
            button.Name="Favorite"..group.."Filter"
            self.FavoriteFilterButtons[group]=button
        end
        self.FavoriteInfo=self:Hint(card,"",44)
    end,{Name="AutoFavorites"})
end

function A:RefreshSellUI()
    if not self.SellInfo then return end
    local pets=self:InventorySellPets()
    local entries={}
    for _,pet in ipairs(pets) do
        entries[#entries+1]={Left=pet.Name,Right=pet.Rarity or "Unknown",RightColor=self.RarityColors[pet.Rarity]}
    end
    self:FillList(self.SellInfo,entries)
    self.SellTiles[1].Text=tostring(#pets)
    self.SellTiles[2].Text=tostring(self.SoldPets or 0)
    local selected={}
    for _,entry in ipairs({{"Rarities",self.RarityNames},{"Types",self.FavoritePetNames}}) do
        local group,names=entry[1],entry[2]
        local count=0
        for _,name in ipairs(names) do if self.FavoriteFilters[group][name] then count=count+1 end end
        selected[group]=count
        self.FavoriteFilterButtons[group].Text=(group=="Types" and "Pet types" or "Rarities")..": "
            ..(count==#names and "All" or count.." / "..#names)
    end
    local pending=0
    for _ in pairs(self.FavoriteRequests) do pending=pending+1 end
    self.FavoriteInfo.Text=(selected.Rarities==0 or selected.Types==0)
        and "Choose at least one rarity and pet type."
        or "Inventory pets matching both filters are kept."
    if pending>0 then self.FavoriteInfo.Text="Waiting for confirmation: "..pending.."\nThese pets are kept from sale." end
    self.SellAllButton.Text=self.Job=="Selling all inventory pets" and "Selling..." or "Sell All"
end

function A:ControlRefresh()
    for key,control in pairs(self.Controls) do
        local value=self.Options[key]
        if control.Toggle then self:SetSwitch(control,value and true or false)
        elseif control.Choice then control.Button.Text=tostring(value) end
    end
    for _,row in ipairs(self.FilterButtons) do
        if row.Mutated then self:SetSwitch(row.Control,row.Filter.MutatedOnly and true or false)
        else
            local count=0
            for _,name in ipairs(row.Names) do if row.Filter[row.Group][name] then count=count+1 end end
            row.Button.Text=row.Group..": "..(count==#row.Names and "All" or tostring(count).." / "..#row.Names)
        end
    end
    self:RefreshNav()
end

function A:ClampPanel(pos)
    local area,size=self.Bounds.AbsoluteSize,self.Panel.AbsoluteSize
    self.Panel.Position=UDim2.fromOffset(math.clamp(pos.X,8,math.max(8,area.X-size.X-8)),
        math.clamp(pos.Y,8,math.max(8,area.Y-size.Y-8)))
end

function A:Layout(size)
    size=size or self.Bounds.AbsoluteSize
    if size.X<=0 or size.Y<=0 then return end
    self:ClosePopup()
    local width=math.min(self.PanelWidth,math.max(240,size.X-24))
    local height=self.Collapsed and self.TitleHeight or math.min(self.PanelHeight,math.max(180,size.Y-24))
    self.Panel.Size=UDim2.fromOffset(width,height)
    self.Container.Visible=not self.Collapsed
    self.TitleLine.Visible=not self.Collapsed
    local rail=width>=400 and 116 or 90
    self.Rail.Size=UDim2.new(0,rail,1,0)
    self.RailLine.Position=UDim2.fromOffset(rail,8)
    self.Content.Position=UDim2.fromOffset(rail+1,0)
    self.Content.Size=UDim2.new(1,-rail-1,1,0)
    local pos=self.Positioned and Vector2.new(self.Panel.Position.X.Offset,self.Panel.Position.Y.Offset)
        or Vector2.new(12,math.floor(size.Y*0.2))
    self:ClampPanel(pos)
    self.Positioned=true
    self:LayoutMobileMenu()
end

function A:RefreshUI()
    if not self.StatusLabel then return end
    local C=self.Colors
    self:ControlRefresh()
    self.StatusLabel.Text=self.Page=="Food" and self.FoodStatus or self.Page=="Sell" and self.SellStatus or self.Status
    self.StatusLabel.TextColor3=self.Job and C.Text or C.Muted
    self.StatusDot.BackgroundColor3=self.Job and C.Accent or C.Line
    self.FarmTiles[1].Text=string.format("%d/%s",self.Cache.Basket or 0,self:Format(self:Capacity()))
    self.FarmTiles[2].Text=tostring(self.Cache.Tools or 0)
    self.FarmTiles[3].Text=tostring(self.Cache.Nests or 0)
    local timers={}
    for _,egg in ipairs(self.Cache.Timers or {}) do
        local ready=egg.Remaining<=0
        timers[#timers+1]={Left=egg.Name,Right=ready and "Ready" or self:Time(egg.Remaining),
            RightColor=ready and C.On or C.Muted}
    end
    self:FillList(self.NestRows,timers)
    local reward=self.Cache.Reward
    local discovered=tonumber(self.Cache.Discovered) or 0
    if reward then
        local goal=tonumber(reward.Goal) or 0
        self.IndexInfo.Text=tostring(self.Cache.Discovered).." / "..tostring(reward.Goal)
        self.IndexFill.Size=UDim2.fromScale(goal>0 and math.clamp(discovered/goal,0,1) or 0,1)
    else
        self.IndexInfo.Text="Complete"
        self.IndexFill.Size=UDim2.fromScale(1,1)
    end
    local egg,matchingCount,filteredSelection=nil,0,false
    for _,row in ipairs(self.Cache.Eggs or {}) do
        local matches=self:Matches(row,"Eggs")
        if matches then matchingCount=matchingCount+1 end
        if row.ID==self.Options.SelectedEgg then
            if matches then egg=row else filteredSelection=true end
        end
    end
    if filteredSelection then self.Options.SelectedEgg=nil end
    if self.EggFiltersToggle then
        self.EggFiltersCount.Text=matchingCount.." eggs"
        self.EggFiltersChevron.Rotation=self.EggFiltersBody.Visible and 0 or -90
    end
    self.EggPicker.Text=egg and egg.Name.." | "..egg.ID:sub(1,5) or (matchingCount==0 and "No matching eggs" or "Select an egg")
    self:Preview(egg)
    self.EggName.Text=egg and egg.Name or (self.Options.SelectedEgg and "Egg no longer available" or "Choose an egg")
    self.EggName.TextColor3=egg and self.RarityColors[egg.Rarity] or C.Muted
    for key,label in pairs(self.EggInfo) do
        local value="-"
        if egg then
            if key=="Rarity" then value=egg.Rarity elseif key=="Luck" then value=self:Format(egg.Luck).."x"
            elseif key=="Weight" then value=self:Format(egg.KG).." kg" elseif key=="Mutation" then value=egg.MutationLabel
            elseif key=="Distance" then value=self:Format(egg.Distance).." studs" end
        end
        label.Text=value
        label.TextColor3=(key=="Rarity" and egg and self.RarityColors[egg.Rarity]) or C.Text
    end
    local pets={}
    for _,pet in ipairs(self.Cache.Pets or {}) do
        pets[#pets+1]={Left=pet.Name,Color=self.RarityColors[pet.Rarity],Right="$"..self:Format(pet.Income).."/s",
            RightColor=C.On,Sub=self:Format(pet.Speed).." speed | "..(pet.Placed and "Placed" or "Inventory")}
    end
    self:FillList(self.PetRows,pets)
    self.ErrorInfo.Text=#self.Errors>0 and self.Errors[#self.Errors] or "No errors"
    self.ErrorInfo.Size=UDim2.new(1,0,0,#self.Errors>0 and 90 or 26)
    self:RefreshMenuButtons()
    self:RefreshFoodUI()
    self:RefreshSellUI()
end

-- ---------------------------------------------------------------------------
--  Window
-- ---------------------------------------------------------------------------
A.Gui=A:Make("ScreenGui",A.Player:WaitForChild("PlayerGui"),{Name="RideAPetCompact",ResetOnSpawn=false,
    DisplayOrder=250,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets})
A.Bounds=A:Make("Frame",A.Gui,{Name="SafeArea",Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0})
A.Panel=A:Make("Frame",A.Bounds,{Name="Panel",Size=UDim2.fromOffset(A.PanelWidth,A.PanelHeight),
    BackgroundColor3=A.Colors.Surface,BorderSizePixel=0,Active=true})
A:Corner(A.Panel,12)
A:Stroke(A.Panel,A.Colors.Line)

A.Title=A:Make("Frame",A.Panel,{Name="TitleBar",Size=UDim2.new(1,0,0,A.TitleHeight),BackgroundTransparency=1,BorderSizePixel=0})
A.TitleLine=A:Make("Frame",A.Title,{Name="TitleLine",AnchorPoint=Vector2.new(0,1),Position=UDim2.fromScale(0,1),
    Size=UDim2.new(1,0,0,1),BackgroundColor3=A.Colors.Line,BorderSizePixel=0})
local eggMark=A:Make("Frame",A.Title,{Name="EggMark",AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,14,0.5,0),
    Size=UDim2.fromOffset(14,18),BackgroundColor3=A.Colors.Accent,BorderSizePixel=0})
A:Corner(eggMark,999)
local eggShine=A:Make("Frame",eggMark,{Name="Shine",Position=UDim2.fromOffset(3,4),Size=UDim2.fromOffset(3,5),
    BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.45,BorderSizePixel=0})
A:Corner(eggShine,2)
A.Header=A:Button(A.Title,"Ride A Pet",function() end,A.Colors.Title,"ghost")
A.Header.Name="DragHandle"
A.Header.BackgroundTransparency=1
A.Header.Position=UDim2.fromOffset(38,0)
A.Header.Size=UDim2.new(1,-38-A.TitleHeight*2,1,0)
A.Header.TextXAlignment=Enum.TextXAlignment.Left
A.Header.TextSize=15
A.Header.AutoButtonColor=false
A.Collapse=A:Button(A.Title,"",function()
    A.Collapsed=not A.Collapsed
    A.CollapseBar.Visible=not A.Collapsed
    A.CollapseBox.Visible=A.Collapsed
    A:Layout()
end,A.Colors.Title,"ghost")
A.Collapse.Name="Collapse"
A.Collapse.BackgroundTransparency=1
A.Collapse.AnchorPoint=Vector2.new(1,0)
A.Collapse.Position=UDim2.new(1,-A.TitleHeight,0,0)
A.Collapse.Size=UDim2.fromOffset(A.TitleHeight,A.TitleHeight)
A.CollapseBar=A:Make("Frame",A.Collapse,{Name="Bar",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),
    Size=UDim2.fromOffset(12,2),BackgroundColor3=A.Colors.Muted,BorderSizePixel=0})
A.CollapseBox=A:Make("Frame",A.Collapse,{Name="Box",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),
    Size=UDim2.fromOffset(11,11),BackgroundTransparency=1,BorderSizePixel=0,Visible=false})
A:Corner(A.CollapseBox,2)
A:Make("UIStroke",A.CollapseBox,{Color=A.Colors.Muted,Thickness=2,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
A.Close=A:Button(A.Title,"",function() A:SetMenuVisible(false) end,A.Colors.Title,"ghost")
A.Close.Name="Close"
A.Close.BackgroundTransparency=1
A.Close.AnchorPoint=Vector2.new(1,0)
A.Close.Position=UDim2.fromScale(1,0)
A.Close.Size=UDim2.fromOffset(A.TitleHeight,A.TitleHeight)
for _,angle in ipairs({45,-45}) do
    A:Make("Frame",A.Close,{Name="Cross",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),
        Size=UDim2.fromOffset(13,2),Rotation=angle,BackgroundColor3=A.Colors.Muted,BorderSizePixel=0})
end

A.Container=A:Make("Frame",A.Panel,{Name="Container",Position=UDim2.fromOffset(0,A.TitleHeight),
    Size=UDim2.new(1,0,1,-A.TitleHeight),BackgroundTransparency=1,BorderSizePixel=0})
A.Body=A:Make("Frame",A.Container,{Name="Body",Size=UDim2.new(1,0,1,-A.StatusHeight),BackgroundTransparency=1,BorderSizePixel=0})
A.Rail=A:Make("ScrollingFrame",A.Body,{Name="Navigation",Size=UDim2.new(0,116,1,0),BackgroundTransparency=1,
    BorderSizePixel=0,CanvasSize=UDim2.fromOffset(0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
    ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=0})
A:Make("UIListLayout",A.Rail,{Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder})
A:Pad(A.Rail,8,8,6,8)
A.RailLine=A:Make("Frame",A.Body,{Name="RailLine",Position=UDim2.fromOffset(116,8),Size=UDim2.new(0,1,1,-16),
    BackgroundColor3=A.Colors.Line,BackgroundTransparency=0.3,BorderSizePixel=0})
A.Content=A:Make("Frame",A.Body,{Name="Content",Position=UDim2.fromOffset(117,0),Size=UDim2.new(1,-117,1,0),
    BackgroundTransparency=1,BorderSizePixel=0})
A.StatusBar=A:Make("Frame",A.Container,{Name="StatusBar",AnchorPoint=Vector2.new(0,1),Position=UDim2.fromScale(0,1),
    Size=UDim2.new(1,0,0,A.StatusHeight),BackgroundTransparency=1,BorderSizePixel=0})
A:Make("Frame",A.StatusBar,{Name="Line",Size=UDim2.new(1,0,0,1),BackgroundColor3=A.Colors.Line,BorderSizePixel=0})
A.StatusDot=A:Make("Frame",A.StatusBar,{Name="Dot",AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,16,0.5,0),
    Size=UDim2.fromOffset(8,8),BackgroundColor3=A.Colors.Line,BorderSizePixel=0})
A:Corner(A.StatusDot,4)
A.StatusLabel=A:Make("TextLabel",A.StatusBar,{Name="Status",Position=UDim2.fromOffset(34,0),Size=UDim2.new(1,-48,1,0),
    BackgroundTransparency=1,Text="Ready",Font=A.Fonts.Medium,TextSize=12,TextColor3=A.Colors.Muted,
    TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,TextTruncate=Enum.TextTruncate.AtEnd})

for _,name in ipairs(A.PageNames) do A:CreatePage(name) end
A:BuildNavigation()

-- Farm -----------------------------------------------------------------------
local farm=A.Pages.Farm
A.FarmTiles=A:StatTiles(farm,{"Basket","Stored eggs","Free nests"})
A:Section(farm,"Automation")
A:Card(farm,function(card)
    A:Toggle(card,"AutoCollect","Auto Collect Eggs")
    A:Toggle(card,"AutoPlace","Auto Place Eggs")
    A:Toggle(card,"AutoHatch","Auto Hatch Eggs")
    A:Toggle(card,"AutoIndex","Auto Claim Index")
end,{Name="Automation"})
A:Section(farm,"Collection")
A:Card(farm,function(card)
    A:Choice(card,"EggPriority","Collection priority",{"Nearest","Rarest","Highest luck","Heaviest"})
    A:NumberInput(card,"TweenSpeed","Flight speed (studs / second)",10,40,350)
    A:NumberInput(card,"MaxDistance","Collection range (studs)",100,100,15000)
end,{Name="Collection"})
A:Section(farm,"Actions")
A:ButtonGrid(farm,{
    {"Place Eggs Now",function() A:StartJob("Placing eggs",function(token) A.EggDeliveryPaused=false A:PlaceEggs(token) end) end},
    {"Hatch Ready Eggs",function() A:StartJob("Hatching eggs",function(token) A:HatchReady(token) end) end},
    {"Claim Index Reward",function() A:StartJob("Claiming index",function(token) A:ClaimIndex(token) end) end},
    {"Fly to Ranch",function() A:StartJob("Returning to ranch",function(token) A.EggDeliveryPaused=false A:Home(token) end) end},
})
A:Section(farm,"Egg timers")
A:Card(farm,function(card) A.NestRows=A:RowList(card,"No eggs in nests") end,{Name="Nests"})
A:Card(farm,function(card)
    local row=A:Row(card,"IndexProgress",58)
    A:Make("TextLabel",row,{Name="Label",Position=UDim2.fromOffset(2,6),Size=UDim2.new(0.5,0,0,20),BackgroundTransparency=1,
        Text="Index",Font=A.Fonts.Bold,TextSize=A.BodySize,TextColor3=A.Colors.Text,TextXAlignment=Enum.TextXAlignment.Left})
    A.IndexInfo=A:Make("TextLabel",row,{Name="Progress",AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-2,0,6),
        Size=UDim2.new(0.5,0,0,20),BackgroundTransparency=1,Text="",Font=A.Fonts.Medium,TextSize=12,
        TextColor3=A.Colors.Muted,TextXAlignment=Enum.TextXAlignment.Right})
    local track=A:Make("Frame",row,{Name="Track",Position=UDim2.new(0,2,0,34),Size=UDim2.new(1,-4,0,8),
        BackgroundColor3=A.Colors.Input,BorderSizePixel=0})
    A:Corner(track,4)
    A.IndexFill=A:Make("Frame",track,{Name="Fill",Size=UDim2.fromScale(0,1),BackgroundColor3=A.Colors.Accent,BorderSizePixel=0})
    A:Corner(A.IndexFill,4)
end,{Name="Index"})

-- Eggs -----------------------------------------------------------------------
local eggs=A.Pages.Eggs
A:Card(eggs,function(card)
    A.EggPicker=A:Dropdown(card,"Select an egg",function() A:OpenEggPicker() end)
    A:BuildEggFilters(card)
end,{Name="EggSelect"})
A:MakePreview()
A.Viewport.Parent=eggs
A.Viewport.BackgroundColor3=A.Colors.Input
A:Corner(A.Viewport,10)
A:Stroke(A.Viewport,A.Colors.Line,0.4)
A:Card(eggs,function(card)
    A.EggName=A:Text(card,"Choose an egg",34)
    A.EggName.TextXAlignment=Enum.TextXAlignment.Center
    A.EggName.Font=A.Fonts.Bold
    A.EggName.TextSize=16
    A.EggInfo={}
    for _,key in ipairs({"Rarity","Luck","Weight","Mutation","Distance"}) do
        A.EggInfo[key]=A:KeyValue(card,key)
    end
end,{Name="EggDetails"})
A:ButtonGrid(eggs,{
    {"Collect Selected Egg",function()
        A:StartJob("Collecting selected egg",function(token)
            A:CollectSelectedEgg(token)
        end)
    end,"primary"},
    {"Stop Collecting",function() A:StopCollecting() end},
})
A:Card(eggs,function(card)
    A:Toggle(card,"RotatePreview","Rotate preview")
    A:Hint(card,"Drag the model to rotate.",22)
end,{Name="PreviewOptions"})

-- ESP ------------------------------------------------------------------------
local esp=A.Pages.ESP
A:Card(esp,function(card) A:Toggle(card,"EggESP","Enable Egg ESP") end,{Name="EggESP"})
A:Section(esp,"Labels")
A:Card(esp,function(card)
    for _,entry in ipairs({{"ESPName","Show name"},{"ESPRarity","Show rarity"},{"ESPShowDistance","Show distance"},
        {"ESPWeight","Show weight"},{"ESPMutation","Show mutation"},{"ESPLuck","Show luck"}}) do A:Toggle(card,entry[1],entry[2]) end
end,{Name="Labels"})
A:Section(esp,"Overlays")
A:Card(esp,function(card)
    A:Toggle(card,"ESPBoxes","Show egg markers")
    A:Toggle(card,"ESPTracers","Show tracers")
end,{Name="Overlays"})
A:Section(esp,"Limits")
A:Card(esp,function(card)
    A:NumberInput(card,"ESPSize","Text size",1,12,25)
    A:NumberInput(card,"ESPCount","Maximum labels",5,1,100)
    A:NumberInput(card,"ESPDistance","ESP range (studs)",100,100,15000)
end,{Name="Limits"})
A:Hint(A.Pages["ESP Filters"],"Egg ESP only shows eggs that match these filters.",20)
A:Card(A.Pages["ESP Filters"],function(card) A:FilterPanel(card,"ESP") end,{Name="ESPFilters"})
A:Hint(A.Pages["Collect filters"],"Auto Collect only picks up eggs that match these filters.",20)
A:Card(A.Pages["Collect filters"],function(card) A:FilterPanel(card,"Collect") end,{Name="CollectFilters"})

-- Pets -----------------------------------------------------------------------
local pets=A.Pages.Pets
A:Card(pets,function(card)
    A:Toggle(card,"AutoBest","Auto Place Best Pets")
    A:Choice(card,"BestMetric","Rank pets by",{"Income","Speed"})
end,{Name="BestPets"})
A:ButtonGrid(pets,{
    {"Place Best Pets Now",function() A:StartJob("Placing best pets",function(token) A:PlaceBest(token) end) end,"primary"},
})
A.Pages.Pets:FindFirstChild("Actions").GridLayoutFix=nil
A:Section(pets,"Your pets")
A:Card(pets,function(card) A.PetRows=A:RowList(card,"No pets available") end,{Name="PetList"})
A:BuildSellPage()
A:BuildFoodPage()

-- Settings -------------------------------------------------------------------
local settings=A.Pages.Settings
A:Card(settings,function(card)
    A:Toggle(card,"AntiAFK","Anti-AFK")
    A.KeybindButton=A:ActionRow(card,"Menu key: Right Ctrl",function()
        A:ClosePopup()
        A.BindingKey=not A.BindingKey
        A:RefreshKeybind()
    end,"field")
    A.KeybindButton.Name="MenuKeybind"
    A:Hint(card,"Click Menu key, then press a key. Esc cancels. Drag the title bar to move the window.",44)
    A:ActionRow(card,"Center Window",function() local s=A.Bounds.AbsoluteSize A:ClampPanel((s-A.Panel.AbsoluteSize)/2) end)
end,{Name="General"})
A:BuildTelegramButton(settings)
A:Button(settings,"Unload",function() A:Unload() end,A.Colors.Danger)
A:Section(settings,"Last error")
A:Card(settings,function(card)
    A.ErrorInfo=A:Text(card,"No errors",26)
    A.ErrorInfo.TextColor3=A.Colors.Muted
    A.ErrorInfo.TextSize=12
    A.ErrorInfo.TextYAlignment=Enum.TextYAlignment.Top
    A.ErrorInfo.TextTruncate=Enum.TextTruncate.AtEnd
end,{Name="LastError"})

for _,page in pairs(A.Pages) do
    local index=0
    for _,child in ipairs(page:GetChildren()) do if child:IsA("GuiObject") then index=index+1 child.LayoutOrder=index end end
end
A:RefreshNav()

A.Menu=A:Button(A.Bounds,"Menu",function() A:SetMenuVisible(true) end,A.Colors.Title)
A.Menu.Size=UDim2.fromOffset(74,44)
A.Menu.Position=UDim2.new(1,-82,1,-52)
A.Menu.ZIndex=30
A.Menu.Visible=false
A:BuildMobileMenu()

--@@DRAG_BLOCK@@

