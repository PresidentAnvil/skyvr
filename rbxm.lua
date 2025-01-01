return function(filename,filedata)
  local s,e = pcall(function()
    writefile(filename,filedata)
    local id = getcustomasset(filename)
    return game:GetObjects(id)
  end)

  if not s then return false end -- unsupported exploit
  return e
end
