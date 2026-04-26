# kt_target — Global Structure

```text
kt_target/
|   architecture.md
|   fxmanifest.lua
|   README.md
|   text.txt
|   
+---.github
|   +---actions
|   |       bump-manifest-version.js
|   |       
|   \---workflows
|           create-release.yml
|           
+---client
|   |   api.lua 'A supprime ?'
|   |   debug.lua 'A supprime ?'
|   |   defaults.lua 'A supprime ?'
|   |   main.lua 'A supprime ?'
|   |   state.lua 'A supprime ?'
|   |   utils.lua 'A supprime ?'
|   |   
|   +---admin
|   |       object_target.lua
|   |       
|   +---api
|   |       exports.lua
|   |       
|   +---commands
|   |       target.lua
|   |       
|   +---compat
|   |       qtarget.lua
|   |       
|   +---core
|   |       detection.lua
|   |       executor.lua
|   |       loop.lua
|   |       raycast.lua
|   |       resolver.lua
|   |       
|   +---debug
|   |       debug.lua
|   |       
|   +---framework
|   |       esx.lua
|   |       nd.lua
|   |       ox.lua
|   |       qbx.lua
|   |       union.lua
|   |       
|   +---nui
|   |       bridge.lua
|   |       focus.lua
|   |       messages.lua
|   |       
|   +---registry
|   |       entities.lua
|   |       globals.lua
|   |       models.lua
|   |       zones.lua
|   |       
|   +---state
|   |       target.lua
|   |       
|   \---utils
|           entity.lua
|           math.lua
|           table.lua
|           
+---locales
|       en.json
|       fr.json
|       
+---server
|       main.lua
|       
+---shared
|       config.lua
|       constants.lua
|       middleware.lua
|       types.lua
|       utils.lua
|       validators.lua
|       
\---web
    |   .gitignore
    |   architecture.md
    |   eslint.config.js
    |   index.html
    |   package-lock.json
    |   package.json
    |   README.md
    |   tsconfig.app.json
    |   tsconfig.json
    |   tsconfig.node.json
    |   vite.config.ts
    |   
    +---dist
    |   |   favicon.svg
    |   |   icons.svg
    |   |   index.html
    |   |   
    |   \---assets
    |           index-Cbuimybg.css
    |           index-DikCWBRv.js
    |           
    |               
    +---public
    |       favicon.svg
    |       icons.svg
    |       
    \---src
        |   App.css
        |   App.tsx
        |   index.css
        |   main.tsx
        |   
        +---assets
        |       hero.png
        |       react.svg
        |       vite.svg
        |       
        +---components
        |       CooldownBar.tsx
        |       index.ts
        |       NoOptions.tsx
        |       Option.tsx
        |       
        +---config
        |       index.ts
        |       
        +---features
        |   +---dev
        |   \---target
        |           index.ts
        |           useTargetStore.ts
        |           
        +---hooks
        |       index.ts
        |       useCooldown.ts
        |       useNuiMessage.ts
        |       useVisibility.ts
        |       
        +---providers
        |       index.ts
        |       ThemeProvider.tsx
        |       
        +---styles
        |       main.scss
        |       
        +---theme
        |       index.ts
        |       
        +---typings
        |       index.ts
        |       
        \---utils
                eye.ts
                fetchNui.ts
                index.ts
                options.ts
```

## Overview

`kt_target` is organized as a modular FiveM target system with:

- a shared layer for constants, config, types, middleware, validators, and utilities;
- a client layer split into core logic, registries, UI bridge, framework adapters, state, APIs, commands, and debugging tools;
- a minimal server layer for validation and orchestration;
- a React/Vite web UI for NUI rendering;
- locale files for French and English;
- GitHub automation for release/version management.

## Main responsibilities

### `shared/`
Cross-runtime definitions and helpers used by both client and server.

### `client/core/`
Low-level targeting pipeline:
- `raycast.lua`: raw entity detection
- `detection.lua`: candidate filtering
- `resolver.lua`: option aggregation and priority
- `executor.lua`: action execution
- `loop.lua`: optimized update loop

### `client/registry/`
Stores interactions by target type:
- entities
- models
- zones
- globals

### `client/nui/`
Client-side bridge between Lua and the React interface.

### `client/framework/`
Framework adapters for different ecosystems:
- ESX
- QBX
- OX
- ND
- Union

### `server/`
Server-side validation, ACL, and cleanup logic.

### `web/`
The frontend interface built with React, TypeScript, and Vite.

## Notes

This structure is already suitable for a scalable production target system. The next step is usually to keep the execution flow strictly defined:

`loop -> raycast -> detection -> resolver -> state -> nui -> executor`
