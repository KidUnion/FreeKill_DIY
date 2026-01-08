local miyan = fk.CreateSkill {
  name = "miyan",
}

Fk:loadTranslationTable{
  ["miyan"] = "迷烟",
  [":miyan"] = "当你成为【杀】的目标时，你可交给你攻击范围内的角色一张牌，然后获得此【杀】或令其交给你一张牌。",
  ["#miyan-give"] = "迷烟：你可以交给攻击范围内的一名角色一张牌",
  ["#miyan-choose"] = "迷烟：选择获得此【杀】或令%dest交给你一张牌",
  ["miyan1"] = "获得此【杀】",
  ["miyan2"] = "令%dest交给你一张牌",
  ["#miyan-regive"] = "迷烟：交给%dest一张牌",

  ["$miyan"] = "迷烟",
}

miyan:addEffect(fk.TargetConfirming, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash"
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p) return player:inMyAttackRange(p) end)
    if #targets < 1 then return end
    local target, card = room:askToChooseCardsAndPlayers(player, {
      min_num = 1,
      max_num = 1,
      min_card_num = 1,
      max_card_num = 1,
      targets = targets,
      pattern = ".",
      skill_name = miyan.name,
      prompt = "#miyan-give",
      cancelable = true,
    })
    if #target > 0 and card then
      event:setCostData(self, {tos = target, cards = card})
      room:obtainCard(target[1], card, false, fk.ReasonGive, player.id)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local target = event:getCostData(self).tos[1].id
    local choices = {"miyan2::"..target}
    if not data.card:isVirtual() then
      table.insert(choices, "miyan1")
    end
    local choice = room:askToChoice(player, {
      choices = { "miyan1", "miyan2::"..target },
      skill_name = miyan.name,
      prompt = "#miyan-choose::"..target,
    })
    if choice == "miyan1" then
      room:moveCardTo(data.card, Player.Hand, player, fk.ReasonPrey, self.name)
    elseif choice == "miyan2::"..target then
      local card = room:askToCards(room:getPlayerById(target), {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = miyan.name,
        prompt = "#miyan-regive:"..player.id,
        cancelable = false,
      })
      if #card > 0 then
        room:obtainCard(player, card[1], false, fk.ReasonGive, room:getPlayerById(target))
      end
    end
  end,
})

return miyan


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

-- local miyan = fk.CreateActiveSkill{
--   name = "miyan",
--   prompt = "#miyan-active",
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
--     room:addPlayerMark(player, "miyan-turn", 1)
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
-- local miyan_targetmod = fk.CreateTargetModSkill{
--   name = "#miyan_targetmod",
--   bypass_times = function(self, player, skill, scope, card)
--     return card and player:hasSkill(miyan) and player:getMark("miyan-turn") > 0
--   end,
--   bypass_distances = function(self, player, skill, card)
--     return card and player:hasSkill(miyan) and player:getMark("miyan-turn") > 0
--   end,
-- }
-- local miyan_trigger = fk.CreateTriggerSkill{
--   name = "#miyan_trigger",
--   mute = true,
--   events = {fk.AfterCardUseDeclared},
--   can_trigger = function(self, event, target, player, data)
--     return player == target and player:hasSkill(miyan) and player:getMark("miyan-turn") > 0
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
--       card.skillName = "miyan"
--       card.suit = Card.NoSuit
--       card.color = Card.NoColor
--       data.card = card
--     end
--     local room = player.room
--     room:setPlayerMark(player, "miyan-turn", 0)
--   end,
-- }