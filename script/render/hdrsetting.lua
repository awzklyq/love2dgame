local metatab =  {
    __call = function(self, param1, ...)
    
    if type(param1) == 'function' then
        table.insert(self, param1);
    else
            for i, v in pairs(self) do
                if type(v) == 'function' then
                    self[i](param1, ...);
                end
            end
        end
    end
  }

  --参数统一
_G.HDRSetting = setmetatable({},  metatab)