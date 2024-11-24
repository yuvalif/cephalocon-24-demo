local http = require("socket.http")
local json = require("dkjson")

local response, status_code, headers = http.request("http://rook-prometheus.rook-ceph.svc.cluster.local:9090/api/v1/alerts")
if status_code == 200 then
  local json_body, pos, err = json.decode(response, 1, nil)
   alerts = json_body["data"]["alerts"]

   for _, alert in ipairs(alerts) do
     if alert["labels"]["alertname"] == "CephSlowOps" then
       -- TODO: detect and set alert per pool/storage class
       RGWDebugLog("slow ops alert was detected")
       RGW["slow_ops_alert"] = true
       return
     end
   end
else
    --- RGWDebugLog("Failed to parse alerts response from prometheus. error: " .. err)
    print("Failed to retrieve the page.")
end
