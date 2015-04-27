math.randomseed(os.time())

request = function()
   wrk.headers["X-Counter"] = math.random(0,50)
   return wrk.format(nil, path)
end
