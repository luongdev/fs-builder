-- file: locationforeign.lua
-- Keeps track of foreign registrations and records them 
-- in the db_data table.
conforeign = freeswitch.EventConsumer("STARTUP")
for e in (function() return conforeign:pop(1) end) do
  freeswitch.consoleLog("notice","event:" .. e:serialize("xml") .. "\n")
  -- element = nil
  -- element = e:getHeader("Orig-Event-Subclass")
  -- if element then
  --   if (element == "sofia::register") then
  --     registerstatus = e:getHeader("Orig-status")
  --     if (registerstatus == "Registered(UDP)") then
  --       ip = e:getHeader("Orig-FreeSWITCH-IPv4")
  --       name = e:getHeader("Orig-FreeSWITCH-Hostname")
  --       unitnumber = e:getHeader("Orig-from-user")
  --       customerid = e:getHeader("Orig-from-host")
  --       freeswitch.consoleLog("notice","Foreign registration: " .. registerstatus .. " ip: " .. ip .. " name: " .. name .. " unitnumber: " .. unitnumber .. " customerid: " .. customerid .. "\n")
  --       varfamily = "LOCATION"
  --       require "luasql.sqlite3"
  --       env = luasql.sqlite3()
  --       con = env:connect("/usr/local/freeswitch/db/call_limit.db")
  --       deletesql = "DELETE FROM db_data WHERE hostname = '"..name.."' AND realm = '"..customerid.."' AND data_key = '"..varfamily.."_"..unitnumber.."'"
  --       result = con:execute(deletesql)
  --       sql="INSERT INTO db_data (hostname,realm,data_key,data) VALUES ('"..name.."','"..customerid.."','"..varfamily.."_"..unitnumber.."','"..ip.."')"
  --       result = con:execute(sql)
  --       if (result == nil) then result = '' end
        
  --       con:close()
  --       env:close()
  --     end
  --   end
  -- end
end