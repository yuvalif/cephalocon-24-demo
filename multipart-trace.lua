if Request.RGWOp == "init_multipart" or 
  Request.RGWOp == "complete_multipart" or 
  Request.RGWOp == "abort_multipart" or 
  Request.RGWOp == "list_multipart" or 
  (Request.RGWOp == "put_obj" and Request.HTTP.Parameters["uploadId"] ~= nil) then
  Request.Trace.Enable = true
else
  Request.Trace.Enable = false
end

