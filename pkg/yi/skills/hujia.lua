local hujia = fk.CreateSkill {
  name = "yi__hujia",
  derived_piles = "$yi__hujia",
}

Fk:loadTranslationTable{
  ["yi__hujia"] = "护驾",
  [":yi__hujia"] = "每回合各限一次，当你距离一以内的{群}或魏势力角色成为牌的目标时，你可与其各摸一张牌/令一名魏势力的非目标角色代替其成为此牌目标；"..
  "每轮开始时，你可更改{}中的势力。",
  ["#yi__hujia-choice"] = "护驾：你可为%dest选择一项",
  ["#yi__hujia-transfer"] = "护驾：选择一名魏势力角色代替%dest成为%arg的目标",
  ["yi__hujia_draw"] = "与其各摸一张牌",
  ["yi__hujia_transfer"] = "转移目标",
  ["@@yi__hujia-turn"] = "护驾",
  ["@yi__hujia_kingdom"] = "",
  ["#yi__hujia-choice2"] = "护驾：你可更改{}中的势力",

  ["$yi__hujia1"] = "虎贲三千，堪当敌万余！",
  ["$yi__hujia2"] = "壮士八百，足护卫吾身！",
}

hujia:addEffect(fk.TargetConfirming, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if data.cancelled or not player:hasSkill(hujia.name) or player:distanceTo(target) > 1 
      or (target.kingdom ~= player:getMark("@yi__hujia_kingdom")[1] and target.kingdom ~= "wei") or target == data.from then
      return false
    end
    return player:getMark("yi__hujia_draw-turn") == 0 or (player:getMark("yi__hujia_transfer-turn") == 0 
      and table.find(data:getExtraTargets({ bypass_distances = true }), function (p)
        return p.kingdom == "wei"
      end))
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local choices = {}
    local all_choices = {
      "yi__hujia_draw",
      "yi__hujia_transfer",
    }
    if player:getMark("yi__hujia_draw-turn") == 0 then
      table.insert(choices, "yi__hujia_draw")
    end
    local transfer_targets = table.filter(data:getExtraTargets({ bypass_times = true }), function(p)
      return p.kingdom == "wei"
    end)
    if player:getMark("yi__hujia_transfer-turn") == 0 and #transfer_targets > 0 then
      table.insert(choices, "yi__hujia_transfer")
    end

    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = hujia.name,
      prompt = "#yi__hujia-choice::" .. target.id,
      all_choices = all_choices,
      cancelable = true,
    })

    if choice == "yi__hujia_transfer" then
      local tos = room:askToChoosePlayers(player, {
        targets = transfer_targets,
        min_num = 1,
        max_num = 1,
        prompt = "#yi__hujia-transfer::" .. target.id .. ":" .. data.card:toLogString(),
        skill_name = hujia.name,
        cancelable = true,
        no_indicate = true,
      })
      if #tos == 0 then return false end

      event:setCostData(self, { tos = tos, choice = "transfer" })
      return true
    elseif choice == "yi__hujia_draw" then
      event:setCostData(self, {choice = "draw" })
      return true
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cost_data = event:getCostData(self)
    local choice = cost_data.choice
    room:setPlayerMark(target, "@@yi__hujia-turn", 1)

    if choice == "draw" then
      room:setPlayerMark(player, "yi__hujia_draw-turn", 1)
      player:drawCards(1, hujia.name)
      target:drawCards(1, hujia.name)
    elseif choice == "transfer" then
      local to = cost_data.tos[1]
      room:setPlayerMark(player, "yi__hujia_transfer-turn", 1)
      room:setPlayerMark(to, "@@yi__hujia-turn", 1)
      data:cancelTarget(target)
      data:addTarget(to)
    end
  end,
})

hujia:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(hujia.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@yi__hujia_kingdom", {"qun"})
  end,
})

hujia:addEffect(fk.RoundStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(hujia.name)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local kingdoms = {"wei", "qun", "shu", "wu"}
    local choice = room:askToChoice(player, {
      choices = kingdoms,
      skill_name = hujia.name,
      prompt = "#yi__hujia-choice2",
    })
    event:setCostData(self, {choice = choice})
    return choice ~= "Cancel"
  end,
  on_use = function(self, event, target, player, data)
    local choice = event:getCostData(self).choice
    player.room:setPlayerMark(player, "@yi__hujia_kingdom", {choice})
  end,
})

return hujia
