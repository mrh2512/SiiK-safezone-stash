# SiiK-safezone-stash

Personal **safezone stash crates** for QBCore servers.

This resource spawns a crate prop in each configured safezone and lets players open a **private stash** (per-player, not shared) using **qb-target**.  
Stash opening is routed through **SiiK-bridge** so it works with qb-like inventories (qb/ps/lj/qs-style stash events), and will use a direct `OpenInventory` export when available.

---

## Features

- **Multiple safezones** (configurable radius + stash crate location)
- **Prop stash crate** per safezone (spawned client-side)
- **qb-target** interaction to open stash
- **Private stash per player**
  - Stash ID is based on citizenid: `siik_safezone_<citizenid>`
- **Server-side validation**
  - Players must be inside a safezone (server checks distance) before opening
- **Inventory support via SiiK-bridge**
  - Uses the active inventory info from your bridge to choose the best open method
  - Falls back to widely-supported qb-like stash open events

---

## Requirements

### Hard Requirements
- **qb-core**
- **qb-target**
- **oxmysql**
- **SiiK-bridge**

### Inventory Notes (Persistence)
- The stash itself is opened through inventory events/exports.
- **Persistence is handled by your inventory system** (example: qb-inventory stores stash contents in its DB tables).
- This resource does **not** create its own stash table — it relies on the inventory you’re using.

---

## Installation

1. **Copy** the folder into your server resources, for example:
resources/[siik]/SiiK-safezone-stash

pgsql
Copy code

2. Ensure your inventory’s **SQL is installed** (example: qb-inventory requires its stash/inventory tables).
- If you’re using qb-inventory: make sure its SQL has been imported already.

3. Add to `server.cfg` (order matters):
```cfg
ensure oxmysql
ensure qb-core
ensure qb-target
ensure SiiK-bridge
ensure SiiK-safezone-stash
Restart the server.

Configuration (config.lua)
Stash Settings
lua
Copy code
Config.Stash = {
    label = 'Safezone Stash',
    slots = 40,
    maxweight = 200000, -- grams
}
Prop Settings
lua
Copy code
Config.Prop = {
    model = `prop_container_03mb`,
    freeze = true,
    invincible = true,
}
qb-target Settings
lua
Copy code
Config.Target = {
    icon = 'fas fa-box-open',
    label = 'Open Safezone Stash',
    distance = 2.0,
}
Safezones
Each safezone has:

name : display name

center : safezone center point

radius : safezone radius in meters

stashProp.coords : where the crate spawns

stashProp.heading : prop heading

Example:

lua
Copy code
Config.Safezones = {
  {
    name = 'Little Soul',
    center = vector3(-496.51, -1003.68, 23.5),
    radius = 65.0,
    stashProp = {
      coords = vector3(-496.53, -1002.84, 23.55),
      heading = 179.65,
    }
  },
}
✅ Tip: Use a dev tool like /vector3 helpers or any coords tool to grab accurate placement.

How It Works
Client
On resource start:

Loads the configured prop model

Spawns the crate at each safezone stash location

Adds qb-target interaction to that crate

When a player uses the target:

Client checks they are inside a safezone (fast local check)

Triggers the server event to open the stash

Server
On SiiK-safezone-stash:server:OpenPersonalStash:

Gets the player (QBCore)

Validates they are inside a safezone (authoritative check)

Builds stash ID: siik_safezone_<citizenid>

Uses SiiK-bridge to detect active inventory and open stash via:

exports[invRes]:OpenInventory(...) if the inventory provides it

Fallback to qb-like stash open events (common pattern)

Events
Server
SiiK-safezone-stash:server:OpenPersonalStash

Triggered when player interacts with the safezone crate

Client
SiiK-safezone-stash:client:OpenStash

Opens stash using qb-like inventory events:

inventory:server:OpenInventory

inventory:client:SetCurrentStash

Customization Ideas
Change crate model to match your server theme (e.g. lockers, safes, weapon crates)

Increase/decrease radius per zone

Add more zones (city, hospital, job hubs, etc.)

Adjust slots/max weight per your economy balance

Troubleshooting
“Crate doesn’t spawn”
Confirm the prop model exists:

Config.Prop.model = \prop_container_03mb``

Check client console for:

[SiiK-safezone-stash] Failed to load prop model...

Ensure the resource is started and config.lua is valid.

“Target option doesn’t appear”
Ensure qb-target is running before this resource.

Confirm distance isn’t too small.

Make sure the entity exists (crate spawned).

“Stash opens but doesn’t save”
This is almost always your inventory SQL / persistence setup.

Verify your inventory resource has its tables imported and is configured to persist stashes.

“You must be inside a safezone…”
You’re outside the configured radius, or the center/radius needs adjusting.

Remember: the server validates distance, not just the client.

“Active inventory not supported”
Your SiiK-bridge is detecting an inventory key that this resource can’t open via export/events.

Fix by:

Ensuring SiiK-bridge returns an inventory that supports either:

OpenInventory export, OR

qb-like stash events (inventory:server:OpenInventory)