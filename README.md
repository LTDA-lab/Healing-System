
fast_heal.gsc: displays an animation when healing.

fast_heal_hands_only.gsc: does not display an animation when healing (hands appear empty).

hud_health_display.gsc: displays the actual HP configured in your gametype files.

hud_health_display_max_HP_100.gsc: displays the maximum HP as 100.



T6 MP – HP HUD & Healing System

Two GSC scripts for Plutonium T6 Multiplayer that add a custom player HP HUD and a manual healing system.

Features
❤️ HP HUD

Displays the player's current health on the HUD:

HP: 100
HP: 75
HP: 50
HP: 25

The HP display changes color depending on the player's health:

Health	Color
51–100	White
26–50	Yellow
0–25	Red

The HP value is updated automatically while the player is alive.

The HUD is also cleaned up when the player dies or disconnects.

💉 Manual Healing

The healing system allows players to manually restore health by holding F.

When the player takes damage, a temporary prompt appears:

Press [F] to Heal

While holding F, the player temporarily switches to a healing-device animation and regenerates health.

Healing Features
Healing is only available when the player has taken damage.
Hold F to heal.
Health regenerates progressively.
The healing device is temporarily given to the player.
The player's previous weapon is restored after healing.
A minimum animation duration is enforced.
The player must release F before starting another heal.
Two consecutive quick heals trigger a cooldown.
Consecutive heals are tracked within a configurable time interval.
A 5-second cooldown is activated after the second consecutive heal.
The HUD displays the cooldown status:
Healing Cooldown (5s)

After the cooldown expires:

Healing Ready
Configuration

The main healing values can be easily modified in the healing script:

heal_rate = 15;
max_consecutive_uses = 2;
max_interval_ms = 3000;
cooldown_time = 5;
min_anim_time = 1.2;
heal_rate

Amount of health restored every 0.05 seconds.

heal_rate = 15;

Higher values make healing faster.

max_consecutive_uses

Number of quick consecutive heals allowed before the cooldown starts.

max_consecutive_uses = 2;
max_interval_ms

Maximum time between heals for them to count as consecutive.

max_interval_ms = 3000;

3000 = 3 seconds.

cooldown_time

Cooldown duration after reaching the consecutive-heal limit.

cooldown_time = 5;
min_anim_time

Minimum amount of time the healing animation remains active.

min_anim_time = 1.2;
HUD Position

Both HUD elements can be repositioned by changing their x and y values.

HP HUD:

player.hpText.x = -40;
player.hpText.y = 52;

Healing HUD:

self.heal_hud_text.x = -40;
self.heal_hud_text.y = 35;

The healing prompt is intentionally positioned above the HP display.

Installation

These scripts are intended for Plutonium T6 Multiplayer GSC scripting.

Add the scripts to your T6 GSC script setup and load them through your existing GSC configuration.

The scripts are designed to work independently, but they can also be used together.

Required
Plutonium T6 Multiplayer
GSC scripting enabled
_hud_util available in the T6 MP environment
Files
hp_hud.gsc
healing_system.gsc
hp_hud.gsc

Handles the player's HP display and HUD cleanup.

healing_system.gsc

Handles the healing mechanic, healing prompt, weapon animation, cooldown and healing state.

Customization

The scripts are intentionally kept simple so server owners can easily modify:

Healing speed
Maximum health
Cooldown duration
Number of consecutive heals
Healing interval
Animation duration
HUD position
HUD colors
HUD text



❤️ Recommended Gameplay: Higher HP + Manual Healing

For servers looking for a different gameplay experience, I also recommend combining this healing system with a higher maximum HP than the default 100 HP.

For example, using:

150 HP maximum
Manual healing with the F key
Progressive health regeneration while healing

The idea is to create longer and more dynamic engagements without changing the original BO2 weapons, maps, movement, or overall gameplay.

With the standard 100 HP, many gunfights can end very quickly. Increasing the maximum HP gives players more time to react, disengage, escape, pursue an opponent, or turn a fight around.

Combined with manual healing, this creates more opportunities for:

🏃 Longer chases and escapes
🔫 Extended gunfights
🔄 Re-engaging after taking damage
🩹 Recovering before returning to combat
🎯 More opportunities for tactical decisions during fights

This is inspired by the type of gameplay found in newer Call of Duty experiences, where players can have greater effective survivability and recover from damage before re-engaging.

However, this is not intended to turn BO2 into Warzone. The goal is simply to experiment with the idea of bringing a small part of that gameplay style into T6 Multiplayer, while keeping the original BO2 weapons, maps and movement.

In my own testing, I found that the combination of higher HP + manual healing creates a noticeably different gameplay experience, especially because fights can develop into longer pursuits rather than ending immediately after the first exchange.

If you want to experiment with this concept, I recommend starting around 150 HP and adjusting the healing rate and cooldown according to your server's gameplay.




Feel free to modify the scripts to fit your server's gameplay.

Credits
Idea & concept: Me
Code: Me + AI assistance
AI assistance: ChatGPT
Platform: Plutonium T6 Multiplayer

The concept, gameplay mechanics, functionality and implementation were created by me, with AI assistance used during the development and refinement of the code.

If you use or modify these scripts, credit is appreciated.

Enjoy! ❤️
