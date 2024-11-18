-- TODO: check for trace indicator per storage class
if RGW["slow_ops_alert"] == true then
  Request.Trace.Enable = true
  RGWDebugLog("tracing is enabled due to slow ops, for request: " .. Request.Id)
else
  Request.Trace.Enable = false
end

