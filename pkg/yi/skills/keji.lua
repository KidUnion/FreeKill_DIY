local keji = fk.CreateSkill {
  name = "yi__keji",
  derived_piles = "$yi__keji",
}

Fk:loadTranslationTable{
  ["yi__keji"] = "克己",
  [":yi__keji"] = "出牌阶段开始时，你可背面朝上移出任意张手牌并发动一次【攻心】；你或你发动过【白衣】的回合结束时，你可将其中任意张牌暗置于装备区。",
  ["$yi__keji"] = "克己",
  ["#yi__keji-remove"] = "克己：你可背面朝上移出任意张手牌",
  ["#yi__keji-invoke"] = "克己：你可将“克己”牌暗置于装备区",
  ["#yi__keji-put"] = "克己：选择一张“克己”牌和一个空装备栏，将其暗置于装备区",

  ["gongxin"] = "攻心",
  ["#gongxin-ask"] = "你可对一名其他角色发动【攻心】",
  ["#gongxin-view"] = "攻心：观看%dest的手牌",
  ["gongxin_discard"] = "弃置此牌",
  ["gongxin_put"] = "将此牌置于牌堆顶",
}

local function getEmptyEquipSlots(player)
  local slots = player:getAvailableEquipSlots()
  for _, id in ipairs(player:getCardIds("e")) do
    local card = player:getVirtualEquip(id) or Fk:getCardById(id)
    if card.type == Card.TypeEquip then
      table.removeOne(slots, Util.convertSubtypeAndEquipSlot(card.sub_type))
    end
  end
  return slots
end

local equipMapper = {
  [Player.WeaponSlot] = "weapon",
  [Player.ArmorSlot] = "armor",
  [Player.OffensiveRideSlot] = "offensive_horse",
  [Player.DefensiveRideSlot] = "defensive_horse",
  [Player.TreasureSlot] = "treasure",
}

keji:addEffect("active", {
  card_num = 1,
  target_num = 0,
  expand_pile = "$yi__keji",
  can_use = Util.FalseFunc,
  interaction = function(self, player)
    local choices = getEmptyEquipSlots(player)
    if #choices > 0 then
      return UI.ComboBox { choices = choices }
    end
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getPile("$yi__keji"), to_select)
  end,
})

keji:addEffect(fk.EventPhaseStart, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Play and player:hasSkill(keji.name) and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = player:getHandcardNum(),
      skill_name = keji.name,
      prompt = "#yi__keji-remove",
      cancelable = true,
    })
    if #cards > 0 then
      event:setCostData(self, { cards = cards })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:addToPile("$yi__keji", event:getCostData(self).cards, false, keji.name, player)
    local targets = table.filter(room.alive_players, function(p)
      return p ~= player and not p:isKongcheng()
    end)

    local tos = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#gongxin-ask",
      skill_name = "gongxin",
      cancelable = true
    })
    if #tos > 0 then
      local cards = tos[1]:getCardIds("h")
      local hearts = table.filter(cards, function (id)
        return Fk:getCardById(id).suit == Card.Heart
      end)
      local ids, choice = room:askToChooseCardsAndChoice(player, {
        cards = hearts,
        choices = {"gongxin_discard", "gongxin_put"},
        skill_name = "gongxin",
        prompt = "#gongxin-view::" .. tos[1].id,
        cancel_choices = {"Cancel"},
        min_num = 1,
        max_num = 1,
        all_cards = cards
      })
      if choice == "gongxin_discard" then
        room:throwCard(ids, "gongxin", tos[1], player)
      elseif choice == "gongxin_put" then
        room:moveCardTo(ids, Card.DrawPile, nil, fk.ReasonPut, "gongxin", nil, true)
      end
    end
  end,
})

keji:addEffect(fk.TurnEnd, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(keji.name) and #player:getPile("$yi__keji") > 0 
      and #getEmptyEquipSlots(player) > 0 and player == target
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = keji.name,
      prompt = "#yi__keji-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    while not player.dead and #player:getPile("$yi__keji") > 0 and #getEmptyEquipSlots(player) > 0 do
      local success, dat = room:askToUseActiveSkill(player, {
        skill_name = keji.name,
        prompt = "#yi__keji-put",
        cancelable = true,
        skip = true,
      })
      if not (success and dat and dat.cards and dat.cards[1] and dat.interaction) then
        break
      end
      if not table.contains(player:getPile("$yi__keji"), dat.cards[1]) or
          not table.contains(getEmptyEquipSlots(player), dat.interaction) then
        break
      end
      local equipName = equipMapper[dat.interaction]
      if not equipName then break end
      local card = Fk:cloneCard(equipName.."__keji")
      card:addSubcard(dat.cards[1])
      room:moveCards({
        ids = { dat.cards[1] },
        from = player,
        to = player,
        toArea = Card.PlayerEquip,
        moveReason = fk.ReasonPut,
        skillName = keji.name,
        proposer = player,
        virtualEquip = card,
        moveVisible = false,
        visiblePlayers = player,
        moveMark = { "yi__keji_hidden-inarea", { Card.PlayerEquip } },
      })
    end
  end,
})

keji:addEffect("visibility", {
  card_visible = function(self, player, card)
    local room = Fk:currentRoom()
    local owner = room:getCardOwner(card)
    if owner and room:getCardArea(card) == Card.PlayerEquip and card:getMark("yi__keji_hidden-inarea") ~= 0 then
      return player == owner
    end
  end,
  move_visible = function(self, player, info, move)
    local card = Fk:getCardById(info.cardId)
    if card:getMark("yi__keji_hidden-inarea") ~= 0 or
        (info.beforeCard and info.beforeCard:getMark("yi__keji_hidden-inarea") ~= 0) then
      if info.fromArea == Card.PlayerEquip then
        return player == move.from
      elseif move.toArea == Card.PlayerEquip then
        return player == move.to
      end
    end
    if move.toArea == Card.PlayerEquip and move.skillName == keji.name then
      local moveMark = move.moveMark
      if type(moveMark) == "table" and moveMark[1] == "yi__keji_hidden-inarea" then
        return player == move.to
      end
    end
  end,
})

return keji
