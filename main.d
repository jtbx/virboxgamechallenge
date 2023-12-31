/*
 * My entry to the 1st Virbox coding challenge.
 * It draws a couple of windows onto the terminal
 * using curses, and then draws the player and the
 * map onto the screen. Very incomplete, at least
 * the movement system works. There is also a basic
 * mapping "system" (basically just a function in
 * the Box class) which allows an array of strings
 * to be placed over the game window. Very handy
 * and I like it. I might reuse this code some
 * other time but for now this is all I got. o7
 *
 * Use HJKL, WASD or the arrow keys to move the
 * character around the screen. The character
 * will not move if there is an obstacle in the
 * way, such as another character or a window
 * border. A "window" in curses terms means a
 * container which you can draw text into.
 *
 * Licensed under the GNU General Public License,
 * version 2. See the COPYING file included for
 * the full license.
 */

import core.sys.posix.unistd : isatty;

import std.algorithm.comparison : clamp;
import std.math.rounding : ceil;

import std.conv   : to;
import std.file   : remove;
import std.format : format;
import std.meta   : Alias;
import std.traits : isSomeString;

/* Import curses into the "cs" namespace */
import cs = deimos.curses;

import box;    /* Box class */
import player; /* Player class */
import util;   /* utility functions, ColourPair alias and stdscr alias */

enum Key
{
	RESIZE      = /*0632*/ 0x19a,            /* Terminal resize event */
	DOWN        = /*0402*/ 0x102,            /* down-arrow key */
	UP          = /*0403*/ 0x103,            /* up-arrow key */
	LEFT        = /*0404*/ 0x104,            /* left-arrow key */
	RIGHT       = /*0405*/ 0x105             /* right-arrow key */
}
enum Colour
{
	BLACK,
	RED,
	GREEN,
	YELLOW,
	BLUE,
	MAGENTA,
	CYAN,
	WHITE
}

/* Minimum required terminal size */
ushort MINROWS = 28;
ushort MINCOLS = 82;

/* Size and position of UI elements */
ushort GAMEBOX_H = 15;
ushort GAMEBOX_W = 65;
ushort GAMEBOX_Y = 5;
ushort GAMEBOX_X = 8;
ushort TEXTBOX_H = 8;
ushort TEXTBOX_W = 65;
ushort TEXTBOX_Y = 20;
ushort TEXTBOX_X = 8;

/* File to dump screen contents to */
const char *DUMPFILE = cast(char *)".vscrdump";


int main(string[] args)
{	
	bool dumped;
	int  ch, tmp;
	Box    game;
	Box    text;
	Player player;

    void panic(R, A...)(R fmt, A a)
    if (isSomeString!R)
	{
		import core.runtime     : Runtime;
		import core.stdc.stdlib : exit;
		import std.path  : baseName;
		import std.stdio : stderr;

		game.destroy();
		text.destroy();
		endCurses();
		stderr.writefln("%s: %s", baseName(args[0]), fmt.format(a));

		scope (exit) {
			Runtime.terminate();
			exit(1);
		}
	}

	if (!isatty(1)) {
		panic("output is not to a terminal; cannot continue");
	}

	cs.initscr(); /* initialise curses */

	if (!cs.has_colors()) {
		panic("terminal does not support color; cannot continue");
	}

	cs.start_color(); /* enable color */
	cs.use_default_colors(); /* take terminal transparency into account */
	cs.raw(); /* disable line buffering */
	cs.noecho(); /* don't echo characters when we run getch() */
	cs.curs_set(0); /* don't show the cursor */
	cs.keypad(stdscr, 1); /* catch F* and arrow key characters */

	/* colours */
	cs.init_color(Colour.RED, 1000, 0, 0);
	/* colour pairs */
	cs.init_pair(1, Colour.WHITE, Colour.RED);

	checkDimensions(MINCOLS, MINROWS, DUMPFILE, dumped);

	game = new Box(GAMEBOX_H, GAMEBOX_W, GAMEBOX_Y, GAMEBOX_X);
	text = new Box(TEXTBOX_H, TEXTBOX_W, TEXTBOX_Y, TEXTBOX_X);
	player = new Player(game.win, 12, 60, '*');

	game.map([
	`  `,
	`   _______ `,
	`  /virbox \   0   0   0   0   0`,
	`  | farms |   |   |   |   |   |`,
	`  |_______|   0   0   0   0   0`,                
	`     |_|      |   |   |   |   | `
	]);

	text.quotew(
"Welcome to virboxquest! We'll give you a quick tutorial.
First, move your character around using h, j, k and l,
or you can use w, a, s, and d.
Remove this text by pressing [Enter].
");


	do {
		ch = cs.wgetch(game.win);
		/*
		 * if we're waiting for the player to resize the terminal,
		 * we want to check the dimensions and then continue with
		 * the next run of the loop immediately, we don't want any
		 * of the other keybinds to be detected until the player
		 * resizes their terminal dimensions properly
		 */
		if (dumped) {
			if (ch == Key.RESIZE) {
				checkDimensions(MINCOLS, MINROWS, DUMPFILE, dumped);
			}
			continue;
		}
		switch (ch) {
			case Key.RESIZE: /* on window resize */
				checkDimensions(MINCOLS, MINROWS, DUMPFILE, dumped);
				break;
			case Key.UP:
			case 'w':
			case 'k':
				player.moveUp();
				break;
			case Key.DOWN:
			case 's':
			case 'j':
				player.moveDown();
				break;
			case Key.LEFT:
			case 'a':
			case 'h':
				player.moveLeft();
				break;
			case Key.RIGHT:
			case 'd':
			case 'l':
				player.moveRight();
				break;
			case 'q': /* quit key */
				text.clear();
				text.quote("Are you sure you want to quit? ", 20);
				cs.curs_set(1); /* show cursor */
				tmp = cs.wgetch(text.win);
				if (tmp == 'y' || tmp == 'Y') {
					game.destroy();
					text.destroy();
					endCurses();
					return 0;
				} else {
					cs.curs_set(0);
					text.clear();
					break;
				}
			default:
				break;
		}
		cs.wrefresh(game.win);
		cs.wrefresh(text.win);
	} while (ch);

	game.destroy();
	endCurses();

	return 0;
}
