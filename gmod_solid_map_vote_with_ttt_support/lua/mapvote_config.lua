-- Time in seconds until the mapvote is over from
-- when it starts.
SolidMapVote[ 'Config' ][ 'Length' ] = 25

-- The time in seconds that the vote will stay on the screen
-- after the winning map has been chosen.
SolidMapVote[ 'Config' ][ 'Post Vote Length' ] = 5

-- This option controls the size of the map vote buttons.
-- This will effect how the images look. If your switching from tall to
-- the square option, then the images should look fine. Vice Versa you'll
-- need to get some new pictures because up scaling small images up looks like butt.
-- 1 = Tall and skinny vote buttons
-- 2 = Square vote buttons
SolidMapVote[ 'Config' ][ 'Map Button Size' ] = 0.5

-- This option allows you to set a time for when the map vote will
-- appear after. The first option must be set to true, then the second
-- option controls how long before it comes up in seconds. Simply math
-- can be used to control the length. The last option sets how long before
-- the vote pops up to show a reminder that it is going to happen.
SolidMapVote[ 'Config' ][ 'Enable Vote Autostart' ] = false
SolidMapVote[ 'Config' ][ 'Vote Autostart Delay' ] = 5*60 + 30  -- 5 minutes 30 seconds
SolidMapVote[ 'Config' ][ 'Autostart Reminder' ] = 1*60 -- 1 minute
SolidMapVote[ 'Config' ][ 'Time Left Commands' ] = {
    '!timeleft', '/timeleft', '.timeleft'
}

-- This it the prefix for maps you want to unclude into
-- the possible maps for the mapvote.
-- List of typical gamemodes prefixes.
-- ttt  = Trouble in Terrorist Town
-- bhop = Bunny Hop
-- surf = Surf
-- rp   = Role Play
SolidMapVote[ 'Config' ][ 'Map Prefix' ] = {
    'ttt',
    'rp',
    'gm',
    'mu',
    'hmcd',
    'de',
    'cs'
}

local namecolor = {
   default = COLOR_WHITE,
   superadmin = Color(212,175,55),
   admin = Color(0,191,255),
   veteran = Color(255,20,147),
   moderator = Color(124,252,0),
   supporter = Color(124,252,0),
   servertreuer = Color(178,34,34),
   nutzer = Color(65,105,225),
   user = Color(230,230,250)
};

-- Use this function to give specific players or groups different colored
-- avatar borders on the map vote.
SolidMapVote[ 'Config' ][ 'Avatar Border Color' ] = function( ply )

  if ply:IsUserGroup("superadmin") then
	return HSVToColor( math.sin( 0.3*RealTime() )*128 + 127, 1, 1 )
  end

  if ply:IsUserGroup("servertreuer") then
	return namecolor.servertreuer
  end
    -- This is the default color
    return color_white
end

-- Use this function to give players more vote power than others.
-- I would personally keep all players at the same power because
-- I beleive in equal vote power, but this is up to you.
SolidMapVote[ 'Config' ][ 'Vote Power' ] = function( ply )
    if ply:IsAdmin() then
        return 1
    end

    -- Default vote power
    -- Would keep this at 1, unless you know what your doing (you're*)
    return 1
end

-- Enabling this option will give greater a chance to maps
-- that are played less often to be selected in the vote.
-- Disabling it will let the map vote randomly choose maps for the vote.
SolidMapVote[ 'Config' ][ 'Fair Map Recycling' ] = true

-- Setting this to true will display on the map vote button how many
-- times the map was played in the past.
SolidMapVote[ 'Config' ][ 'Show Map Play Count' ] = true

-- Setting the option below to true will allow you to manually set the
-- map pool using the table below. Only the maps inside the table will
-- be able to be chosen for the vote.
SolidMapVote[ 'Config' ][ 'Manual Map Pool' ] = false
SolidMapVote[ 'Config' ][ 'Map Pool' ] = {

}

-- Allow players to use their mics while in the mapvote
SolidMapVote[ 'Config' ][ 'Enable Voice' ] = true

-- Allow players to use the chat box while in the mapvote
SolidMapVote[ 'Config' ][ 'Enable Chat' ] = true

-- Here you can specify what players can force the mapvote to appear.
SolidMapVote[ 'Config' ][ 'Force Vote Permission' ] = function( ply )
    return ply:IsAdmin()
end

-- These commands can be used by players specified above to
-- start the mapvote regarless of the amount of players that rtv
SolidMapVote[ 'Config' ][ 'Force Vote Commands' ] = {
    '!forcertv', '/forcertv', '.forcertv'
}

-- This is the percentage of players that need to rtv in order for the vote
-- to come up
SolidMapVote[ 'Config' ][ 'RTV Percentage' ] = 0.6

-- This is the time in seconds that must pass before players can begin to RTV
SolidMapVote[ 'Config' ][ 'RTV Delay' ] = 60

-- If this is set to true, players will be able to remove their RTV
-- by typing the RTV command again.
SolidMapVote[ 'Config' ][ 'Enable UnVote' ] = true

-- These commands will add to rocking the vote.
SolidMapVote[ 'Config' ][ 'Vote Commands' ] = {
    '!rtv', '/rtv', '.rtv'
}

-- Set this option to true if you want to ignore the
-- prefix and just use all the maps in your maps folder.
SolidMapVote[ 'Config' ][ 'Ignore Prefix' ] = false

-- These commands will open the nomination menu
SolidMapVote[ 'Config' ][ 'Nomination Commands' ] = {
    '!nominate', '/nominate', '.nominate'
}

-- Set this option to true if you want players to be able to
-- nominate maps.
SolidMapVote[ 'Config' ][ 'Allow Nominations' ] = true

-- You can use this function to only allow certain players to be able to
-- use the nomination system. Open a support ticket if you need assistance
-- setting this up.
SolidMapVote[ 'Config' ][ 'Nomination Permissions' ] = function( ply )
    return true
end

-- Set this to true if you want the option to extend the map on the vote
-- Set to false to disable
SolidMapVote[ 'Config' ][ 'Enable Extend' ] = true
SolidMapVote[ 'Config' ][ 'Extend Image' ] = 'http://i.imgur.com/zzBeMid.png'

-- Set this to true if you want the option to choose a random map
-- Set to false to disable
SolidMapVote[ 'Config' ][ 'Enable Random' ] = true
-- This option controls how the random button works
-- 1 = Random map will be selected from the maps on the vote menu
-- 2 = Random map will be selected from the entire map pool
SolidMapVote[ 'Config' ][ 'Random Mode' ] = 2
SolidMapVote[ 'Config' ][ 'Random Image' ] = 'http://i.imgur.com/oqeqWhl.png'

-- This is the image for maps that are missing an image
SolidMapVote[ 'Config' ][ 'Missing Image' ] = ''
SolidMapVote[ 'Config' ][ 'Missing Image Size' ] = { width = 1920, height = 1080 }

-- In this table you can add information for the map to make it more
-- appealing on the mapvote.
SolidMapVote[ 'Config' ][ 'Specific Maps' ] = {
    { filename = 'ttt_minecraft_b5', displayname = 'Minecraft B5', image = 'http://i2.imgbus.com/doimg/3co1mmfoncb63a7.jpg', width = 1920, height = 1080 },
}
