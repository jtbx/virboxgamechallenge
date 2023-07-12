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
import entity; /* Entity class */

alias stdscr = cs.stdscr;
alias ColourPair = cs.COLOR_PAIR;

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
enum MINROWS = 30;
enum MINCOLS = 82;

/* Size and position of UI elements */
enum GAMEBOX_H = 15;
enum GAMEBOX_W = 65;
enum GAMEBOX_Y = 5;
enum GAMEBOX_X = 8;
enum TEXTBOX_H = 8;
enum TEXTBOX_W = 65;
enum TEXTBOX_Y = 20;
enum TEXTBOX_X = 8;

/* File to dump screen contents to */
const char *DUMPFILE = cast(char *)".vscrdump";


int main(string[] args)
{	
	bool dumped;
	int  ch, tmp;
	Box    game;
	Box    text;
	Entity player;

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
		stderr.writefln("%s: %s", args[0].baseName(), format(fmt, a));

		scope (exit) {
			Runtime.terminate();
			exit(1);
		}
	}

	void refreshAll() nothrow @nogc
	{
		cs.refresh();
		cs.wrefresh(game.win);
		cs.wrefresh(text.win);
	}

	void checkDimensions()
	{
		int rows, cols;

		cs.getmaxyx(stdscr, rows, cols); /* get terminal size */
		/* if the screen state has not been dumped
		 * AND the terminal is too small: */
		if (!dumped && (rows < MINROWS || cols < MINCOLS)) {
			cs.scr_dump(DUMPFILE); /* dump screen to file */
			dumped = true;
			cs.clear(); /* clear entire screen */
			cs.attron(ColourPair(1)); /* enable white-on-red palette */
			cs.mvprintw(0, 0, "terminal size too small (%d x %d)", cols, rows);
			cs.mvprintw(1, 0, "must be at least %d columns by %d rows",
				MINCOLS, MINROWS);
			cs.attroff(ColourPair(1)); /* disable palette */
			cs.refresh();
		/* else, if the screen state HAS been dumped
		   AND the terminal is a good size */
		} else if (dumped && (rows >= MINROWS || cols >= MINCOLS)) {
			/* restore screen state */
			cs.clear(); /* clear entire screen */
			cs.scr_restore(DUMPFILE); /* restore screen from file */
			refreshAll();
			remove(DUMPFILE.to!string()); /* remove the dump file */
			dumped = false;
		}
	}

	dumped = false;

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

	checkDimensions();

	game = new Box(GAMEBOX_H, GAMEBOX_W, GAMEBOX_Y, GAMEBOX_X);
	text = new Box(TEXTBOX_H, TEXTBOX_W, TEXTBOX_Y, TEXTBOX_X);
	player = new Entity(game.win, 2, 2, '+');

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
				checkDimensions();
			}
			continue;
		}
		switch (ch) {
			case Key.RESIZE: /* on window resize */
				checkDimensions();
				break;
			case Key.UP:
			case 'w':
			case 'k':
				player.y = player.y - 1;
				break;
			case Key.DOWN:
			case 's':
			case 'j':
				player.y = player.y + 1;
				break;
			case Key.LEFT:
			case 'a':
			case 'h':
				player.x = player.x - 1;
				break;
			case Key.RIGHT:
			case 'd':
			case 'l':
				player.x = player.x + 1;
				break;
			case 'q': /* quit key */
				text.clear();
				cs.mvwprintw(text.win, 1, 2, "Are you sure you want to quit? ");
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

/* destruct ncurses */
void endCurses() nothrow @nogc
{
	cs.refresh();
	cs.endwin();
}
