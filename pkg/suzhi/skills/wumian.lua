local wumian = fk.CreateSkill {
  name = "wumian",
}

Fk:loadTranslationTable{
  ["wumian"] = "无眠",
  [":wumian"] = "每阶段每项限一次，当你的牌被弃置时，若其中包含："..
  "基本牌：你可视为使用一张不计次数的【杀】；"..
  "锦囊牌：你可移动场上一张牌并摸一张牌；"..
  "装备牌：你本回合下个阶段改为出牌阶段；",
  ["#wumian_basic"] = "视为使用【杀】",
  ["#wumian_trick"] = "移动牌并摸牌",
  ["#wumian_equip"] = "下阶段改为出牌阶段",
  ["#wumian-choose"] = "无眠：你可选择一项",
  ["#wumian_slash"] = "无眠：你可视为使用一张不计次数的【杀】",
  ["#wumian_move-choose"] = "无眠：你可移动场上一张牌并摸一张牌",

  ["$wumian"] = "无眠",
  ["wumian_types-phase"] = "无眠",
  ["@@wumian_extraplay-turn"] = "下阶段改出牌",
}

wumian:addEffect(fk.AfterCardsMove, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if not  player:hasSkill(wumian.name) then return end
    local cost_data = {}
    for _, move in ipairs(data) do
      if move.from == player and move.moveReason == fk.ReasonDiscard then
        for _, info in ipairs(move.moveInfo) do
          if (info.fromArea == Card.PlayerEquip or info.fromArea == Card.PlayerHand) and 
          not table.contains(player:getTableMark("wumian_types-phase"), Fk:getCardById(info.cardId).type) then
            table.insertIfNeed(cost_data, Fk:getCardById(info.cardId).type)
          end
        end
      end
    end
    if #cost_data > 0 then
      event:setCostData(self, { types = cost_data })
      return true
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = {}
    local types = event:getCostData(self).types
    for _, type in ipairs(types) do
      if type == Card.TypeBasic then
        table.insert(choices, "#wumian_basic")
      elseif type == Card.TypeTrick then
        table.insert(choices, "#wumian_trick")
      elseif type == Card.TypeEquip then
        table.insert(choices, "#wumian_equip")
      end
    end
    if #choices > 0 then
      local choice = room:askToChoice(player, {
        choices = choices,
        skill_name = wumian.name,
        all_choices = {"#wumian_basic", "#wumian_trick", "#wumian_equip"},
        prompt = "#wumian-choose",
      })
      if choice == "#wumian_basic" then
        local use = room:askToUseVirtualCard(player, {
          name = "slash",
          skill_name = wumian.name,
          prompt = "#wumian_slash",
        })
        if not use then return end
        room:addTableMark(player, "wumian_types-phase", Card.TypeBasic)
      elseif choice == "#wumian_trick" then
        local targets = room:askToChooseToMoveCardInBoard(player, {
          prompt = "#wumian_move-choose",
          skill_name = wumian.name,
          no_indicate = true,
          flag = "ej",
        })
        if #targets == 0 then return end
        room:askToMoveCardInBoard(player, {
          target_one = targets[1],
          target_two = targets[2],
          skill_name = wumian.name,
        })
        player:drawCards(1, wumian.name)
        room:addTableMark(player, "wumian_types-phase", Card.TypeTrick)
      elseif choice == "#wumian_equip" then
        room:setPlayerMark(player, "@@wumian_extraplay-turn", 1)
        room:addTableMark(player, "wumian_types-phase", Card.TypeEquip)
      end
    end
  end,
})

wumian:addEffect(fk.EventPhaseChanging, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and data.phase > Player.RoundStart and data.phase < Player.NotActive 
      and player:getMark("@@wumian_extraplay-turn") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:sendLog{
      type = "#PhaseChanged",
      from = player.id,
      arg = Util.PhaseStrMapper(data.phase),
      arg2 = "phase_play",
    }
    data.phase = Player.Play
    room:setPlayerMark(player, "@@wumian_extraplay-turn", 0)
  end,
})

return wumian


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

-- local wumian = fk.CreateActiveSkill{
--   name = "wumian",
--   prompt = "#wumian-active",
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
--     room:addPlayerMark(player, "wumian-turn", 1)
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
-- local wumian_targetmod = fk.CreateTargetModSkill{
--   name = "#wumian_targetmod",
--   bypass_times = function(self, player, skill, scope, card)
--     return card and player:hasSkill(wumian) and player:getMark("wumian-turn") > 0
--   end,
--   bypass_distances = function(self, player, skill, card)
--     return card and player:hasSkill(wumian) and player:getMark("wumian-turn") > 0
--   end,
-- }
-- local wumian_trigger = fk.CreateTriggerSkill{
--   name = "#wumian_trigger",
--   mute = true,
--   events = {fk.AfterCardUseDeclared},
--   can_trigger = function(self, event, target, player, data)
--     return player == target and player:hasSkill(wumian) and player:getMark("wumian-turn") > 0
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
--       card.skillName = "wumian"
--       card.suit = Card.NoSuit
--       card.color = Card.NoColor
--       data.card = card
--     end
--     local room = player.room
--     room:setPlayerMark(player, "wumian-turn", 0)
--   end,
-- }