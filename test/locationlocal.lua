conlocal = freeswitch.EventConsumer("STARTUP")

for e in (function() return conlocal:pop(1) end) do
  freeswitch.consoleLog("notice","event:" .. e:serialize("xml") .. "\n")
  -- registerstatus = e:getHeader("status")
  -- if (registerstatus == "Registered(UDP)") then
  --   ip = e:getHeader("FreeSWITCH-IPv4")
  --   name = e:getHeader("FreeSWITCH-Hostname")
  --   unitnumber = e:getHeader("from-user")
  --   customerid = e:getHeader("from-host")
  --   freeswitch.consoleLog("notice","Local registration: " .. registerstatus .. " ip: " .. ip .. " name: " .. name .. " unitnumber: " .. unitnumber .. " customerid: " .. customerid .. "\n")
  --   varfamily = "LOCATION"
  --   require "luasql.sqlite3"
  --   env = luasql.sqlite3()
  --   con = env:connect("/usr/local/freeswitch/db/call_limit.db")
  --   deletesql = "DELETE FROM db_data WHERE hostname = '"..name.."' AND realm = '"..customerid.."' AND data_key = '"..varfamily.."_"..unitnumber.."'"
  --   result = con:execute(deletesql)
  --   sql="INSERT INTO db_data (hostname,realm,data_key,data) VALUES ('"..name.."','"..customerid.."','"..varfamily.."_"..unitnumber.."','"..ip.."')"
  --   result = con:execute(sql)
  --   freeswitch.consoleLog("notice","\n" .. "SQL statement:  " .. sql .."\n result: " .. result .. "\n");
  --   con:close()
  --   env:close()
  -- end
end