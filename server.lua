local ESX = nil;

TriggerEvent("esx:getSharedObject", function(obj)
	ESX = obj;
end);

function GetKeybox(id)
	for k,v in pairs(Config.Keyboxes) do
		if v.id == id then
			return v;
		end
	end
	
	return nil;
end

function CanUseKeybox(src, keyboxId)
	local xPlayer = ESX.GetPlayerFromId(src);

	local keybox = GetKeybox(keyboxId);
		
	-- check if a valid keybox id was provided
	if not keybox then
		print("no keybox", keyboxId);
		return false;
	end
		
	local job = xPlayer.getJob();
	
	-- check if the user has the correct job
	if keybox.job and job.name ~= keybox.job then
		print("wrong job", job.name, keybox.job);
		return false;
	end
	
	-- check if the user has the correct grade
	if keybox.grade and job.grade < keybox.grade then
		print("wrong grade", job.grade, keybox.grade);
		return false;
	end
	
	return true;
end

function GetVehicleOwner(plate, cb)
	MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE plate = @plate", {
		["@plate"] = plate
	}, function(results)
		if #results > 0 then
			cb(results[1].owner);
		else
			cb(nil);
		end
	end);
end

function SetVehicleOwner(plate, owner, cb)
	MySQL.Async.fetchAll("UPDATE owned_vehicles SET owner = @owner WHERE plate = @plate", {
		["@owner"] = owner,
		["@plate"] = plate,
	}, function()
		cb();
	end);
end

RegisterNetEvent("ngKeybox:StoreKey", function(plate, keyboxId)
	local src = source;
	local xPlayer = ESX.GetPlayerFromId(src);
	
	if not CanUseKeybox(src, keyboxId) then
		return;
	end

	GetVehicleOwner(plate, function(owner)
		if owner ~= xPlayer.identifier then
			print("wrong owner", owner);
			return;
		end
		
		SetVehicleOwner(plate, "keybox_" .. keyboxId, function()
			xPlayer.showNotification(_U("key_stored", plate));
		end);
	end);
end);

RegisterNetEvent("ngKeybox:TakeKey", function(plate, keyboxId)
	local src = source;
	local xPlayer = ESX.GetPlayerFromId(src);
	
	if not CanUseKeybox(src, keyboxId) then
		return;
	end

	GetVehicleOwner(plate, function(owner)
		if owner ~= "keybox_" .. keyboxId then
			print("wrong owner", owner);
			return;
		end
		
		SetVehicleOwner(plate, xPlayer.identifier, function()
			xPlayer.showNotification(_U("key_taken", plate));
		end);
	end);
end);

function GetKeys(owner, cb)
	MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE owner = @owner", {
		["@owner"] = owner,
	}, function(results)
		local keys = {};
		
		for k,v in pairs(results) do
			local label = v.plate;
			local data = json.decode(v.vehicle);
			
			table.insert(keys, {
				label = label,
				plate = v.plate,
				name = v.vehiclename,
				model = data.model,
			});
		end
		
		cb(keys);
	end);
end

ESX.RegisterServerCallback("ngKeybox:GetKeys", function(src, cb)
	local xPlayer = ESX.GetPlayerFromId(src);
	
	GetKeys(xPlayer.identifier, cb);
end);

ESX.RegisterServerCallback("ngKeybox:GetStoredKeys", function(src, cb, keyboxId)
	GetKeys("keybox_" .. keyboxId, cb);
end);