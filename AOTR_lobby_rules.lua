-- Yozakura Lobby R1: pure decisions, also exercised by the offline tests.
local R = {}
function R.clean(value)
    return tostring(value or ""):gsub("<[^>]->", ""):gsub("’", "'"):gsub("%s+", " "):match("^%s*(.-)%s*$"):lower()
end
function R.mode(facts)
    -- Positive evidence on both sides is a transition, never a reason to guess.
    if facts.lobby and facts.mission then return "transition" end
    if facts.lobby then return "lobby" end
    if facts.mission then return "mission" end
    if facts.menu then return "menu" end
    return "unknown"
end
function R.number(text)
    local raw = R.clean(text):gsub(",", "")
    if not raw:match("^%d+%.?%d*[kmb]?$") then return nil end
    local base, suffix = raw:match("^(%d+%.?%d*)([kmb]?)$")
    return tonumber(base) * ({k=1000,m=1000000,b=1000000000,[""]=1})[suffix]
end
function R.market(card, config, spent)
    if card.robux or card.crate then return false, "Robux / random crate excluded" end
    if not config.currencies[card.currency] then return false, "Currency not selected" end
    if card.soldOut then return false, "Sold out" end
    if not card.price or card.price <= 0 then return false, "Price unreadable" end
    local allowed = (card.spin and config.spins) or (not card.spin and config.rarities[card.rarity])
    if not allowed then return false, "Item not selected" end
    local limit = config.budgets[card.currency] or 0
    if (spent[card.currency] or 0) + card.price > limit then return false, "Session budget reached" end
    if card.balance == nil or card.balance < card.price then return false, "Balance unreadable / insufficient" end
    return true, "Ready"
end
function R.plan(text)
    local result = {}
    for name in tostring(text or ""):gmatch("[^>\n]+") do
        name = name:match("^%s*(.-)%s*$")
        if name ~= "" then table.insert(result, name) end
    end
    return result
end
return R
