-- shared/constants.lua
-- Constantes globales partagées entre client et serveur.

-- ─── Types d'entités GTA ─────────────────────────────────────────────────────

ENTITY_TYPE_PED     = 1
ENTITY_TYPE_VEHICLE = 2
ENTITY_TYPE_OBJECT  = 3

-- ─── Flags de raycast ────────────────────────────────────────────────────────

RAYCAST_FLAG_ALL  = 511   -- Tout (map + entités + eau…)
RAYCAST_FLAG_MAP  = 26    -- Map uniquement

-- ─── Distances par défaut ────────────────────────────────────────────────────

DEFAULT_OPTION_DISTANCE = 7.0
DEFAULT_ZONE_DISTANCE   = 7.0
DEFAULT_BONE_DISTANCE   = 2.0

-- ─── Noms d'événements NUI ───────────────────────────────────────────────────

NUI_EVENT_VISIBLE    = 'visible'
NUI_EVENT_LEFT       = 'leftTarget'
NUI_EVENT_SET_TARGET = 'setTarget'

-- ─── Menus ───────────────────────────────────────────────────────────────────

MENU_HOME = 'home'