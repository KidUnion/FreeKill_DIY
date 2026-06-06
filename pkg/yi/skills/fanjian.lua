local fanjian = fk.CreateSkill {
  name = "yi__fanjian",
}

Fk:loadTranslationTable{
  ["yi__fanjian"] = "反间",
  [":yi__fanjian"] = "出牌阶段限一次，你可明置一名其他角色半数（向上取整且至多为5）手牌并明置一种花色的手牌，"..
  "直至你下回合开始，其使用明置牌后你可获得之，下次使用此花色的牌后失去一点体力。",
  ["#yi__fanjian"] = "反间：明置一名角色半数手牌并明置一种花色的手牌",
  ["@@yi__fanjian"] = "反间",
  ["@yi__fanjian_suits"] = "反间",
  ["#yi__fanjian-suit"] = "反间：明置一种花色的手牌",
  
  ["$yi__fanjian1"] = "挣扎吧，在血和暗的深渊里！",
  ["$yi__fanjian2"] = "痛苦吧，在仇与恨的地狱中！",
}

local mobileUtil = require "packages.mobile.mobile_util"

fanjian:addEffect("active", {
  anim_type = "offensive",
  prompt = "#yi__fanjian",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:hasSkill(fanjian.name) and player:usedSkillTimes(fanjian.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player and not to_select:isNude()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local card_num = math.min(math.ceil(target:getHandcardNum() / 2), 5)
    local cards = room:askToChooseCards(player, {
      skill_name = fanjian.name,
      target = target,
      min = card_num,
      max = card_num,
      flag = "h",
    })
    for _, id in ipairs(cards) do
      room:setCardMark(Fk:getCardById(id), "visible", 1)
    end
    target:showCards(cards)
    mobileUtil.displayCards(player, cards)
    if target.dead then return end
    room:addPlayerMark(target, "@@yi__fanjian", 1)
    local cards_bysuit = {["log_spade"] = {}, ["log_heart"] = {}, ["log_club"] = {}, ["log_diamond"] = {}}
    for _, id in ipairs(player:getCardIds("h")) do
      local card = Fk:getCardById(id)
      table.insert(cards_bysuit[card:getSuitString(true)], card)
    end
    local suits = table.filter({"log_spade", "log_heart", "log_club", "log_diamond"}, function(suit)
      return #cards_bysuit[suit] > 0
    end)
    local choice = room:askToChoice(player, {
      choices = suits,
      skill_name = fanjian.name,
      prompt = "#yi__fanjian-suit",
    })
    for _, card in ipairs(cards_bysuit[choice]) do
      room:setCardMark(card, "visible", 1)
    end
    player:showCards(cards_bysuit[choice])
    mobileUtil.displayCards(player, cards_bysuit[choice])
    room:addTableMarkIfNeed(target, "@yi__fanjian_suits", choice)
  end,
})

fanjian:addEffect(fk.CardUseFinished, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(fanjian.name) and target:getMark("@@yi__fanjian") > 0 and (data.card:getMark("visible") > 0 
      or table.contains(target:getTableMark("@yi__fanjian_suits"), data.card:getSuitString(true)))
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    if table.contains(target:getTableMark("@yi__fanjian_suits"), data.card:getSuitString(true)) then
      room:setPlayerMark(target, "@yi__fanjian_suits", 0)
      room:loseHp(target, 1, fanjian.name)
    end
    if data.card:getMark("visible") > 0 then
      room:setCardMark(data.card, "visible", 0)
      room:obtainCard(player, data.card, true, fk.ReasonJustMove, player, fanjian.name)
    end
  end,
})

fanjian:addEffect(fk.AfterCardsMove, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player.dead then return false end
    for _, move in ipairs(data) do
      if move.to == player then
        for _, info in ipairs(move.moveInfo) do
          player.room:setCardMark(Fk:getCardById(info.cardId), "visible", 0)
        end
      end
      return false
    end
  end,
})

fanjian:addEffect(fk.TurnStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(fanjian.name)
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      room:setPlayerMark(p, "@@yi__fanjian", 0)
      room:setPlayerMark(p, "@yi__fanjian_suits", 0)
    end
  end,
})

fanjian:addEffect("visibility", {
  card_visible = function (self, player, card, toChoose)
    local p = Fk:currentRoom():getCardOwner(card)
    if p and mobileUtil.cardIsVisible(Fk:currentRoom(), card) and player ~= p then
      return true
    end
  end,
})

return fanjian

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

-- local fanjian = fk.CreateActiveSkill{
--   name = "fanjian",
--   prompt = "#fanjian-active",
--   anim_type = "drawcard",
--   can_use = function(self, player)
--     return player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryRound) == 0 
--       and #player:getCardIds(Player.Hand) > 0
--   end,
--   card_filter = Util.FalseFunc,
--   on_use = function(self, room, effect)
--     local player = room:getPlayerById(effect.from)
--     local show_cards = player:getCardIds(Player.Hand)
--     player:showCards(show_cards)
--     room:addPlayerMark(player, "fanjian-turn", 1)
--     local cards_suits = {}
--     for _, id in ipairs(show_cards) do
--       local card = Fk:getCardById(id)
--       if not table.contains(cards_suits, card.suit) then
--         table.insert(cards_suits, card.suit)
--       end
--     end
--     local top_cards = room:getNCards(5)
--     room:moveCardTo(top_cards, Card.Processing)
--     room:delay(500)
--     local match = {}
--     for _, id in ipairs(top_cards) do
--       local card = Fk:getCardById(id)
--       if not table.contains(cards_suits, card.suit) then
--         table.insert(match, card)
--       end
--     end
--     room:moveCardTo(match, Player.Hand, player, fk.ReasonPrey, self.name)
--     local cardsInProcessing = table.filter(top_cards, function(id) return room:getCardArea(id) == Card.Processing end)
--     if #cardsInProcessing > 0 then
--       room:moveCardTo(cardsInProcessing, Card.DiscardPile)
--     end
--   end,
-- }
-- local fanjian_targetmod = fk.CreateTargetModSkill{
--   name = "#fanjian_targetmod",
--   bypass_times = function(self, player, skill, scope, card)
--     return card and player:hasSkill(fanjian) and player:getMark("fanjian-turn") > 0
--   end,
--   bypass_distances = function(self, player, skill, card)
--     return card and player:hasSkill(fanjian) and player:getMark("fanjian-turn") > 0
--   end,
-- }
-- local fanjian_trigger = fk.CreateTriggerSkill{
--   name = "#fanjian_trigger",
--   mute = true,
--   events = {fk.AfterCardUseDeclared},
--   can_trigger = function(self, event, target, player, data)
--     return player == target and player:hasSkill(fanjian) and player:getMark("fanjian-turn") > 0
--   end,
--   on_cost = Util.TrueFunc,
--   on_use = function(self, event, target, player, data)
--     if not (data.card:isVirtual() and #data.card.subcards == 0) then
--       local card = Fk:cloneCard(data.card.name, data.card.suit, data.card.number)
--       for k, v in pairs(data.card) do
--         if card[k] == nil then
--           card[k] = v
--         end
--       end
--       if data.card:isVirtual() then
--         card.subcards = data.card.subcards
--       else
--         card.id = data.card.id
--       end
--       card.skillNames = data.card.skillNames
--       card.skillName = "fanjian"
--       card.suit = Card.NoSuit
--       card.color = Card.NoColor
--       data.card = card
--     end
--     local room = player.room
--     room:setPlayerMark(player, "fanjian-turn", 0)
--   end,
-- }