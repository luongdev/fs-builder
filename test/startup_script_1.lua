con = freeswitch.EventConsumer("CUSTOM","multicast::event")
for e in (function() return con:pop(1) end) do
  freeswitch.consoleLog("notice","event\n" .. e:serialize("xml"))

  e:fire();
  -- element = nil
  -- element = e:getHeader("Orig-status")
  -- if element then
  --   if ((element == "CS_EXECUTE") or (element == "CS_ROUTING") or (element == "CS_HANGUP")) then
  --     event = freeswitch.Event("PRESENCE_IN")
  --     event:addHeader("proto", "sip")
  --     event:addHeader("event_type", "presence")
  --     event:addHeader("alt_event_type", "dialog")
  --     event:addHeader("Presence-Call-Direction", "outbound")
  --     from = e:getHeader("Orig-from")
  --     event:addHeader("from", from)
  --     event:addHeader("login", from)
  --     if (element == "CS_HANGUP") then event:addHeader("answer-state", "terminated")
  --     else event:addHeader("answer-state", "confirmed") end
  --     event:fire()
  --     freeswitch.consoleLog("notice","event\n" .. e:serialize("xml"))
  --   end
  -- end
end