# SiiK-safezone-stash (qb-inventory v2 / qs-inventory)

Personal safezone stash using a wooden crate prop + qb-target.

## Features
- Container prop at each configured safezone stash location ( prop can be changed )
- Use qb-target on the crate to open the stash
- Each player gets their OWN private stash (based on citizenid)
- Saved to SQL by NEW qb-inventory (inventories table) via oxmysql

## Requirements
- qb-core
- qb-target
- oxmysql
- **One** inventory:
  - qb-inventory (v2 / 2.0.0+), **or**
  - qs-inventory (Quasar)

## Notes
- If you use **qs-inventory**, the stash is opened using Quasar's recommended events:
  `inventory:server:OpenInventory` + `inventory:client:SetCurrentStash` after registering the stash.
