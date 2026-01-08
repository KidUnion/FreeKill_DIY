local wangzun = fk.CreateSkill {
  name = "yi__wangzun",
}

Fk:loadTranslationTable{
  ["yi__wangzun"] = "妄尊",
  [":yi__wangzun"] = "一号位的回合开始前，你可获得其一张牌，然后你可交给其一张牌并执行一个出牌阶段。",
  ["#yi__wangzun-invoke"] = "发动【妄尊】，获得%dest一张牌",
  ["#yi__wangzun-give"] = "妄尊：你可交给%dest一张牌并执行一个出牌阶段",
  
  ["$yi__wangzun1"] = "真命天子，八方拜服。",
  ["$yi__wangzun2"] = "归顺于我，封爵赏地。",
}

wangzun:addEffect(fk.TurnStart, {
  name = "yi__wangzun",
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return target.seat == 1 and player:hasSkill(wangzun.name) and #target:getCardIds("he") > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = wangzun.name, 
      prompt = "#yi__wangzun-invoke::"..target.id
    }) then
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card1 = room:askToChooseCard(player, {
      target = target, 
      flag = "he", 
      skill_name = wangzun.name
    })
    if not card1 then return false end
    room:obtainCard(player, card1, false, fk.ReasonPrey, player.id, wangzun.name)
    local card2 = room:askToCards(player, {
      skill_name = wangzun.name,
      include_equip = true,
      min_num = 1,
      max_num = 1,
      prompt = "#yi__wangzun-give::"..target.id,
    })
    if #card2 == 0 then return false end
    room:obtainCard(target, card2, false, fk.ReasonPrey, player.id, wangzun.name)
    player:gainAnExtraPhase(Player.Play)
  end,
})

return wangzun


-- dangxian:addEffect(fk.TurnStart, {
--   anim_type = "offensive",
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player:hasSkill(dangxian.name)
--   end,
--   on_use = function(self, event, target, player, data)
--     player:gainAnExtraPhase(Player.Play, dangxian.name)
--   end,
-- })

-- dangxian:addEffect(fk.EventPhaseStart, {
--   mute = true,
--   can_trigger = function(self, event, target, player, data)
--     return target == player and player:hasSkill(dangxian.name) and player.phase == Player.Play and
--       data.reason == dangxian.name
--   end,
--   on_cost = function (self, event, target, player, data)
--     if player:getMark("ty_ex__fuli") == 0 then
--       return true
--     else
--       return player.room:askToSkillInvoke(player, {
--         skill_name = dangxian.name,
--         prompt = "#ty_ex__dangxian-invoke",
--       })
--     end
--   end,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     room:loseHp(player, 1, dangxian.name)
--     if not player.dead then
--       local cards = room:getCardsFromPileByRule("slash", 1, "discardPile")
--       if #cards > 0 then
--         room:obtainCard(player, cards, true, fk.ReasonJustMove, player, dangxian.name)
--       end
--     end
--   end,
-- })

-- dangxian:addLoseEffect(function (self, player, is_death)
--   player.room:setPlayerMark(player, "ty_ex__fuli", 0)
-- end)

-- return dangxian

-- local luanjuan = fk.CreateTriggerSkill{
--   name = "luanjuan",
--   mute = true,
--   events = {},

--   refresh_events = {fk.CardUsing},
--   can_refresh = function (self, event, target, player, data)
--     return player == target and player:hasSkill(self, true) and data.card.suit ~= Card.NoSuit
--     and not table.contains(player:getTableMark("@luanjuan-turn"), data.card:getSuitString(true))
--   end,
--   on_refresh = function (self, event, target, player, data)
--     player.room:addTableMark(player, "@luanjuan-turn", data.card:getSuitString(true))
--   end,

--   on_acquire = function (self, player, is_start)
--     local room = player.room
--     if player ~= player.room.current then return end
--     local mark = {}
--     room.logic:getEventsOfScope(GameEvent.UseCard, 999, function(e)
--       local use = e.data[1]
--       if use.from == player.id and use.card.suit ~= Card.NoSuit then
--         table.insertIfNeed(mark, use.card:getSuitString(true))
--       end
--     end, Player.HistoryTurn)
--     room:setPlayerMark(player, "@luanjuan-turn", #mark > 0 and mark or 0)
--   end,
-- }
-- local luanjuan_maxcards = fk.CreateMaxCardsSkill{
--   name = "#luanjuan_maxcards",
--   fixed_func = function(self, player)
--     if player:hasSkill(luanjuan) then
--       return (5 - #player:getTableMark("@luanjuan-turn"))
--     end
--   end,
-- }