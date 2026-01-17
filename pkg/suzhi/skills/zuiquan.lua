local zuiquan = fk.CreateSkill {
  name = "zuiquan",
}

Fk:loadTranslationTable{
  ["zuiquan"] = "醉拳",
  [":zuiquan"] = "出牌阶段，你可视为使用一张【酒】并随机重铸一张手牌。当有【闪】进入弃牌堆时，你本回合使用的下一张【杀】或【酒】无次数限制",
  ["#zuiquan-active"] = "发动【醉拳】，视为使用一张【酒】并随机重铸一张手牌",
  
  ["$zuiquan"] = "醉拳",
  ["@@zuiquan-turn"] = "醉拳",
}

-- local zuiquan = fk.CreateViewAsSkill{
--   name = "zuiquan",
--   anim_type = "offensive",
--   prompt = "#zuiquan-active",
--   card_num = 0,
--   view_as = function(self)
--     local card = Fk:cloneCard("analeptic")
--     card.skillName = self.name
--     return card
--   end,
--   after_use = function(self, player, useData)
--     local room = player.room
--     local card = table.random(player:getCardIds(Player.Hand))
--     if not card then return end
--     room:recastCard(card, player, self.name)
--   end,
--   enabled_at_play = function (self, player)
--     return player.phase == Player.Play and player:canUse(Fk:cloneCard("analeptic")) and 
--     #player:getCardIds(Player.Hand) > 0
--   end,
--   enabled_at_response = Util.FalseFunc,
-- }
-- local zuiquan_trigger = fk.CreateTriggerSkill{
--   name = "#zuiquan_trigger",
--   events = {fk.AfterCardsMove},
--   can_trigger = function(self, event, target, player, data)
--     if not player:hasSkill(zuiquan) then return end
--     for _, move in ipairs(data) do
--       if move.toArea == Card.DiscardPile then
--         for _, info in ipairs(move.moveInfo) do
--           local card = Fk:getCardById(info.cardId)
--           return card and card.trueName == "jink"
--         end
--       end
--     end
--   end,
--   on_trigger = function(self, event, target, player, data)
--     local room = player.room
--     room:setPlayerMark(player, "@@zuiquan-turn", 1)
--   end,
--   refresh_events = {fk.CardUsing},
--   can_refresh = function (self, event, target, player, data)
--     return player == target and (data.card.trueName == "slash" or data.card.trueName == "analeptic")
--   end,
--   on_refresh = function (self, event, target, player, data)
--     local room = player.room
--     room:setPlayerMark(player, "@@zuiquan-turn", 0)
--   end
-- }
-- local zuiquan_targetmod = fk.CreateTargetModSkill{
--   name = "#zuiquan_targetmod",
--   bypass_times = function(self, player, skill, scope, card)
--     return (card.trueName == "slash" or card.trueName == "analeptic") and player:getMark("@@zuiquan-turn") > 0
--   end,
-- }

return zuiquan

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

-- local zuiquan = fk.CreateActiveSkill{
--   name = "zuiquan",
--   prompt = "#zuiquan-active",
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
--     room:addPlayerMark(player, "zuiquan-turn", 1)
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
-- local zuiquan_targetmod = fk.CreateTargetModSkill{
--   name = "#zuiquan_targetmod",
--   bypass_times = function(self, player, skill, scope, card)
--     return card and player:hasSkill(zuiquan) and player:getMark("zuiquan-turn") > 0
--   end,
--   bypass_distances = function(self, player, skill, card)
--     return card and player:hasSkill(zuiquan) and player:getMark("zuiquan-turn") > 0
--   end,
-- }
-- local zuiquan_trigger = fk.CreateTriggerSkill{
--   name = "#zuiquan_trigger",
--   mute = true,
--   events = {fk.AfterCardUseDeclared},
--   can_trigger = function(self, event, target, player, data)
--     return player == target and player:hasSkill(zuiquan) and player:getMark("zuiquan-turn") > 0
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
--       card.skillName = "zuiquan"
--       card.suit = Card.NoSuit
--       card.color = Card.NoColor
--       data.card = card
--     end
--     local room = player.room
--     room:setPlayerMark(player, "zuiquan-turn", 0)
--   end,
-- }