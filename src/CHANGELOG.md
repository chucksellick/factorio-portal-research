# Portal Research Changelog

### 0.7.3

  * Orbitals now take damage over time and eventually die
  * Fixed a silly init bug
  * Fixed an occasional lockup due to tick handling

### 0.7.2

  * Added entity: Orbital Logistics Combinator
  * Added entity: Radio Mast
  * Implemented Ticks system for periodic entity actions with reduced UPS load
  * Tidied up GUI quite a bit
  * Orbitals now take time to move to their destination and their progress can be seen in GUI
  * Lots of recipe changes (particularly satellites) for both realism and balancing.
    Updating users will unfortunately need to check their machines are still working.
  * Visible beams for microwave transmitters/receivers
  * Made all techs use even ratio of science packs, in line with 0.15.27

### 0.6.7

  * Fixed launching solar and telescopes

### 0.6.6

  * Revert plastic forming plant to electric energy

### 0.6.5

  * Fixed launching portals

### 0.6.4

  * Include *.md files in build (README.md, CHANGELOG.md)
  * Add script interfaces to remove/alter resources

### 0.6.3

  * Fix completely broken plastic plant recipe

### 0.6.2

  * Broken build with no files

### 0.6.1

  * Fixed portal landers not removing themselves once landed
  * Update orbitals tab list when any unit is added or removed

### 0.6.0

  * New orbital: Space Telescope, can spot asteroids much further away with much better resources
  * PCUs now use medium crystals to make science pack easier
  * Separate plexiglass sheet production from lenses
  * New assembler: Plastic Forming Plant to make plastic objects out of plexiglass
  * Add a plexiglass vacuum tube recipe
  * Added radio transmitter/receiver recipes (currently non-functional, used as an intermediate)
  * Update recipes for portal lander and solar harvester
  * Modify recipe of base satellite to align with new units
  * Added unique icons for most items
  * Added some missing descriptions
  * Added technologies: Radio Communication, Advanced Plastics
  * Give increasing space science rewards for all the new satellite types
  * Fixed crash when removing Microwave equipment from player grid
  * Reduce portal chest inventory to 1 stack
  * Added README.md and CHANGELOG.md

### 0.5.5

  * Fixed a GUI error sometimes triggered on reload

### 0.5.4

  * Fixed observatories not processing scan results. If updating you will need to deconstruct then rebuild all your observatories for them to start working. Scan results can be manually placed back into the output slots on the machines for them to be processed and discover sites.

### 0.5.3

  * Fix another init error

### 0.5.2

  * Fixed a couple of reported issues with initialisation (u/, u/)
  * Made the portal control unit recipe easier since a ton are required for research
  * Removed some left-over dev fluff
  * Added a script interface for mod authors to enable additional ores on asteroids

### 0.5.1

  * First release