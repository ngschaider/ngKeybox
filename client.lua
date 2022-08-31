local menuPool = NativeUI.CreatePool();
local ESX = nil;

TriggerEvent("esx:getSharedObject", function(obj)
	ESX = obj;
end);

Citizen.CreateThread(function()
	while true do 
		menuPool:ProcessMenus()
		
		local coords = GetEntityCoords(PlayerPedId());
		
		local job = ESX.GetPlayerData().job;
		for _,keybox in pairs(Config.Keyboxes) do
			if not keybox.job or (job and job.name == keybox.job) then
				if not keybox.grade or (job and job.grade >= keybox.grade) then
					if GetDistanceBetweenCoords(coords, keybox.pos[1], keybox.pos[2], keybox.pos[3], true) < keybox.radius then
						if not menuPool:IsAnyMenuOpen() then
							ESX.ShowHelpNotification(_U("open_menu_hint"));
							
							if IsControlJustPressed(0, 38) then
								OpenMenu(keybox.id);
							end
						end
					end
				end
			end
		end

		Citizen.Wait(0)
	end
end);

function GetVehicleLabel(data)
	local label = data.plate;
	if data.name then
		label = label .. " - " .. data.name;
	else
		label = label .. " - " .. GetDisplayNameFromVehicleModel(data.model);
	end
	
	return label;
end
		
function OpenMenu(keyboxId)
	local playerPed = GetPlayerPed(PlayerId());
	
	ESX.TriggerServerCallback("ngKeybox:GetStoredKeys", function(storedKeys)
		ESX.TriggerServerCallback("ngKeybox:GetKeys", function(keys)
			local menu = NativeUI.CreateMenu(_U("menu_title"), _U("menu_subtitle"));
			menuPool:Clear();
			menuPool:Add(menu);
			collectgarbage();
			
			local takeKeyMenu = menuPool:AddSubMenu(menu, _U("take_key"));
			for k,v in pairs(storedKeys) do
				local label = GetVehicleLabel(v);
				v.item = NativeUI.CreateItem(label, v.description or "");
				takeKeyMenu:AddItem(v.item);
			end
			takeKeyMenu.OnItemSelect = function(sender, item, index)
				for k,v in pairs(storedKeys) do
					if v.item == item then
						TriggerServerEvent("ngKeybox:TakeKey", v.plate, keyboxId);
						menuPool:CloseAllMenus();
						return;
					end
				end
			end;
			
			local storeKeyMenu = menuPool:AddSubMenu(menu, _U("store_key"));
			for k,v in pairs(keys) do
				local label = GetVehicleLabel(v);
				v.item = NativeUI.CreateItem(label, v.description or "");
				storeKeyMenu:AddItem(v.item);
			end
			storeKeyMenu.OnItemSelect = function(sender, item, index)
				for k,v in pairs(keys) do
					if v.item == item then
						TriggerServerEvent("ngKeybox:StoreKey", v.plate, keyboxId);
						menuPool:CloseAllMenus();
						return;
					end
				end
			end;
			
			menu:Visible(true);

			menuPool:MouseControlsEnabled(false);
			menuPool:MouseEdgeEnabled(false);
			menuPool:RefreshIndex();
		end);
	end, keyboxId);
end

