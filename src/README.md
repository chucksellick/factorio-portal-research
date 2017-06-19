# Portal Research (and Asteroid Mining)

Factorio mod by Doc
https://forums.factorio.com/viewtopic.php?f=93&t=49940&p=290043

This mod adds a number of powerful late- and end-game technologies, unlocking amazing new items that enable the following:

* Use portals to teleport yourself (and items) quickly around the base
* Scan the skies for asteroids containing vast amounts of resources
* Deploy portals remotely to asteroids so you can travel there to set up a mining outpost
* Power your asteroid outputs (and your suit) with space-based solar power
* ...And eventually much more!

Note: This is a very alpha release. The above features are all working but the GUI is pretty horrible and most graphics are just placeholders. There are also a lot of issues with balance and recipes that will take a lot of tweaking. I have plenty of ideas to develop and improve this mod but these things take time.

Some planned features are as follows:

* New combinators to send signals wirelessly, and read data from your orbital network
* Use cheap probes to gauge asteroid resources before sending the expensive lander
* Space telescopes to find juicier asteroids farther away, and perhaps other interstellar objects
* Orbital mining lasers!

## Script interface for mod authors

All script interfaces are in the "portal_research" namespace:

### Add a new ore

  remote.call("portal_research", "add_offworld_resource", "my-ore-name", weight, richness_multiplier)

Adds the resource "my-ore-name" to the allowable list to be found offworld. It's important to at least consider realism if doing this! By default oil and coal are omitted because they're derived from organic matter so it wouldn't seem right to find them on an asteroid.

weight is an integer which weights the probability of this resource being found relative to others. It does not affect the total chance of finding a resource.

richness_multiplier is a float which affects the quantity of the resource found per tile. This will additionally by affected by game settings (when I implement this!) so don't feel you need to
adjust this yourself. If not sure, just use 1, for similar richness patches to iron/copper.

The default table of values is as follows:

  { name="iron-ore",  weight=120,  richness=1 },
  { name="copper-ore", weight=100, richness=1.2 },
  { name="stone", weight=200, richness=0.8 },
  { name="uranium-ore", weight=1, richness=0.05 }
