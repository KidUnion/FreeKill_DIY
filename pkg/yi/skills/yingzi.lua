local yingzi = fk.CreateSkill {
  name = "yi__yingzi",
}

Fk:loadTranslationTable{
  ["yi__yingzi"] = "英姿",
  [":yi__yingzi"] = "摸牌阶段开始时，你可摸X张牌或获得一张你未明置的类型（由你指定）的牌；\r\n"..
  "你的手牌上限+X。（X为你明置牌的类型数）",
  ["@@visible"] = "明置",
  ["#yi__yingzi-choice"] = "英姿：你可选择一项",
  ["#yi__yingzi_basic"] = "获得一张基本牌",
  ["#yi__yingzi_equip"] = "获得一张装备牌",
  ["#yi__yingzi_trick"] = "获得一张锦囊牌",
  ["#yi__yingzi_draw"] = "摸%arg张牌",

  ["$yi__yingzi1"] = "交之总角，付之九州！",
  ["$yi__yingzi2"] = "定策分两治，纵马饮三江！",
}

yingzi:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yingzi.name) and player.phase == Player.Draw
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local types = {"basic", "equip", "trick"}
    for _, id in ipairs(player:getCardIds("h")) do
      local card = Fk:getCardById(id)
      if card:getMark("@@visible") > 0 and table.contains(types, card:getTypeString()) then
        table.removeOne(types, card:getTypeString())
      end
    end
    if #player:getCardIds("e") > 0 and table.contains(types, "equip") then
      table.removeOne(types, "equip")
    end
    
    local choices = {}
    for _, t in ipairs(types) do
      table.insert(choices, "#yi__yingzi_" .. t)
    end
    if #types < 3 then
      table.insert(choices, "#yi__yingzi_draw:::" .. (3 - #types))
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = yingzi.name,
      prompt = "#yi__yingzi-choice",
      cancelable = true,
    })
    if not choice then return false end
    event:setCostData(self, { choice = choice })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local choice = event:getCostData(self).choice
    local room = player.room
    local cards = {}
    if choice == "#yi__yingzi_basic" then
      cards = table.filter(room.draw_pile, function (id)
        return Fk:getCardById(id).type == Card.TypeBasic 
      end)
    elseif choice == "#yi__yingzi_equip" then
      cards = table.filter(room.draw_pile, function (id)
        return Fk:getCardById(id).type == Card.TypeEquip 
      end)
    elseif choice == "#yi__yingzi_trick" then
      cards = table.filter(room.draw_pile, function (id)
        return Fk:getCardById(id).type == Card.TypeTrick 
      end)
    else
      local num = tonumber(string.match(choice, "#yi__yingzi_draw:::(%d+)"))
      player:drawCards(num, self.name)
      return
    end
    room:obtainCard(player, table.random(cards), false, fk.ReasonJustMove, player, yingzi.name)
  end,
})

yingzi:addEffect("maxcards", {
  mute = true,
  correct_func = function(self, player)
    if player:hasSkill(yingzi.name) then
      local types = {}
      for _, id in ipairs(player:getCardIds("h")) do
        local card = Fk:getCardById(id)
        if card:getMark("@@visible") > 0 then
          table.insertIfNeed(types, card:getTypeString())
        end
      end
      if #player:getCardIds("e") > 0 then
        table.insertIfNeed(types, "equip")
      end
      return #types
    end
  end,
})

return yingzi

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

-- local yingzi = fk.CreateTriggerSkill{
--   name = "yingzi",
--   mute = true,
--   events = {},

--   refresh_events = {fk.CardUsing},
--   can_refresh = function (self, event, target, player, data)
--     return player == target and player:hasSkill(self, true) and data.card.suit ~= Card.NoSuit
--     and not table.contains(player:getTableMark("@yingzi-turn"), data.card:getSuitString(true))
--   end,
--   on_refresh = function (self, event, target, player, data)
--     player.room:addTableMark(player, "@yingzi-turn", data.card:getSuitString(true))
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
--     room:setPlayerMark(player, "@yingzi-turn", #mark > 0 and mark or 0)
--   end,
-- }
-- local yingzi_maxcards = fk.CreateMaxCardsSkill{
--   name = "#yingzi_maxcards",
--   fixed_func = function(self, player)
--     if player:hasSkill(yingzi) then
--       return (5 - #player:getTableMark("@yingzi-turn"))
--     end
--   end,
-- }