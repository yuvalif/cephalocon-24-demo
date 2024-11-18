requests = require("requests")

-- TODO: how to get the prometheus service address?
response = requests.get("http://<prometheus service>:9090/api/v1/alerts")

json_body, err = response.json()

if err then
  RGWDebugLog("Failed to parse alerts response from prometheus. error: " .. err)
  return
end

alerts = json_body["data"]["alerts"]

for _, alert in ipairs(alerts) do
  if alert["labels"]["alertname"] == "slow-ops" then
    -- TODO: detect and set alert per pool/storage class
    RGWDebugLog("slow ops alert was detected")
    RGW["slow_ops_alert"] = true
    return
  end
end

