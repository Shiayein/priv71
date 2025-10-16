-- key_system.lua
-- ImmortalFarm - Key store (ASCII only)
-- Contains a single developer key with HWID binding.
-- IMPORTANT: Keep ASCII only (no fancy dashes/quotes).

local KeyStore = {}

-- Developer key: works for the specified HWID only
KeyStore.DEV_KEYS = {
  "83TE-8IYQ-ES31-EFK6" -- Your only key
}

-- Key bindings with HWID
KeyStore.KEYS = {
  ["83TE-8IYQ-ES31-EFK6"] = { hwid = "1B830866-70FD-4F14-9AF2-0603C4741363" } -- Your HWID
}

return KeyStore
