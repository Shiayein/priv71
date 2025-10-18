-- key_system.lua
-- ImmortalFarm - Key store (ASCII only)
-- Contains a single developer key with HWID binding.
-- IMPORTANT: Keep ASCII only (no fancy dashes/quotes).

local KeyStore = {}

-- Developer key: works for the specified HWID only
KeyStore.DEV_KEYS = {
  "83TE-8IYQ-ES31-EFK6" -- Your only key
}

-- Key bindings with HWID and users (empty by default)
KeyStore.KEYS = {
  ["83TE-8IYQ-ES31-EFK6"] = { users = {}, hwid = "A464C775-7637-4FEF-86E0-FB079291868B" } -- Your updated HWID
}

return KeyStore


