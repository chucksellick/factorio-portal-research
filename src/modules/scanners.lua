local Scanners = {}

function Scanners.setupWorkerEntity(scanner)
  -- The only scanner that needs a worker entity currently is the orbital space telescope
  -- TODO: Setting the force makes debug easier otherwise we can't access the GUI. The consequence is this will show up under production.
  -- Need to decide what is wanted.
  scanner.entity = Sites.addHiddenWorkerEntity(scanner, { name = "space-telescope-worker", force = scanner.force })
end

function Scanners.destroyWorkerEntity(scanner)
  Sites.removeHiddenWorkerEntity(scanner)
end

local scanner_types = {}
scanner_types["observatory"] = { max_size = 3, base_distance = 1, scan_chance = 0.01 }
scanner_types["space-telescope-worker"] = { max_size = 5, base_distance = 10, scan_chance = 0.05 }

-- TODO: Fix UPS
-- TODO: For orbital scanners, stop scanning (deactive entity) whilst in transit
function Scanners.scan(event)
  for i,scanner in pairs(global.scanners) do
    local result = scanner.entity.get_inventory(defines.inventory.assembling_machine_output)
    if result[1].valid_for_read and result[1].count > 0 then
      local scan_spec = scanner_types[scanner.entity.name]
      for n = 1, result[1].count do
        -- TODO: Can improve with research etc
        if math.random() < scan_spec.scan_chance then
          -- TODO: Set more parameters of site
          local newSite = Sites.generateRandom(scanner.entity.force, scanner, scan_spec)
          scanner.entity.force.print({"site-discovered", {"entity-name."..scanner.entity.name}, newSite.name})
          -- TODO: Show site details only if no window open
          -- TODO: Use a notifications queue for events like this
          -- TODO: Show "last find" in orbital + observatory details
          --for i,player in pairs(scanner.entity.force.connected_players) do
          --  Gui.showSiteDetails(player, newSite)
          --end
        else
          -- TODO: Some chance for other finds eventually. e.g. incoming solar storms / meteorites,
          -- mysterious objects from ancient civilisations, space debris, pods (send probes to intercept)
          -- TODO: This message will get really annoying with a whole bunch of scanners. Instead, the first time
          -- this happens, display a tutorial message saying "Your scanner found nothing this time, keep trying yada yada" (once for each player)
          --scanner.entity.force.print({"scan-found-nothing", {"entity-name."..scanner.entity.name}})
        end
      end
      result[1].clear()
    end
  end
  -- TODO: Could additionally require inserting the "scan result" into some kind of navigational computer ("Space Command Mainframe?"). Might seem like busywork. Space telescopes
  -- would download their results to some kind of printer? Requires some medium to store the result? (circuits) ... not sure about this. But could
  -- be cool to require *some* sort of ground-based structures that actually coordinate and track all the orbital activity and even portals, and requiring more computers the
  -- more stuff you have in the air. Mainframes should have a neighbour bonus like nuke plants due to parallel processing, and require use of heat pipes and coolant to keep within
  -- operational temperature. Going too hot e.g. 200C causes a shutdown and a long reboot process only once temperature comes back under 100C.
  -- Mainframes could also interact with observatories to track things better, and/or make orbitals generally work quicker, avoid damage, etc etc.
  -- (Note: mainframe buildable without space science, need them around from the start ... even before the first satellite ... should also make satellites do things! (Map reveal?))
end

return Scanners