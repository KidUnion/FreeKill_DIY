local chengyun = fk.CreateSkill {
  name = "chengyun",
}

Fk:loadTranslationTable{
  ["chengyun"] = "熵增",
  [":chengyun"] = "出牌阶段限一次，你可展示手牌并亮出牌堆顶五张牌，然后获得其中花色与你的手牌均不同的牌；你本回合使用的下一张牌无距离次数限制且不计花色。",
  ["#chengyun-active"] = "发动〖熵增〗，展示手牌并亮出牌堆顶五张牌",

  ["$chengyun"] = "熵增",
}

chengyun:addEffect("active",{
  prompt = "#chengyun-active",
  anim_type = "drawcard",
  can_use = function(self, player)
    return player:hasSkill(self) and player:usedSkillTimes(chengyun.name, Player.HistoryRound) == 0 
      and #player:getCardIds(Player.Hand) > 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local show_cards = player:getCardIds(Player.Hand)
    player:showCards(show_cards)
    room:addPlayerMark(player, "chengyun-turn", 1)
    local cards_suits = {}
    for _, id in ipairs(show_cards) do
      local card = Fk:getCardById(id)
      if not table.contains(cards_suits, card.suit) then
        table.insert(cards_suits, card.suit)
      end
    end
    local top_cards = room:getNCards(5)
    room:moveCardTo(top_cards, Card.Processing)
    room:delay(500)
    local match = {}
    for _, id in ipairs(top_cards) do
      local card = Fk:getCardById(id)
      if not table.contains(cards_suits, card.suit) then
        table.insert(match, card)
      end
    end
    room:moveCardTo(match, Player.Hand, player, fk.ReasonPrey, self.name)
    local cardsInProcessing = table.filter(top_cards, function(id) return room:getCardArea(id) == Card.Processing end)
    if #cardsInProcessing > 0 then
      room:moveCardTo(cardsInProcessing, Card.DiscardPile)
    end
  end,
})

chengyun:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and player:hasSkill(chengyun.name) and player:getMark("chengyun-turn") > 0
  end,
  bypass_distances = function (self, player, skill, card, to)
    return card and player:hasSkill(chengyun.name) and player:getMark("chengyun-turn") > 0
  end,
})

chengyun:addEffect(fk.AfterCardUseDeclared, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(chengyun.name) and player:getMark("chengyun-turn") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data:changeCard(data.card.name, Card.NoSuit, data.card.number, chengyun.name)
    local room = player.room
    room:setPlayerMark(player, "chengyun-turn", 0)
  end,
})

return chengyun

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

-- local chengyun = fk.CreateActiveSkill{
--   name = "chengyun",
--   prompt = "#chengyun-active",
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
--     room:addPlayerMark(player, "chengyun-turn", 1)
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
-- local chengyun_targetmod = fk.CreateTargetModSkill{
--   name = "#chengyun_targetmod",
--   bypass_times = function(self, player, skill, scope, card)
--     return card and player:hasSkill(chengyun) and player:getMark("chengyun-turn") > 0
--   end,
--   bypass_distances = function(self, player, skill, card)
--     return card and player:hasSkill(chengyun) and player:getMark("chengyun-turn") > 0
--   end,
-- }
-- local chengyun_trigger = fk.CreateTriggerSkill{
--   name = "#chengyun_trigger",
--   mute = true,
--   events = {fk.AfterCardUseDeclared},
--   can_trigger = function(self, event, target, player, data)
--     return player == target and player:hasSkill(chengyun) and player:getMark("chengyun-turn") > 0
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
--       card.skillName = "chengyun"
--       card.suit = Card.NoSuit
--       card.color = Card.NoColor
--       data.card = card
--     end
--     local room = player.room
--     room:setPlayerMark(player, "chengyun-turn", 0)
--   end,
-- }