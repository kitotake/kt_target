-- shared/config.lua
-- Configuration partagée entre client et serveur.

Config = Config or {}

-- ─── Ciblage ─────────────────────────────────────────────────────────────────

--- Distance maximale de ciblage par défaut (en unités GTA).
Config.maxDistance = 7.0

--- Distance maximale pour les zones interactives.
Config.zoneDistance = 7.0

--- Activer la ligne de vue (LoS) pour les entités non-map.
Config.requireLoS = true

--- Touches : true = toggle (appui/relâche), false = maintien
Config.toggleHotkey = GetConvarInt('kt_target:toggleHotkey', 0) == 1

--- Bouton souris pour sélectionner une option (24 = clic gauche, 25 = clic droit)
Config.mouseButton = GetConvarInt('kt_target:leftClick', 1) == 1 and 24 or 25

-- ─── Debug ───────────────────────────────────────────────────────────────────

Config.debug = GetConvarInt('kt_target:debug', 0) == 1

-- ─── Defaults ────────────────────────────────────────────────────────────────

--- Activer les interactions par défaut sur les véhicules (portes).
Config.defaults = GetConvarInt('kt_target:defaults', 1) == 1

-- ─── DrawSprite ──────────────────────────────────────────────────────────────

--- Nombre maximum de sprites de zone dessinés par frame (0 = désactivé).
Config.drawSprite = GetConvarInt('kt_target:drawSprite', 24)