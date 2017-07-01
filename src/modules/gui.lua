local inspect = require("lib.inspect")
local Gui = {}

local buttonDefs = {
  { name="portal-research", sprite = "item/medium-portal" },
  { name="emergency-home", sprite = "portal-research.site-type-home" }
}

local tabDefs = {
  { name="orbitals", sprite = "item/satellite" },
  { name="sites", sprite = "portal-research.site-type-very-large-asteroid" },
  { name="portals", sprite = "item/medium-portal" },
  { name="power", sprite = "item/microwave-antenna" },
}
local windowNames = { "primary-tab", "object-detail", "secondary-pane", "tertiary-pane", "hover-detail" }

function Gui.initForPlayer(player)

  -- XXX: Cleanup old buttons
  local button_flow = mod_gui.get_button_flow(player)
  if button_flow["portal-research-gui-button"] then
    button_flow["portal-research-gui-button"].destroy()
  end
  if button_flow["portal-research-emergency-home-button"] then
    button_flow["portal-research-emergency-home-button"].destroy()
  end
  -- XXX: End

  local playerData = getPlayerData(player)
  playerData.buttons = playerData.buttons or {}
  playerData.window_buttons = playerData.window_buttons or {}

  local flow = button_flow["portal-research-buttons"] or button_flow.add {
    type="flow",
    name="portal-research-buttons"
  }

  for i,buttonDef in pairs(buttonDefs) do
    local buttonName = buttonDef.name .. "-button"
    if playerData.buttons[buttonName] ~= nil and playerData.buttons[buttonName].button.valid then
      playerData.buttons[buttonName].button.destroy()
    end
    if button_flow[buttonName] ~= nil and button_flow[buttonName].valid then
      button_flow[buttonName].destroy()
    end
    buttonDef.button = button_flow.add {
      type = buttonDef.sprite and "sprite-button" or "button",
      name = buttonName,
      sprite = buttonDef.sprite,
      style = mod_gui.button_style,
      caption = buttonDef.sprite == nil and {"gui-portal-research." .. buttonDef.name .. "-button-caption"} or nil,
      tooltip = {"gui-portal-research." .. buttonName .. "-tooltip"}
    }
    playerData.buttons[buttonName] = buttonDef
  end

  -- TODO: Don't necessarily destroy every init - just refresh open windows
  local frame_flow = mod_gui.get_frame_flow(player)
  if frame_flow.portal_research_gui_flow then
    frame_flow.portal_research_gui_flow.destroy()
  end

  playerData.gui = frame_flow.add{type="flow", name="portal_research_gui_flow", direction="horizontal"}
  playerData.gui.add{name="tabs", type="frame", direction="vertical"}

  playerData.tabs = playerData.tabs or {}
  for i,tabDef in pairs(tabDefs) do
    local tab = playerData.gui.tabs.add {
      type = "sprite-button",
      name = tabDef.name .. "-tab",
      sprite = tabDef.sprite,
      style = mod_gui.button_style,
      tooltip = {"gui-portal-research." .. tabDef.name .. "-tab-tooltip"}
    }
    playerData.tabs[tab.name] = {
      name = tabDef.name,
      button = tab
    }
  end

  playerData.windows = {}
  for i,windowName in pairs(windowNames) do
    local window = {
      frame = playerData.gui.add{name=windowName, type="frame", direction="vertical"}
    }
    window.frame.style.visible = false
    window.scroll = window.frame.add{name="scroll", type="scroll-pane", direction="vertical"}
    window.scroll.horizontal_scroll_policy = "never"
    window.scroll.vertical_scroll_policy = "auto"
    -- TODO: Check height of game, set accordingly?
    window.scroll.style.maximal_height = 700
    window.scroll.style.bottom_padding = 9

    playerData.windows[windowName] = window
  end

  Gui.updateForPlayer(player)
end

local function createButton(player, gui_parent, options)
  local playerData = getPlayerData(player)
  local element = gui_parent.add{
    type = (options.sprite and "sprite-button" or "button"),
    name = options.name, -- TODO: Concatenate window name as well?
    caption = (not options.sprite and options.caption or nil)
  }

  -- TODO: Should display a warning if conflicting with an existing button id?
  playerData.window_buttons[options.name] = options
  options.element = element
end

local function cleanUpButtons(player)
  local playerData = getPlayerData(player)
  for i,button in pairs(playerData.window_buttons) do
    if not button.element.valid then
      playerData.window_buttons[i] = nil
    end
  end
  -- TODO: Cleanup could be specific to the window that's been closed/changed,
  -- however unless I see severe performance problems this is simple enough right now
end

local function getPlayerGui(playerData)
  if playerData.gui == nil or not playerData.gui.valid then
    Gui.initForPlayer(playerData.player)
  end

  return playerData.gui
end

local function openWindow(player, options)
  -- TODO: Clean up existing frame data
  local playerData = getPlayerData(player)
  local window = playerData.windows[options.window]
  if window == nil then player.print("Unknown window: " .. options.window) end

  window.frame.style.visible = true
  window.frame.caption = options.caption
  window.scroll.clear()

  -- Make sure Gui is visible
  local playerGui = getPlayerGui(playerData)
  playerGui.style.visible = true

  return window.scroll
end

local function closeWindow(player, options)
  local playerData = getPlayerData(player)
  local playerGui = getPlayerGui(playerData)
  local frame = playerGui[options.window]
  frame.style.visible = false
  cleanUpButtons(player)
  -- TODO: Actually delete gui, cancel ticks
  -- TODO: Also nilify playerData.current_tab if window was primary-tab
end

local function closeWindows(player)
  for i,windowName in pairs(windowNames) do
    closeWindow(player, {window=windowName})
  end
end

local function buildNameEditor(player, gui, object, window_options)
end

-- TODO: Is there any built-in method for this?
local function formatResourceAmount(amount)
  local round = Util.round(amount/1000000, 1)
  return round .. "M"
end

local function spriteNameForSite(site)
  local sprite = "unknown"
  if site.is_offworld then
    local size = Sites.getSize(site.size)
    sprite = size.name .. "-asteroid" -- TODO: Comets
  end
  if site.surface and site.surface.name == "nauvis" then
    sprite = "home"
  end
  if sprite == "unknown" then
    game.print("Unknown site type")
    game.print(inspect(site))
    return nil
  end
  return "portal-research.site-type-" .. sprite
end

local function siteMiniDetails(player, site, parent)
  local flow = parent.add{type="flow", direction="vertical"}
  local line1 = flow.add{type="flow", direction="horizontal"}
  local line2 = flow.add{type="flow", direction="horizontal"}
  local line3 = flow.add{type="flow", direction="horizontal"}

  local spriteName = spriteNameForSite(site)
  if spriteName~=nil then
    line1.add{type="sprite",sprite=spriteName,tooltip={spriteName}}
  end
  line1.add{type="label",caption=site.custom_name or site.name}
  if site.resources then
    local tooltip = "portal-research.resource-quantity" .. (site.resources_estimated and "-estimated" or "")
    for i,resource in pairs(site.resources) do
      -- TODO: Display friendly numbers on button
      line2.add{
        type="sprite",
        sprite="entity/" .. resource.resource.name,
        tooltip={tooltip, {"entity-name." .. resource.resource.name}, formatResourceAmount(resource.amount)}
      }
    end
  end
end

function Gui.showHoverDetail(player, data)
  if data.entity.name == "medium-portal"
    or data.entity.name == "portal-chest" then
    Gui.showPortalDetails(player, data, {window="hover-detail", open_target_select=false})
  end
end

function Gui.showSiteDetails(playerData, site, gui, window_options)
  local detailsTable = gui.add{type="table", colspan="2"}
  local function addDetailRow(label, value)
    --local detailRow = detailsTable.add{type="flow", direction="horizontal"}
    detailsTable.add{type="label", caption={"site-details-label-"..label}}
    detailsTable.add{type="label", caption=value}
  end

  addDetailRow("name", site.name)
  addDetailRow("size", {"site-size-" .. Sites.getSize(site.size).name})
  addDetailRow("distance", site.distance)

  gui.add{type="label", caption={"estimated-resources-label"}}

  local resourceTable = gui.add{type="table", colspan="2"}
  local count = 0
  for i,estimate in pairs(site.resources) do
    count = count+1
    resourceTable.add{type="sprite", sprite="entity/"..estimate.resource.name, tooltip={"entity-name."..estimate.resource.name}}
    resourceTable.add{type="label", caption=formatResourceAmount(estimate.amount)}
  end
  if count == 0 then
    gui.add{type="label", caption={"estimated-resources-none"}}
  end

  if site.is_offworld then
    if site.surface_generated then
      local preview_size = 200
      -- TODO: Add a function to build a "standard" camera widget with map toggle and zoom support
      local camera = gui.add{
        type="camera",
        position={x=0,y=0},
        surface_index = site.surface.index,
        zoom = 0.15
      }
      camera.style.minimal_width = preview_size
      camera.style.minimal_height = preview_size
    else
      gui.add{type="label", caption={"portal-research.site-not-yet-explored"}}
    end
  end

  gui.add{type="button", name="close-site-details-button",
          caption={"close-dialog-caption"}}
end

local function buildSitesList(player, list, root, options)
  local options = options or {}
  for site in list do
    local row = root.add{type="flow",direction="horizontal"}
    siteMiniDetails(player, site, row)
    -- Add buttons for 
    local name_base = "-" .. site.name .. "-button"
    --createButton(player, row, {name="site-details" .. name_base,caption="view-button-caption",action={name="site-details",site=site}, windowTarget)

    -- TODO: sprite buttons instead of captions
    createButton(player, row, {
      name="view-site-details-" .. site.name,
      caption={"portal-research.site-details-button-caption"},
      action={name="site-details",site=site,window="tertiary-pane"},
      window="secondary-pane"
    })
    if options.extra_buttons then
      for i,button in pairs(options.extra_buttons) do
        createButton(player, row, button(site))
      end
    end
  end
end

-- TODO: Move this stuff out to Orbitals
local function commonOrbitalDetails(playerData, orbital, gui, window_options)
  gui.add{type="sprite", sprite="item/" .. orbital.name}
  gui.add{type="label", caption={"portal-research.orbital-location-caption"}}  
  if orbital.in_transit then
    gui.add{type="label", caption={"portal-research.orbital-transitting-caption"}}
    siteMiniDetails(playerData.player, orbital.transit_destination, gui)
    -- TODO: Assumptions here and elsewhere that speed is constant (for now it is).
    local time_to_arrival = (orbital.transit_complete_tick.tick - game.tick)/60
    gui.add{type="label", caption={"portal-research.orbital-eta-caption", Util.round(time_to_arrival, 1), Util.round(orbital.transit_distance,1)}}
    gui.add{type="progressbar", size=200, value = (game.tick - orbital.started_transit_at)/(orbital.transit_complete_tick.tick - orbital.started_transit_at)}
  else
    siteMiniDetails(playerData.player, orbital.site, gui)
    -- TODO: Add a function to build a "standard" camera widget with map toggle^B^B^B^B and zoom support
    if orbital.site.is_offworld and orbital.site.surface_generated then
      local preview_size = 200
      local camera = gui.add{
        type="camera",
        position={x=0,y=0},
        surface_index = orbital.site.surface.index,
        zoom = 0.15
      }
      camera.style.minimal_width = preview_size
      camera.style.minimal_height = preview_size
    end
  end
  createButton(playerData.player, gui, {
    name = "change-orbital-destination-" .. orbital.id,
    caption={"portal-research.change-destination-caption"},
    action={name="change-orbital-destination",orbital=orbital,window="secondary-pane"},
    window="object-detail"
  })
    -- TODO: Tick to update every second
end

local function buildOrbitalsList(player, list, root, options)
  local options = options or {}
  local playerData = getPlayerData(player)
  for orbital in list do
    local row = root.add{type="flow",direction="horizontal"}
    local name_base = "-orbital-" .. orbital.id .. "-button"

    row.add{type="label", caption={"item-name." .. orbital.name}}
    row.add{type="sprite", sprite="item/" .. orbital.name}
    if orbital.site then
      siteMiniDetails(player, orbital.site, row)
    end

    createButton(player, row, {
      name="view-orbital-details-" .. orbital.id,
      caption={"portal-research.portal-details-button-caption"},
      action={name="orbital-details",orbital=orbital},
      window=options.window
    })
    if orbital.in_transit then
      row = root.add{type="flow",direction="horizontal"}
      siteMiniDetails(player, orbital.transit_destination, row)
      row.add{type="progressbar", size=200, value = (game.tick - orbital.started_transit_at)/(orbital.transit_complete_tick.tick - orbital.started_transit_at)}
    end
  end
    -- TODO: Tick to update every second
end

local function buildTab(player, tab_name)
  local options = {
    window="primary-tab",
    caption={"gui-portal-research."..tab_name.."-tab-caption"}
  }
  local gui = openWindow(player, options)
  if tab_name == "sites" then
    buildSitesList(player, Sites.list(player.force), gui, options)
  elseif tab_name == "orbitals" then
    buildOrbitalsList(player, Orbitals.list(player.force), gui, options)
  elseif tab_name == "portals" then
    --buildPortalsList(player, Portals.list(player.force), gui)
  elseif tab_name == "power" then
    --buildPowerList(player, Portals.list(player.force), gui)
  end
end

local function pickPortalTargets(player, portal)
  local window_options = {
    window="secondary-pane",
    caption={"gui-portal-research.portal-target-select-caption." .. portal.entity.name},
    object=portal
  }
  local gui = openWindow(player, window_options)
  local playerData = getPlayerData(player)

  -- List sites that don't yet have a portal
  local allowLongRange = player.force.technologies["interplanetary-teleportation"]
    and player.force.technologies["interplanetary-teleportation"].researched

  -- TODO: However, for box portals do check they're close enough on the surface until interplanetary is unlocked
  -- TODO: Maybe shorter distances initially, go to 50 on long-range, go to infinite on interplanetary
  -- List actual portals (of the same type and within range) that don't have a target
  for i,target in pairs(global.portals) do -- TODO: Portals.list()
    if portal.entity.name == target.entity.name
      and target.entity.force == player.force and portal ~= target
      and target.teleport_target == nil -- TODO: Remove this check soon
      -- Note: It seems like long range shouldn't happen before lander is created,
      -- however we're also checking for different surfaces e.g. those created by Factorissimo
      and (allowLongRange or target.entity.surface == portal.entity.surface) then

      -- TODO: Some of this is repeated in buildSitesList but it's a bit different

      local row = gui.add{
        type="flow",
        direction="horizontal"
      }
      --portalMiniDetails
      siteMiniDetails(player, target.site, row)
      createButton(player, row, {
        name="view-portal-details-" .. target.id,
        caption={"portal-research.portal-details-button-caption"},
        action={name="portal-details",portal=target,open_target_select=false,window="tertiary-pane"},
        window="secondary-pane"
      })
      createButton(player, row, {
        name="portal-" .. portal.id .. "-pick-target-portal-" .. target.id,
        caption={"portal-research.pick-portal-button-caption"},
        action={name="pick-portal-target",portal=portal,target_portal=target},
        window="secondary-pane"
      })
    end
  end
  -- TODO: X close buttons
end

-- TODO: Too much of this is in Gui rather than Portals
-- TODO: Close GUI when running away from portal.
function Gui.showPortalDetails(player, portal, options)
  -- TODO: Show energy also
  -- TODO: Check this doesn't get executed too much when walking through a portal
  local window_options = options or {}
  window_options.window = window_options.window or "object-detail"
  window_options.caption = window_options.caption or {"portal-research.portal-details-caption"}
  window_options.object = portal

  local gui = openWindow(player, window_options)

  local playerData = getPlayerData(player)
  -- TODO: Handle this in the openWindow stuff?
  playerData.current_detail_object = portal

  buildNameEditor(player, gui, window_options)

  local preview_size = 200
  -- TODO: Add a function to build a "standard" camera widget with map toggle and zoom support
  local camera = gui.add{
    type="camera",
    position=portal.entity.position,
    surface_index = portal.entity.surface.index,
    zoom = 0.15
  }
  camera.style.minimal_width = preview_size
  camera.style.minimal_height = preview_size

  if portal.entity.name == "portal-chest" then
    if portal.is_sender then
      gui.add{type="label", caption={"portal-research.portal-chest-sending-heading"}}
    else
      gui.add{type="label", caption={"portal-research.portal-chest-receiving-heading"}}
    end
  else
    gui.add{type="label", caption={"portal-research.portal-target-heading"}}
  end

  if portal.teleport_target then
    local site = Sites.getSiteForEntity(portal.teleport_target.entity)
    gui.add{type="label", caption=site.name}
    local target_camera = gui.add{
      type="camera",
      position=portal.teleport_target.entity.position,
      surface_index = portal.teleport_target.entity.surface.index,
      zoom = 0.15
    }
    target_camera.style.minimal_width = preview_size
    target_camera.style.minimal_height = preview_size
  else
    gui.add{type="label", caption={"portal-research.no-target-portal"}}
    if window_options.open_target_select ~= false then
      pickPortalTargets(player, portal)
    end
  end
end

local function pickOrbitalDestination(player, orbital, options)
  local window_options = {
    window="secondary-pane",
    caption={"gui-portal-research.orbital-destination-select-caption." .. orbital.name},
    object=orbital
  }
  local gui = openWindow(player, window_options)
  local playerData = getPlayerData(player)

  local predicate = function(site)
    -- Landers must go to a site without a portal; everything else can go to asteroids
    -- or nauvis. TODO: Maybe miners should only go to asteroids?
    return (orbital.name == "portal-lander" and site.is_offworld
      and not site.surface_generated and not site.has_portal) 
      or (orbital.name ~= "portal-lander" and (site.is_offworld or site.name=="nauvis"))
  end

  -- TODO: The buttons system is pretty horrible, could be improved
  buildSitesList(player, Sites.list(player.force, predicate), gui, {
    extra_buttons = {
      function(site)
        return {
          name="orbital-" .. orbital.id .. "-pick-destination-" .. site.name,
          caption={"portal-research.pick-destination-button-caption"},
          action={name="pick-orbital-destination",orbital=orbital,destination=site},
          window="secondary-pane"
        }
      end
    }
  })
end

function Gui.showObjectDetails(player, object, options)
  local playerData = getPlayerData(player)
  local window_options = options or {}
  window_options.window = window_options.window or "object-detail"
  window_options.object = object

  if window_options.caption == nil then
    if object.is_offworld then
      window_options.caption = {"site-details-caption", object.name}
    elseif object.is_orbital then
      window_options.caption = {"orbital-details-caption", {"item-name." .. object.name}}
    end
  end

  local gui = openWindow(player, window_options)

  if object.is_offworld then
    Gui.showSiteDetails(playerData, object, gui, window_options)
  elseif object.is_orbital then
    commonOrbitalDetails(playerData, object, gui, window_options)
    if object.name == "portal-lander" then
      if not object.transit_destination then
        pickOrbitalDestination(player, object)
      end
      -- TODO: Maybe don't deploy automatically on arrival; show button to do so
    elseif object.name == "solar-harvester" then
      -- TODO: Show power / target
    end
  end
end

-- TODO: Actually break this in two? Deciding generally which buttons are available to a player is a bit
-- different 
function Gui.updateForPlayer(player, options)
  options = options or {}
  -- TODO: Only show buttons as appropriate for player entities / tech level
  local playerData = getPlayerData(player)

  -- Emergency home button needs to show whenever not on Nauvis (at least by teleportation). Some of these surfaces
  -- could be from other mods (e.g. Factorissimo) and since we have no idea how these are created
  -- and interlinked there are all kinds of ways players could make broken situations and not be able to get home!
  playerData.buttons["emergency-home-button"].button.style.visible = (player.surface.name ~= "nauvis")

  -- Update the tab only if the player has it open
  if options.tab and playerData.current_tab and playerData.current_tab.name == options.tab then
    buildTab(player, options.tab)
  end

  if options.object then
    if options.show then
      Gui.showObjectDetails(player, options.object)
    end
  end
end

function Gui.update(options)
  if options.force then
    for i,player in pairs(options.force.connected_players) do
      Gui.updateForPlayer(player, options)
    end
  elseif options.player then
    Gui.updateForPlayer(options.player, options)
  else
    -- Otherwise global update! (Careful)
    for i,player in pairs(game.players) do
      Gui.updateForPlayer(player, options)
    end
  end
end

function Gui.messagePlayer(player, options)
  -- TODO: Use a special frame for this and display a notification so player can review messages and jump to object details
  -- TODO: Options.target is a target entity that can be viewed in a camera if off-surface
  player.print(options.message)
end
function Gui.message(options)
  if options.force then
    for i,player in pairs(options.force.connected_players) do
      Gui.messagePlayer(player, options)
    end
  elseif options.player then
    Gui.messagePlayer(options.player)
  else
    -- Otherwise global update! (Careful)
    for i,player in pairs(game.players) do
      Gui.messagePlayer(player, options)
    end
  end
end

function Gui.tick(event)
  for i,player in pairs(game.players) do
    -- TODO: More optimal to just loop through playerData instead?
    local playerData = getPlayerData(player)
    if playerData.hovered_object ~= nil and player.selected ~= playerData.hovered_object then
      closeWindow(player, {window="hover-detail"})
    end
    if player.selected and player.selected ~= playerData.hovered_object then
      local data = getEntityData(player.selected)
      if data ~= nil then
        Gui.showHoverDetail(player, data)
      end
    end
    playerData.hovered_object = player.selected
  end
end

local function onGuiClick(event)
  local player = game.players[event.player_index]
  local playerData = getPlayerData(player)
  local playerGui = getPlayerGui(playerData)
  local name = event.element.name
  if name == "portal-research-button" then
    playerGui.style.visible = not playerGui.style.visible
    return
  end
  if name == "emergency-home-button" then
    Portals.emergencyHomeTeleport(player)
    return
  end

  if playerData.tabs[name] and playerData.tabs[name].button == event.element then
    local clicked_tab = playerData.tabs[name]
    closeWindows(player)
    if playerData.current_tab == clicked_tab then
      playerData.current_tab = nil
    else
      buildTab(player, clicked_tab.name)
      playerData.current_tab = clicked_tab
    end
    return
  end
  
  if playerData.window_buttons[name] then
    local button = playerData.window_buttons[name]
    -- TODO: Action handlers definitely need moving out of this
    -- function before it gets out of control
    if button.action.name == "site-details" then
      Gui.showObjectDetails(player, button.action.site, button.action)
    elseif button.action.name == "orbital-details" then
      Gui.showObjectDetails(player, button.action.orbital, button.action)
    elseif button.action.name == "change-orbital-destination" then
      pickOrbitalDestination(player, button.action.orbital, button.action)
    elseif button.action.name == "portal-details" then
      Gui.showPortalDetails(player, button.action.portal, button.action)
    elseif button.action.name == "pick-portal-target" then
      local chosen = button.action.target_portal
      button.action.portal.teleport_target = chosen
      chosen.teleport_target = button.action.portal

      -- TODO: Allow this to be toggled in GUI (and even using circuits?) and leave GUI open...
      -- TODO: Allow naming things (soon). Open portal GUI on mouse hover.
      -- TODO: (Much later) GUI can show connections diagrammatically
      if chosen.entity.name == "portal-chest" then
        chosen.is_sender = false
        chosen.teleport_target.is_sender = true
      end

      -- Buffer size will need to change
      Portals.updateEnergyProperties(chosen)
      Portals.updateEnergyProperties(chosen.teleport_target)
      -- TODO: Window should be closed automagically by the below call to showPortalDetails
      -- but this doesn't work yet
      closeWindow(player, {window=button.window})
      -- Refresh portal details
      Gui.showPortalDetails(player, button.action.portal)
      -- TODO: If other players had GUI open for the same portal, should update all their views
      -- Need better tracking of what models are shown in the windows and what their original render
      -- path was
    elseif button.action.name == "pick-orbital-destination" then
      -- Close the triggering window first; could open a new window as a result
      closeWindow(player, {window=button.window})
      -- Start orbital moving to selected site
      Orbitals.sendOrbitalToSite(button.action.orbital, button.action.destination)
    end
  end
end

script.on_event(defines.events.on_gui_click, onGuiClick)

return Gui