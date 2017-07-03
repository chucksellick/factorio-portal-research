# Asteroid Mining and Portal Research

Factorio mod by Doc
https://forums.factorio.com/viewtopic.php?f=93&t=49940&p=290043

This mod adds a number of late- and end-game technologies, unlocking amazing new items and locations and providing an entirely new post-rocket-launch game layer.

Scan the skies for resource-rich asteroids, then teleport up there and build your outpost. Maintain your orbital fleet 

Note: This is still a work in progress but has plenty of functional gameplay already. Recipes are unfortunately changing quite a bit between releases. The biggest problem is the GUI which is taking a lot of work!

Planned features include a variety of new satellite types to launch such as probes, spy satellites, research stations, a defense grid, and orbital mining lasers! New ways to transfer resources between your base and your asteroid outposts, such as orbital drops and a space shuttle network. More fun stuff to happen in space! And perhaps one day the ultimate crowning achievement, the Space Elevator.

## Guide

### Asteroid mining

Two key components are needed in order to mine asteroids. Firstly you will need to find asteroids: this is achieved by building Observatories or launching Space Telescopes which will keep scanning until they find asteroids. Space Telescopes can find much better asteroids. Then you will need to deliver a portal to the asteroid to establish a two-way portal link.

Light levels vary on asteroids so solar may or may not work depending on the asteroid. Either way you might want to start investing in Space Based Solar Power to supply power remotely via microwave link.

Resources can be returned to your base using a portal chest but watch out, portal usage consumes a *lot* of power.

### Orbital Network

Units that you launch will initially orbit your home base (Nauvis) but they can be sent to other locations that you've discovered to provide support there instead. Orbital units will take damage over time however and must be repaired by launching a Repair Station and keeping it stocked.

## 3rd party mod integrations

This list will be maintained whenever I am made aware of an integration. A huge thanks to any authors who create these, and of course to the original creators of the mods in question! Below the list is some information about the script interface to add new integrations.

### RSO (Resource Spawner Overhaul) https://mods.factorio.com/mods/orzelek/rso-modhttps://mods.factorio.com/mods/orzelek/rso-mod

Built-in support added v 3.3.10 by orzelek.

### Omnimatter https://mods.factorio.com/mods/EmperorZelos/omnimatter

Support by nucleargen:
https://mods.factorio.com/mods/nucleargen/portal-research-addon

## Script interface for mod authors

All script interfaces are in the "portal_research" namespace:

### Add a new ore

  remote.call("portal_research", "add_offworld_resource", "my-ore-name", weight, richness_multiplier)

Adds the resource "my-ore-name" to the allowable list to be found offworld. Think about realism if doing this. By default oil and coal are omitted because they're derived from organic matter so it wouldn't seem right to find them on an asteroid.

If the ore is already registered then its properties will be updated.

weight is an integer which weights the probability of this resource being found relative to others. It does not affect the total chance of finding a resource.

richness_multiplier is a float which affects the quantity of the resource found per tile. This will additionally by affected by game settings (when I implement this!) so don't feel you need to
adjust this yourself. If not sure, just use 1, for similar richness patches to iron/copper.

The default table of values is as follows:

  { name="iron-ore",  weight=120,  richness=1 },
  { name="copper-ore", weight=100, richness=1.2 },
  { name="stone", weight=200, richness=0.8 },
  { name="uranium-ore", weight=1, richness=0.05 }

### Remove an ore

  remote.call("portal_research", "remove_offworld_resource", "my-ore-name")

### Clear all ores

  remote.call("portal_research", "clear_offworld_resources")

## Credits

Special thanks to all other modders of Factorio for inspiration and examples but in particular:

### Supercheese - Satellite Uplink Station

https://forums.factorio.com/viewtopic.php?f=97&t=19883

  * Borrowed dish graphic

### MagmaMcFry - Factorissimo2

  * A lot of code examples
  