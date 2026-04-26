-- shared/types.lua
-- Définitions de types LuaLS (annotations) partagées.

---@class KtTargetOption
---@field name?        string        Identifiant unique de l'option
---@field label        string        Texte affiché dans le menu
---@field icon?        string        Classe FontAwesome (ex: "fa-solid fa-cube")
---@field iconColor?   string        Couleur CSS de l'icône
---@field distance?    number        Distance max d'interaction (défaut : 7)
---@field groups?      string|string[]|table<string,number>  Filtre par groupe/job
---@field items?       string|string[]|table<string,number>  Filtre par item inventaire
---@field anyItem?     boolean       true = au moins un item suffit
---@field bones?       string|string[]  Os de l'entité ciblée
---@field offset?      vector3       Offset relatif à l'entité
---@field absoluteOffset? boolean    true = offset en coordonnées monde
---@field offsetSize?  number        Tolérance autour de l'offset (défaut : 1)
---@field canInteract? fun(entity:number,distance:number,coords:vector3,name:string,bone:number|nil):boolean
---@field onSelect?    fun(data:table):void
---@field export?      string        Nom de l'export à appeler
---@field event?       string        Événement client à déclencher
---@field serverEvent? string        Événement serveur à déclencher
---@field command?     string        Commande à exécuter
---@field openMenu?    string        Ouvre un sous-menu
---@field menuName?    string        Nom du menu auquel cette option appartient
---@field cooldown?    number        Durée de cooldown en ms
---@field hide?        boolean       Masqué (calculé runtime, ne pas renseigner)
---@field resource?    string        Resource propriétaire (injecté automatiquement)
---@field qtarget?     boolean       Compatibilité qtarget (onSelect reçoit entity brut)

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