local lvji = fk.CreateSkill {
  name = "lvji",
}

Fk:loadTranslationTable{
  ["lvji"] = "律己",
  [":lvji"] = "出牌阶段，牌堆顶的4张牌对你可见（你响应牌后此数值-1直至你下回合结束）；"..
  "出牌阶段开始时，你可弃置一张牌，本回合你可使用其中花色与之相同的牌。",
  ["#lvji"] = "律己：观看牌堆顶%arg张牌，使用其中你需要的牌",
  ["#lvji-discard"] = "律己：弃一张牌，本回合你可使用牌堆顶此花色的牌",
  ["#lvji_trigger"] = "律己",

  ["$lvji"] = "律己",
  ["@lvji-turn"] = "律己",
  ["@lvji_num"] = "律己",
}

lvji:addEffect("viewas", {
  pattern = ".",
  expand_pile = function (self, player)
    return table.slice(player:getTableMark("lvji_view"), 1, player:getMark("@lvji_num") + 1)
  end,
  prompt = function(self, player)
    return "#lvji:::"..(player:getMark("@lvji_num"))
  end,
  card_filter = function(self, player, to_select, selected)
    if #selected == 0 and table.contains(player:getTableMark("lvji_view"), to_select) then
      local card = Fk:getCardById(to_select)
      if table.contains(player:getTableMark("@lvji-turn"), card:getSuitString(true)) then
        if Fk.currentResponsePattern == nil then
          return player:canUse(card) and not player:prohibitUse(card)
        else
          return Exppattern:Parse(Fk.currentResponsePattern):match(card)
        end
      end
    end
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    player:setMark("lvji_id", cards[1])
    return Fk:getCardById(cards[1])
  end,
  before_use = function(self, player, use)
    use.card:addSubcard(player:getMark("lvji_id"))
  end,
  enabled_at_play = function(self, player)
    return #player:getTableMark("lvji_view") > 0 and player.phase == Player.Play
  end,
  enabled_at_response = function(self, player)
    return #player:getTableMark("lvji_view") > 0 and player.phase == Player.Play
  end,
})

lvji:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return player == target and player.phase == Player.Play and player:hasSkill(lvji.name)
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    local cards = player.room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = lvji.name,
      cancelable = true,
      prompt = "#lvji-discard",
    })
    if #cards > 0 then
      local suit = Fk:getCardById(cards[1]):getSuitString(true)
      if not table.contains(player:getTableMark("@lvji-turn"), suit) then
        room:notifySkillInvoked(player, self.name, "special")
        room:addTableMark(player, "@lvji-turn", suit)
      end
    end
  end,
  on_cost = Util.FalseFunc,
})
    
local spec = {
  mute = true,
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(lvji.name)
  end,
  on_refresh = function(self, event, target, player, data)
    if not player:hasSkill(lvji.name) then return end
    local room = player.room
    local mark = player:getTableMark("lvji_view")
    local draw_pile = room.draw_pile
    local new_mark = {}
    for i = 0, 3, 1 do
      if #draw_pile <= i then break end
      table.insert(new_mark, draw_pile[i + 1])
    end
    if #new_mark ~= #mark then
      room:setPlayerMark(player, "lvji_view", new_mark)
      return false
    end
    for i = 1, #new_mark, 1 do
      if new_mark[i] ~= mark[i] then
        room:setPlayerMark(player, "lvji_view", new_mark)
        return false
      end
    end
  end,
}
  
lvji:addEffect(fk.AfterDrawPileShuffle, spec)
lvji:addEffect(fk.AfterCardsMove, spec)
  
local spec2 = {
  can_trigger = function(self, event, target, player, data)
    return player == target and (event == fk.CardResponding or (event == fk.CardUsing and data.responseToEvent))
    and player:hasSkill(lvji.name)
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@lvji_num", math.max(0, player:getMark("@lvji_num") - 1))
    room:notifySkillInvoked(player, self.name, "negative")
  end,
}

lvji:addEffect(fk.CardResponding, spec2)
lvji:addEffect(fk.CardUsing, spec2)
  
lvji:addEffect(fk.TurnEnd, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player == target
  end,
  on_trigger = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@lvji_num", 4)
  end,
})
    
lvji:addAcquireEffect(function (self, player, is_start)
  local room = player.room
  local draw_pile = room.draw_pile
  local mark = {}
  for i = 0, 3, 1 do
    if #draw_pile <= i then break end
    table.insert(mark, draw_pile[i + 1])
  end
  room:setPlayerMark(player, "lvji_view", mark)
  room:setPlayerMark(player, "@lvji_num", 4)
  room:setPlayerMark(player, "@lvji-turn", {})
end)
  
lvji:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "lvji_view", 0)
  player.room:setPlayerMark(player, "@lvji_num", 0)
  player.room:setPlayerMark(player, "@lvji-turn", {})
end)

return lvji
    
    -- local dangxian = fk.CreateSkill {
    --   name = "ty_ex__dangxian",
    --   tags = { Skill.Compulsory },
    --   dynamic_desc = function (self, player)
    --     if player:getMark("ty_ex__fuli") > 0 then
    --       return "ty_ex__dangxian_update"
    --     end
    --   end,
-- }

-- Fk:loadTranslationTable{
--   ["ty_ex__dangxian"] = "当先",
--   [":ty_ex__dangxian"] = "锁定技，回合开始时，你执行一个额外的出牌阶段，此阶段开始时你失去1点体力并从弃牌堆获得一张【杀】。",

--   [":ty_ex__dangxian_update"] = "锁定技，回合开始时，你执行一个额外的出牌阶段，此阶段开始时，你可以失去1点体力并从弃牌堆获得一张【杀】。",

--   ["#ty_ex__dangxian-invoke"] = "当先：你可以失去1点体力，从弃牌堆获得一张【杀】",

--   ["$ty_ex__dangxian1"] = "竭诚当先，一举克定！",
--   ["$ty_ex__dangxian2"] = "一马当先，奋勇杀敌！",
-- }

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

-- local lvji = fk.CreateTriggerSkill{
--   name = "lvji",
--   mute = true,
--   events = {},

--   refresh_events = {fk.CardUsing},
--   can_refresh = function (self, event, target, player, data)
--     return player == target and player:hasSkill(self, true) and data.card.suit ~= Card.NoSuit
--     and not table.contains(player:getTableMark("@lvji-turn"), data.card:getSuitString(true))
--   end,
--   on_refresh = function (self, event, target, player, data)
--     player.room:addTableMark(player, "@lvji-turn", data.card:getSuitString(true))
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
--     room:setPlayerMark(player, "@lvji-turn", #mark > 0 and mark or 0)
--   end,
-- }
-- local lvji_maxcards = fk.CreateMaxCardsSkill{
--   name = "#lvji_maxcards",
--   fixed_func = function(self, player)
--     if player:hasSkill(lvji) then
--       return (5 - #player:getTableMark("@lvji-turn"))
--     end
--   end,
-- }