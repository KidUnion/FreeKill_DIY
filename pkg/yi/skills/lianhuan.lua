local lianhuan = fk.CreateSkill {
  name = "yi__lianhuan",
}

Fk:loadTranslationTable{
  ["yi__lianhuan"] = "连环",
  [":yi__lianhuan"] = "出牌阶段，你可与一名未横置角色拼点，若你赢，你可使用一张本回合非因使用进入弃牌堆的牌；否则其横置。"..
  "若全场横置角色均相邻，你每回合首次发动此技能无目标限制且没赢的角色下一次受到的伤害改为火属性。",
  ["#yi__lianhuan"] = "连环：与一名角色拼点",
  ["#yi__lianhuan_use"] = "连环：你可使用其中一张牌",
  ["@@yi__lianhuan_lose"] = "连环 没赢",
  
  ["$yi__lianhuan1"] = "任凭潮涌，连环无惧！",
  ["$yi__lianhuan2"] = "并排横江，可利水战！",
}

function adjacent(players)
  local n = 0
  local has_chained = false
  for i, player in ipairs(players) do
    if player.chained then
      has_chained = true
    end
    if player.chained ~= players[i % #players + 1].chained then
      n = n + 1
    end
  end
  return has_chained and n < 3
end

lianhuan:addEffect("active", {
  anim_type = "offensive",
  prompt = "#yi__lianhuan",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:hasSkill(lianhuan.name) and not player:isKongcheng()
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player and not to_select:isKongcheng() and (not to_select.chained or 
      (player:usedSkillTimes(lianhuan.name, Player.HistoryPhase) == 0 and adjacent(Fk:currentRoom().alive_players)))
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local fire = false
    if player:usedSkillTimes(lianhuan.name, Player.HistoryPhase) == 1 and adjacent(player.room:getAlivePlayers()) then
      fire = true
    end
    local pindian = player:pindian({target}, lianhuan.name)
    if pindian.results[target].winner == player then
      if fire and not target.dead then
        room:setPlayerMark(target, "@@yi__lianhuan_lose", 1)
      end
      if player.dead then return end
      local all_cards, cards = {}, {}
      room.logic:getEventsByRule(GameEvent.MoveCards, 1, function(e)
        for _, move in ipairs(e.data) do
          if move.toArea == Card.DiscardPile then
            for _, info in ipairs(move.moveInfo) do
              if room:getCardArea(info.cardId) == Card.DiscardPile then
                if move.moveReason ~= fk.ReasonUse and
                    table.insertIfNeed(all_cards, info.cardId) then
                  table.insertIfNeed(cards, info.cardId)
                else
                  table.insertIfNeed(all_cards, info.cardId)
                end
              end
            end
          end
        end
      end, nil, Player.HistoryTurn)
      if #cards == 0 then return end
      local use = room:askToUseRealCard(player, {
        pattern = cards,
        skill_name = lianhuan.name,
        prompt = "#yi__lianhuan_use",
        extra_data = {
          bypass_times = true,
          extraUse = true,
          expand_pile = cards,
        },
        skip = false,
      })
    else
      if not target.dead then
        target:setChainState(true)
        if fire and pindian.results[target].winner ~= target then
          room:setPlayerMark(target, "@@yi__lianhuan_lose", 1)
        end
      end
      if not player.dead and fire then
        room:setPlayerMark(player, "@@yi__lianhuan_lose", 1)
      end
    end
  end,
})

lianhuan:addEffect(fk.DetermineDamageInflicted, {
  can_refresh = function(self, event, target, player, data)
    return target:getMark("@@yi__lianhuan_lose") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.damageType = fk.FireDamage
    player.room:setPlayerMark(target, "@@yi__lianhuan_lose", 0)
  end,
})

return lianhuan

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

-- local lianhuan = fk.CreateActiveSkill{
--   name = "lianhuan",
--   prompt = "#lianhuan-active",
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
--     room:addPlayerMark(player, "lianhuan-turn", 1)
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
-- local lianhuan_targetmod = fk.CreateTargetModSkill{
--   name = "#lianhuan_targetmod",
--   bypass_times = function(self, player, skill, scope, card)
--     return card and player:hasSkill(lianhuan) and player:getMark("lianhuan-turn") > 0
--   end,
--   bypass_distances = function(self, player, skill, card)
--     return card and player:hasSkill(lianhuan) and player:getMark("lianhuan-turn") > 0
--   end,
-- }
-- local lianhuan_trigger = fk.CreateTriggerSkill{
--   name = "#lianhuan_trigger",
--   mute = true,
--   events = {fk.AfterCardUseDeclared},
--   can_trigger = function(self, event, target, player, data)
--     return player == target and player:hasSkill(lianhuan) and player:getMark("lianhuan-turn") > 0
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
--       card.skillName = "lianhuan"
--       card.suit = Card.NoSuit
--       card.color = Card.NoColor
--       data.card = card
--     end
--     local room = player.room
--     room:setPlayerMark(player, "lianhuan-turn", 0)
--   end,
-- }