local module = {}
local uiModule = require(script.Parent.Parent.UiModule)
module.PurchaseBind = nil
module.WearingCharacter = nil
local tweenService = game:GetService("TweenService")
function module:Tween(obj,proprety,duration,easingStyle,easingDirection)
	local tweenInfo = TweenInfo.new(duration or 0.15,easingStyle or Enum.EasingStyle.Sine,easingDirection or Enum.EasingDirection.In)
	local tween = tweenService:Create(obj,tweenInfo,proprety)
	tween:Play()
end
function module:SetupCharacter(Title,Icon,Description,Cost,IsOwned,IsWearing)
	local lib = {}
  local ui = script.Parent.CharacterSelection

  ui.Title.Text = Title
  ui.Description.Description.Text = Description 
  if IsOwned then
    ui.Purchase.Button.Text = "WEAR"
  else 
    ui.Purchase.Button.Text = "PURCHASE"
  end

	if IsWearing then 
    ui.Purchase.Button.Text = "CURRENTLY WEARING"
	end
  
	lib.Perks = {}
	function lib:CreatePerk(perkt,perkName)
		local perkCost = perkt.Costs
		local perkLevel = perkt.Level
		local perkOwned = perkt.IsOwned
		local perkCallback = perkt.Callback
		local toggle = perkStatus
		local perk = script.Perk:Clone()
		lib.Perks[perkName] = perkt
		perk.Parent = script.Parent.CharacterPerks.ScrollingFrame
    if perkLevel then 
		   perk.Title = perkName.." | ".. tostring(perkLevel) .. " | ".. tostring(perkCost[perkLevel]) .. "$"
    else
       perk.Title = perkName.." | ".. tostring(perkCost[1]) .. "$"	
		end
		if perkOwned then 
			perk.Button.Text = "Upgrade"
    else 
			perk.Button.Text = "Purchase"
		end

		perk.Purchase.MouseButton1Click:Connect(function()
			if perkOwned then 
				toggle = not toggle
				perk.Button.Text = tostring(toggle)
				perkCallback(toggle)
				script.Parent.Remotes.ToggleActive:InvokeServer(perkName,toggle) --Saving the toggle
        local purchase = script.Parent.Remotes.PurchaseEvent:InvokeServer(perkName,"PerkUpgrade",Title,perkLevel + 1)
        if purchase then
          perkt.Level += 1 
          perkLevel += 1
          
          script.purchase:Play()
          perk.Title = perkName.." | ".. tostring(perkLevel) .. " | ".. tostring(perkCost[perkLevel]) .. "$"
          perkCallback(perkLevel)
        else 
          script.Failed:Play()
        end
			else 
				local purchase = script.Parent.Remotes.PurchaseEvent:InvokeServer(perkName,"Perk",Title)
				print("Purchase is",purchase)
				if purchase then
					--TODO: Purchase code
          perkt.Level = 1 
          perkLevel = 1
					perkOwned = true 
					perkt.IsOwned = true
					script.Purchase:Play()
					perk.Button.Text = "Upgrade"
          perk.Title = perkName.." | ".. tostring(perkLevel) .. " | ".. tostring(perkCost[perkLevel]) .. "$"
					perkCallback()
				else 
					script.Failed:Play()
				end
			end
		end)
	end
	local function setupPerks()
		for i,v in pairs(script.Parent.Frame.Perks:GetChildren()) do
			if v:IsA("Frame") then v:Destroy() end
		end
		for i,v in pairs(lib.Perks) do
			lib:CreatePerk(v,i)
		end
	end
	if IsWearing then
		module.WearingCharacter = Title --change later
		setupPerks()
	end 
  ui.Purchase.Button.MouseButton1Click:Connect(function ()
    if IsOwned then
        module.WearingCharacter = Title
         ui.Purchase.Button.Text = "CURRENTLY WEARING"
    else
	    local purchase = script.Parent.Remotes.PurchaseEvent:InvokeServer(Title,"Role")
			print("Purchase is",purchase)
        if purchase then
          IsOwned = true
          module.WearingCharacter = Title
          ui.Purchase.Button.Text = "CURRENTLY WEARING"
          script.Purchase:Play()
        else
          script.Failed:Play()
        end
    end
  end)

		

	return lib
end


return module

