local http = require("socket.http")
local cjson = require("cjson")

local response, status_code, headers = http.request("http://rook-prometheus.rook-ceph.svc.cluster.local:9090/api/v1/alerts")
if status_code == 200 then
  
  local success, json_body = pcall(cjson.decode, response)  -- Try to decode the JSON
  
  if success then
    local alerts = json_body["data"]["alerts"]
    
    for _, alert in ipairs(alerts) do
      if alert["labels"]["alertname"] == "CephSlowOps" or
      alert["labels"]["alertname"] == "CephDaemonSlowOps" then
        -- TODO: detect and set alert per pool/storage class
        RGWDebugLog("slow ops alert was detected")
        RGW["slow_ops_alert"] = true
        return
      end
    end
  else
    -- Handle JSON decoding error
    RGWDebugLog("Failed to parse JSON response: " .. json_body)  -- `json_body` will contain the error message
  end
else
    -- Handle HTTP request failure
    print("Failed to retrieve the page. HTTP Status code: " .. status_code)
end

