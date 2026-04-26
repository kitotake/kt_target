-- client/main.lua
if not lib.checkDependency('kt_lib', '3.30.0', true) then return end

lib.locale()

require 'client.core.loop'        -- boucle principale
require 'client.debug'            -- debug zones/entités  
require 'client.defaults'         -- portes véhicules
require 'client.compat.qtarget'   -- compat qtarget