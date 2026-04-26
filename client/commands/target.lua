-- client/commands/target.lua
-- Commandes de débogage / administration pour kt_target.
-- Disponibles uniquement en mode debug ou pour les admins.

local debug_enabled = GetConvarInt('kt_target:debug', 0) == 1

if not debug_enabled then return end

-- ─────────────────────────────────────────────────────────────
-- /target_reload — recharge les options (utile en dev)
-- ─────────────────────────────────────────────────────────────

RegisterCommand('target_reload', function()
    TriggerEvent('onClientResourceStop', GetCurrentResourceName())
    print('[kt_target] Options réinitialisées.')
end, false)

-- ─────────────────────────────────────────────────────────────
-- /target_debug — affiche l'état courant du targeting
-- ─────────────────────────────────────────────────────────────

RegisterCommand('target_debug', function()
    local api   = require 'client.api'
    local state = require 'client.state'

    print('[kt_target] isActive   :', state.isActive())
    print('[kt_target] isDisabled :', state.isDisabled())
    print('[kt_target] isNuiFocused:', state.isNuiFocused())

    local opts = api.getTargetOptions()
    print('[kt_target] options.__global count:', opts.__global and #opts.__global or 0)
end, false)