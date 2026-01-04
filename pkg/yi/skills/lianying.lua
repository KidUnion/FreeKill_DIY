local lianying = fk.CreateSkill {
  name = "yi__lianying",
}

Fk:loadTranslationTable{
	["yi__lianying"] = "连营",
  [":yi__lianying"] = "当你使用一种花色的最后一张手牌时，你可令此牌不计次数或额外结算一次；"..
  "当你非因使用失去一种花色的最后一张手牌时，你可观看牌堆顶一张牌并将之交给一名角色。",
  ["#yi__lianying-give"] = "连营：你可观看牌堆顶一张牌并分配",
  ["#yi__lianying-choose"] = "连营：你可令此牌不计次数或额外结算一次",

  ["$yi__lianying1"] = "生生不息，源源不绝。",
  ["$yi__lianying2"] = "失之淡然，得之坦然。",
}

lianying:addEffect(fk.AfterCardsMove, {
  anim_type = "special",
  prompt = "#yi__lianying-give",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(lianying.name) then
      for _, move in ipairs(data) do
        if move.from == player and move.moveReason ~= fk.ReasonUse then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand and not table.find(player:getCardIds("h"), function (id)
                return Fk:getCardById(id):compareSuitWith(Fk:getCardById(info.cardId))
              end) then return true
            end
          end
        end
      end
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:getNCards(1)
    room:askToYiji(player, {
      cards = cards,
      targets = room.alive_players,
      skill_name = lianying.name,
      min_num = #cards,
      max_num = #cards,
      expand_pile = cards,
    })
  end,
})
lianying:addEffect(fk.TargetSpecifying, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(lianying.name) and target == player and data.card.type ~= Card.TypeEquip and data.card.suit ~= Card.NoSuit and
    table.every(player.player_cards[Player.Hand], function (id) return Fk:getCardById(id).suit ~= data.card.suit end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = {"不计次数", "额外结算"}
    local choice = room:askToChoice(player, {
      choices = choices, 
      skill_name = self.name, 
      prompt = "#yi__lianying-choose"
    })
    if choice == "不计次数" then
      player:addCardUseHistory(data.card.trueName, -1)
    elseif choice == "额外结算" then
      data.use.additionalEffect = (data.use.additionalEffect or 0) + 1
    end
  end,
})

return lianying

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

  