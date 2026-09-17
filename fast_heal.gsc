#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;

init()
{
    precacheitem( "briefcase_bomb_mp" );
    level thread on_player_connect();
}

on_player_connect()
{
    for (;;)
    {
        level waittill( "connecting", player );
        player thread on_player_spawned();
    }
}

on_player_spawned()
{
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "spawned_player" );

        // Resetear todas las variables al reaparecer
        self.is_healing = false;
        self.heal_uses = 0;
        self.last_heal_time = 0;
        self.heal_cooldown = false;

        // Limpiar HUDs previos si existían
        if ( isdefined( self.heal_hud_text ) )
            self.heal_hud_text destroy();

        // Cancelar hilos previos y lanzar nuevos monitores
        self notify( "end_monitor_heal" );
        self thread monitor_heal();
        self thread monitor_damage_hud();
    }
}

monitor_damage_hud()
{
    self endon( "disconnect" );
    self endon( "death" );
    self endon( "end_monitor_heal" );

    for (;;)
    {
        self waittill( "damage" );

        // Si no está en cooldown, ni curándose, y necesita curación, mostrar aviso durante 1 segundo
        if ( (!isdefined( self.heal_cooldown ) || !self.heal_cooldown) && (!isdefined( self.is_healing ) || !self.is_healing) )
        {
            self thread show_temp_heal_prompt( "^1Press [F] to Heal", 1.0 );
        }
    }
}

show_temp_heal_prompt( text_msg, duration )
{
    self endon( "disconnect" );
    self endon( "death" );

    // Evitar superponer prompts
    self notify( "new_heal_prompt" );
    self endon( "new_heal_prompt" );

    if ( !isdefined( self.heal_hud_text ) )
    {
        self.heal_hud_text = self maps\mp\gametypes\_hud_util::createfontstring( "small", 1.0 );
        self.heal_hud_text.alignX = "left";
        self.heal_hud_text.alignY = "middle";
        self.heal_hud_text.horzAlign = "left";
        self.heal_hud_text.vertAlign = "middle";
        self.heal_hud_text.foreground = true;
        self.heal_hud_text.alpha = 1;
        self.heal_hud_text.x = -40;
        self.heal_hud_text.y = 35; // Ubicado arriba del HUD de HP que está en y = 52
    }

    self.heal_hud_text settext( text_msg );
    self.heal_hud_text.alpha = 1;

    wait duration;

    // Ocultar solo si no está en cooldown activo (para no borrar el mensaje de cooldown)
    if ( !isdefined( self.heal_cooldown ) || !self.heal_cooldown )
    {
        self.heal_hud_text.alpha = 0;
    }
}

monitor_heal()
{
    self endon( "disconnect" );
    self endon( "death" );
    self endon( "end_monitor_heal" );

    heal_weapon = "briefcase_bomb_mp";
    heal_rate = 15; // Puntos de salud recuperados cada 0.05s (~300 HP por segundo)
    max_consecutive_uses = 2; // Bloqueo al curarse 2 veces seguidas
    max_interval_ms = 3000;   // Tiempo máximo (3s) entre curaciones para considerarse "seguidas"
    cooldown_time = 5;       // 5 segundos de cooldown
    min_anim_time = 1.2;     // Tiempo mínimo de animación en segundos para visualizar el tecleo

    for (;;)
    {
        wait 0.05;

        // Si está en cooldown o ya se está curando, esperar
        if ( isdefined( self.heal_cooldown ) && self.heal_cooldown )
            continue;

        if ( isdefined( self.is_healing ) && self.is_healing )
            continue;

        // Comprobar si el jugador está vivo, presiona la tecla de uso (F) y tiene menos de su salud máxima
        if ( isalive( self ) && self usebuttonpressed() && self.health < self.maxhealth )
        {
            current_weapon = self getcurrentweapon();
            if ( current_weapon == "none" || current_weapon == heal_weapon )
                continue;

            self.is_healing = true;
            self.heal_previous_weapon = current_weapon;

            // Ocultar mensaje prompt al comenzar a curarse
            if ( isdefined( self.heal_hud_text ) )
            {
                self.heal_hud_text.alpha = 0;
            }

            // Otorgar temporalmente el dispositivo del tecleo ("briefcase_bomb_mp")
            if ( !self hasweapon( heal_weapon ) )
            {
                self giveweapon( heal_weapon );
            }
            self setweaponammoclip( heal_weapon, 1 );
            self setweaponammostock( heal_weapon, 1 );
            self switchtoweapon( heal_weapon );

            start_time = gettime();

            // Bucle de curación mientras mantenga apretada la tecla F y tenga daño,
            // garantizando que la animación dure al menos min_anim_time segundos para ver los botones siendo presionados.
            while ( isalive( self ) && ( ( self usebuttonpressed() && self.health < self.maxhealth ) || ( ( gettime() - start_time ) < ( min_anim_time * 1000 ) ) ) )
            {
                if ( self.health < self.maxhealth )
                {
                    self.health += heal_rate;
                    if ( self.health > self.maxhealth )
                    {
                        self.health = self.maxhealth;
                    }
                }

                // Asegurar munición activa para que el motor no cambie de arma automáticamente
                self setweaponammoclip( heal_weapon, 1 );

                // Mantener al jugador en la animación del dispositivo
                if ( self getcurrentweapon() != heal_weapon )
                {
                    self switchtoweapon( heal_weapon );
                }

                wait 0.05;
            }

            // Quitar el dispositivo de la animación y devolver el arma que tenía equipada antes
            if ( self hasweapon( heal_weapon ) )
            {
                self takeweapon( heal_weapon );
            }

            if ( isalive( self ) && isdefined( self.heal_previous_weapon ) && self hasweapon( self.heal_previous_weapon ) )
            {
                self switchtoweapon( self.heal_previous_weapon );
            }

            self.is_healing = false;

            // Evaluar si es una curación consecutiva rápida (menos de 3 segundos desde la última curación)
            now = gettime();
            if ( isdefined( self.last_heal_time ) && self.last_heal_time > 0 && ( now - self.last_heal_time ) <= max_interval_ms )
            {
                self.heal_uses++;
            }
            else
            {
                self.heal_uses = 1;
            }
            self.last_heal_time = now;

            // Si se curó 2 veces seguidas rápidamente (en menos de 3s), activar el enfriamiento de 5 segundos
            if ( self.heal_uses >= max_consecutive_uses )
            {
                self thread start_heal_cooldown( cooldown_time );
            }

            // Requerir que el jugador suelte la tecla F antes de poder iniciar la siguiente curación
            while ( isalive( self ) && self usebuttonpressed() )
            {
                wait 0.05;
            }
        }
    }
}

start_heal_cooldown( duration )
{
    self endon( "disconnect" );
    self endon( "death" );

    self.heal_cooldown = true;

    if ( !isdefined( self.heal_hud_text ) )
    {
        self.heal_hud_text = self maps\mp\gametypes\_hud_util::createfontstring( "small", 1.0 );
        self.heal_hud_text.alignX = "left";
        self.heal_hud_text.alignY = "middle";
        self.heal_hud_text.horzAlign = "left";
        self.heal_hud_text.vertAlign = "middle";
        self.heal_hud_text.foreground = true;
        self.heal_hud_text.x = -40;
        self.heal_hud_text.y = 35; // Arriba del hpText
    }

    self.heal_hud_text settext( "^1Healing Cooldown (5s)" );
    self.heal_hud_text.alpha = 1;

    wait duration;

    self.heal_uses = 0;
    self.last_heal_time = 0;
    self.heal_cooldown = false;

    self.heal_hud_text settext( "^2Healing Ready" );
    self.heal_hud_text.alpha = 1;

    wait 1.5;

    if ( isdefined( self.heal_hud_text ) && (!isdefined( self.heal_cooldown ) || !self.heal_cooldown) )
    {
        self.heal_hud_text.alpha = 0;
    }
}