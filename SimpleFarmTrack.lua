local ADDON_NAME = "SimpleFarmTrack"
SimpleFarmTrack = {}
local async = LibAsync
local isTracking = false
local seconds = 0
local timerEnabled = false




local function GetItemPrice(itemLink)
    local price = LibPrice.ItemLinkToPriceGold(itemLink)
    if (price == nil or price == 0) then price = GetItemLinkValue(itemLink, true) end
    return price
end


local total = 0
function SimpleFarmTrack:OnItemLoot(eventCode, name, itemLink, quantity)
  if isTracking then
    total = total + GetItemPrice(itemLink) * quantity
    --SimpleFarmTrackLabel:SetText(string.format("%.2f",total))
  end
end

function SimpleFarmTrack:AddEventHandlers()
  EVENT_MANAGER:RegisterForEvent(
    ADDON_NAME,
    EVENT_LOOT_RECEIVED,
    function(...)
      async:Call(self:OnItemLoot(...))
    end
  )
end


SimpleFarmTrack:AddEventHandlers()

function SecondsToTime(second)
  local minutes = math.floor(second / 60)
  local secs = second % 60

  return string.format("%02d:%02d", minutes, secs)
end

function TimeIncrement()
  if timerEnabled then
    seconds = seconds + 0.25
    zo_callLater(function () TimeIncrement() end, 250)

    SimpleFarmTrackLabel:SetText(string.format("%.2f",total/seconds) .. " GPS - " .. SecondsToTime(seconds) .. " - " .. string.format("%.2f",total) .. " G")
  end
end









function Stop()
  SimpleFarmTrackLabel:SetText("")
  d("Final results: " .. string.format("%.2f",total/seconds) .. " GPS - " .. SecondsToTime(seconds) .. " - " .. string.format("%.2f",total) .. " G")
  seconds = 0
  total = 0
  isTracking = false
  timerEnabled = false
end

function Start()
  total = 0
  seconds = 0
  isTracking = true
  timerEnabled = true
  TimeIncrement()
end

function Pause()
  isTracking = false
  timerEnabled = false
end

function Resume()
  isTracking = true
  timerEnabled = true
  TimeIncrement()
end


function Help()
  d("/startsft -> Starts the timer and loot tracking")
  d("/endsft -> Ends the process")
  d("/pausesft -> Pause the timer and loot tracking")
  d("/resumesft -> Resume the timer and loot tracking")  
end

SLASH_COMMANDS["/endsft"] = Stop
SLASH_COMMANDS["/startsft"] = Start
SLASH_COMMANDS["/pausesft"] = Pause
SLASH_COMMANDS["/resumesft"] = Resume
SLASH_COMMANDS["/sfthelp"] = Help