-- A passive blue outline attached to the game control being clicked.
return function(isCurrent)
    local feedback={serial=0,alive=true,frame=nil}
    function feedback:Clear()
        self.serial=self.serial+1
        if self.frame then self.frame:Destroy();self.frame=nil end
    end
    function feedback:Destroy()
        self.alive=false
        self:Clear()
    end
    function feedback:Preview(target,valid)
        self:Clear()
        local serial=self.serial
        local function allowed()
            return self.alive and self.serial==serial and isCurrent()
                and target and target.Parent and target:IsA("GuiObject") and valid()
        end
        if not allowed() then return false end
        local frame=Instance.new("Frame")
        frame.Name="YozakuraClickOutline"
        frame.Size=UDim2.fromScale(1,1)
        frame.Position=UDim2.fromOffset(0,0)
        frame.BackgroundTransparency=1
        frame.BorderSizePixel=0
        frame.Active=false
        frame.Selectable=false
        frame.ZIndex=target.ZIndex+1
        self.frame=frame
        local stroke=Instance.new("UIStroke")
        stroke.Color=Color3.fromRGB(40,140,255)
        stroke.Thickness=3
        stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
        stroke.Parent=frame
        local originalCorner=target:FindFirstChildOfClass("UICorner")
        if originalCorner then
            local corner=Instance.new("UICorner")
            corner.CornerRadius=originalCorner.CornerRadius
            corner.Parent=frame
        end
        frame.Parent=target
        -- Render the outline before a successful click hides or replaces the control.
        task.wait(0.12)
        if not allowed() then
            if self.serial==serial then self:Clear() end
            return false
        end
        task.delay(0.55,function()
            if self.serial==serial then self:Clear() end
        end)
        return true
    end
    return feedback
end
