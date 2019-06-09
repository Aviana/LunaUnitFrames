# LibClassicDurations

Tracks all whitelisted aura applications and then returns UnitAura-friendly _duration, expirationTime_ pair

### Usage:
    local LibClassicDurations = LibStub("LibClassicDurations")
    LibClassicDurations:RegisterFrame(addon) -- tell library it's being used for something

    hooksecurefunc("CompactUnitFrame_UtilSetBuff", function(buffFrame, unit, index, filter)
        local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura = UnitBuff(unit, index, filter);


        local durationNew, expirationTimeNew = LibClassicDurations:GetAuraDurationByUnit(unit, spellId, unitCaster)
        if duration == 0 and durationNew then
            duration = durationNew
            expirationTime = expirationTimeNew
        end

        local enabled = expirationTime and expirationTime ~= 0;
        if enabled then
            local startTime = expirationTime - duration;
            CooldownFrame_Set(buffFrame.cooldown, startTime, duration, true);
        else
            CooldownFrame_Clear(buffFrame.cooldown);
        end
    end)

![Screenshot](https://i.imgur.com/ZE6IWys.jpg)