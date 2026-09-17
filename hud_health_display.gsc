init()
{
    level.hpDisplayThread = thread displayHPPercentageHUD();
    thread cleanupUnusedHUDs();
}

displayHPPercentageHUD()
{
    for(;;)
    {
        players = getEntArray("player", "classname");

        for(i = 0; i < players.size; i++)
        {
            player = players[i];

            // Crear HUD si no existe
            if (!isDefined(player.hpText))
            {
                player.hpText = newClientHudElem(player);
                player.hpText.hideWhenInMenu = true;
                player.hpText.alignX = "left";
                player.hpText.alignY = "middle";
                player.hpText.horzAlign = "left";
                player.hpText.vertAlign = "middle";
                player.hpText.foreground = true;
                player.hpText.fontScale = 1;
                player.hpText.alpha = 1;
                player.hpText.x = -40;
                player.hpText.y = 52;

                // Vincular evento de muerte para borrar HUD
                player notifyOnPlayerCommand("death", "death");
                player thread onPlayerDeath();
            }

            // Obtener vida real
            health = player.health;

            if (!isDefined(health))
                continue;

            roundedHP = int((health + 5) / 10) * 10;

            // Ya NO se limita a 100

            if (roundedHP < 0)
                roundedHP = 0;

            if (roundedHP > 50)
                color = (1, 1, 1);
            else if (roundedHP > 25)
                color = (1, 1, 0);
            else
                color = (1, 0, 0);

            player.hpText.color = color;

            if (roundedHP < 10)
                displayHP = "0" + roundedHP;
            else
                displayHP = "" + roundedHP;

            if (roundedHP <= 25)
                colorCode = "^1";
            else if (roundedHP <= 50)
                colorCode = "^3";
            else
                colorCode = "^7";

            player.hpText setText(colorCode + "HP: " + displayHP);
        }

        wait 0.5;
    }
}

onPlayerDeath()
{
    self waittill("death");

    if (isDefined(self.hpText))
    {
        self.hpText destroy();
        self.hpText = undefined;
    }
}

onPlayerDisconnect()
{
    if (isDefined(self.hpText))
    {
        self.hpText destroy();
        self.hpText = undefined;
    }
}

cleanupUnusedHUDs()
{
    for (;;)
    {
        players = getEntArray("player", "classname");

        for (i = 0; i < players.size; i++)
        {
            player = players[i];

            if (isDefined(player.hpText) && !isAlive(player))
            {
                player.hpText destroy();
                player.hpText = undefined;
            }
        }

        wait 10;
    }
}
