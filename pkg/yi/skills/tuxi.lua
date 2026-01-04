local tuxi = fk.CreateSkill {
  name = "yi__tuxi",
}

Fk:loadTranslationTable{
  ["yi__tuxi"] = "突袭",
  [":yi__tuxi"] = "准备阶段，你可分配{}中的数值（总和不超过6）并观看{}名角色各{}张手牌，将其中至多{}张置于牌堆两侧。",
	["#yi__tuxi-choose"] = "突袭：请选择任意名角色，总数剩余 %arg",
	["yi__tuxi-view"] = "突袭：选择观看这些角色任意张牌，总数剩余 %arg",
	["#tuxi-prey"] = "突袭：你可选择其中至多 %arg 张牌置于牌堆两侧",

	["$yi__tuxi1"] = "快马突袭，占尽先机！",
  ["$yi__tuxi2"] = "马似飞影，枪如霹雳！",
}

Fk:addPoxiMethod{
  name = "tuxi_prey0",
  prompt = "#tuxi-prey:::" .. 0,
  card_filter = function (to_select, selected, data, extra_data)
    return #selected < 0
  end,
  feasible = function(selected, data)
    return #selected <= 0
  end,
  default_choice = function (data, extra_data)
    return {}
  end,
}
Fk:addPoxiMethod{
  name = "tuxi_prey1",
  prompt = "#tuxi-prey:::" .. 1,
  card_filter = function (to_select, selected, data, extra_data)
    return #selected < 1
  end,
  feasible = function(selected, data)
    return #selected <= 1
  end,
  default_choice = function (data, extra_data)
    return {}
  end,
}
Fk:addPoxiMethod{
  name = "tuxi_prey2",
  prompt = "#tuxi-prey:::" .. 2,
  card_filter = function (to_select, selected, data, extra_data)
    return #selected < 2
  end,
  feasible = function(selected, data)
    return #selected <= 2
  end,
  default_choice = function (data, extra_data)
    return {}
  end,
}
Fk:addPoxiMethod{
  name = "tuxi_prey3",
  prompt = "#tuxi-prey:::" .. 3,
  card_filter = function (to_select, selected, data, extra_data)
    return #selected < 3
  end,
  feasible = function(selected, data)
    return #selected <= 3
  end,
  default_choice = function (data, extra_data)
    return {}
  end,
}
Fk:addPoxiMethod{
  name = "tuxi_prey4",
  prompt = "#tuxi-prey:::" .. 4,
  card_filter = function (to_select, selected, data, extra_data)
    return #selected < 4
  end,
  feasible = function(selected, data)
    return #selected <= 4
  end,
  default_choice = function (data, extra_data)
    return {}
  end,
}

tuxi:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tuxi.name) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
			targets = room:getOtherPlayers(player),
			min_num = 1,
			max_num = 6,
			prompt = "#yi__tuxi-choose:::" .. 6,
			skill_name = tuxi.name,
    })
		local toView = room:askToNumber(
			player,
			{
				min = 1,
				max = 6 - #tos,
				skill_name = tuxi.name,
				cancelable = true,
				prompt = "yi__tuxi-view:::" .. (6 - #tos),
			}
		)
		local toGain = 6 - #tos - toView
		local cards = {}
		local card_data = {}
		for _, p in ipairs(tos) do
			local handIds = p:getCardIds("h")
			-- randomly select toView cards from each target
			if toView > 0 then
				local viewIds = table.random(handIds, math.min(toView, #handIds))
				table.insertTable(cards, viewIds)
				table.insert(card_data, {p.general, viewIds})
			end
		end
		local tuxi_cards = room:askToPoxi(player, {
      poxi_type = "tuxi_prey" .. toGain,
      data = card_data,
      cancelable = false,
    })
    if #tuxi_cards > 0 then
      local result = room:askToGuanxing(player, {
        cards = tuxi_cards,
        skill_name = tuxi.name,
        skip = true,
      })
      local top, bottom = result.top, result.bottom
      room:moveCards({
        ids = top,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonJustMove,
        skillName = tuxi.name,
        proposer = player,
        drawPilePosition = 1,
      })
      room:moveCards({
        ids = bottom,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonJustMove,
        skillName = tuxi.name,
        proposer = player,
        drawPilePosition = -1,
      })
		end
  end,
})


return tuxi