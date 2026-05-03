-- shared/types.lua
-- Définitions de types LuaLS (annotations) partagées.

---@class KtTargetOption
---@field name?        string
---@field label        string
---@field icon?        string
---@field iconColor?   string
---@field distance?    number
---@field groups?      string|string[]|table<string,number>
---@field items?       string|string[]|table<string,number>
---@field anyItem?     boolean
---@field bones?       string|string[]
---@field offset?      vector3
---@field absoluteOffset? boolean
---@field offsetSize?  number
---@field canInteract? fun(entity:number,distance:number,coords:vector3,name:string,bone:number|nil):boolean
---@field onSelect?    fun(data:table):void
---@field export?      string
---@field event?       string
---@field serverEvent? string
---@field command?     string
---@field openMenu?    string
---@field menuName?    string
---@field cooldown?    number
---@field hide?        boolean
---@field resource?    string
---@field qtarget?     boolean

---@class KtTargetZoneBase
---@field name?     string
---@field debug?    boolean
---@field drawSprite? boolean
---@field options   KtTargetOption | KtTargetOption[]
---@field resource? string

---@class KtTargetPolyZone : KtTargetZoneBase
---@field points    vector3[]
---@field thickness? number

---@class KtTargetBoxZone : KtTargetZoneBase
---@field coords    vector3
---@field size      vector3
---@field rotation? number

---@class KtTargetSphereZone : KtTargetZoneBase
---@field coords    vector3
---@field radius    number