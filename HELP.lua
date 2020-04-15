-- Retreiving Character Information - Server Side

local char = exports['pw_core']:getCharacter(source)

--------------------------
-- Inventory Management --
--------------------------

char:Inventory():Add().Default(InventoryID, "water", qty, {metapublic table}, {metaprivate table}, function(item)

end, OWNER)

-- Just a note about the above variables
-- `InventoryID` is a number corospoding with the Inventory Type -- Check MySQL `entity_types` Table which would corospond with the `id` 
-- field, for the type of inventory to store as.
-- `qty` is the amount of items of this type to give
-- `{metapublic table}` can contain a table of meta public information to store with the item, if no meta is needed just leave this as a blank table {}
-- `{metaprivate table}` can contain a table of meta private information to store with the item, if no meta is needed just leave this as a blank table {}
-- THE FUNCTION, this will return the successful state of the item added, including item information and the newly inserted record id, it is returned as a table,
-- `OWNER` -- This is the Owner to store the item under, if blank it defaults to the corosponding CID, else can be used for storing in other inventories aganst the "company" id for example.

char:Inventory():Add().Slot(InventoryID, "water", qty, {metapublic table}, {metaprivate table}, slot, function(item)

end, OWNER)

-- The above is a specific slot saving method, the variables are excately the same however with the additional slot variable which would contain the slot number to save in.

---- UPDATE METHODS

char:Inventory():Update().MetaData(InventoryID, record_id, {metapublic table}, {metaprivate table}, function(res)
    
end, OWNER)

-- Just a note about the above variables
-- `InventoryID` is a number corospoding with the Inventory Type -- Check MySQL `entity_types` Table which would corospond with the `id` 
-- field, for the type of inventory to store as.
-- `record_id` -- The ID of the specific item in teh stored_items table, generally returned in the item info as itemData.record_id
-- `{metapublic table}` can contain a table of meta public information to store with the item, if no meta is needed just leave this as a blank table {}
-- `{metaprivate table}` can contain a table of meta private information to store with the item, if no meta is needed just leave this as a blank table {}
-- THE FUNCTION, this will return the successful state of the item added, including item information and the newly inserted record id, it is returned as a table,
-- `OWNER` -- This is the Owner to store the item under, if blank it defaults to the corosponding CID, else can be used for storing in other inventories aganst the "company" id for example.


char:Inventory():Remove().Default(record_id, qty, function(res)
    
end)

-- `record_id` -- The ID of the specific item in teh stored_items table, generally returned in the item info as itemData.record_id
-- `qty` -- the amount of items to remove.
-- the function - - Will return true on success or false on failure

char:Inventory().getItemCount("water", function(res)
    print('you have '..res..' bottles of water')
end)

char:Inventory().getAllCount(function(res)
    print('you have '..res..' total slots occupied in your entire inventory')
end)

char:Inventory().getSlot(slotnumber, function(item)
    
end)

-- returns the item in a specific slot, as a table 

--==============================================================================================================--

--------------------
-- Cash Functions --
--------------------

local currentCash = char:Cash().getBalance()
-- returns the amount of cash the character currently has

local addCash = char:Cash().addCash(AMOUNT)
-- Adds the requested amount to there cash balance

local removeCash = char:Cash().removeCash(AMOUNT)
-- Removes the requested amount of cash from there balance

--==============================================================================================================--

-----------------------
-- Banking Functions --
-----------------------

local currentBank = char:Bank().getBalance()
-- returns the amount of bank money the character currently has

local addBank = char:Bank().addMoney(AMOUNT)
-- Adds the requested amount to there bank money balance

local removeBank = char:Bank().removeMoney(AMOUNT)
-- Removes the requested amount of bank money from there balance

--==============================================================================================================--

-------------------
-- Job Functions --
-------------------

local getJob = char:Job().getJob()
-- Will return the current job in a table

local setJob = char:Job().setJob(name, grade, workplace, salery)
-- name = "police"
-- grade = "boss"
-- workplace = 1
-- salery = 1000

local removeJob = char:Job().removeJob()
-- Removes the job from the player and sets the to unemployed

local setSalery = char:Job().setSalery(amount)
-- Adjusts the users salery with the specified amount

local toggleDuty = char:Job().toggleDuty()
-- Toggles the players job duty on or off.

