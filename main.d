import std.algorithm.comparison : clamp;
import std.math.rounding : ceil;

import std.conv   : to;
import std.format : format;
import std.meta   : Alias;
import std.traits : isSomeString;

/* Import curses into the "cs" namespace */
import cs = deimos.curses;

import box;    /* Box class */
import entity; /* Entity class */

alias stdscr = cs.stdscr;

enum Key
{
	RESIZE      = /*0632*/ 0x19a,            /* Terminal resize event */
	DOWN        = /*0402*/ 0x102,            /* down-arrow key */
	UP          = /*0403*/ 0x103,            /* up-arrow key */
	LEFT        = /*0404*/ 0x104,            /* left-arrow key */
	RIGHT       = /*0405*/ 0x105             /* right-arrow key */
}
enum MINROWS = 20;
enum MINCOLS = 70;

int main(string[] args)
{	
	int ch;
	int rows, cols;
	Box gamebox;
	Box textbox;
	Entity player;

    void panic(R, A...)(R fmt, A a)
    if (isSomeString!R)
	{
		import core.runtime     : Runtime;
		import core.stdc.stdlib : exit;
		import std.path  : baseName;
		import std.stdio : stderr;

		endCurses();
		stderr.writefln("%s: %s", args[0].baseName(), format(fmt, a));

		scope(exit) {
			Runtime.terminate();
			exit(1);
		}
	}

	void checkDimensions(ref int rows, ref int cols)
	{
		cs.getmaxyx(stdscr, rows, cols); /* get terminal size */
		if (rows < MINROWS || cols < MINCOLS) {
			panic("terminal size too small (%d x %d)
	must have at least %d columns and %d rows", cols, rows, MINCOLS, MINROWS);
		}
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

	checkDimensions(rows, cols);

	gamebox = new Box(rows / 2, cols / 2, rows / 4, cols / 4);
	player = new Entity(gamebox.win, 2, 2, '@');

	do {
		ch = cs.wgetch(gamebox.win);
		switch (ch) {
			case Key.RESIZE:
				checkDimensions(rows, cols);
				gamebox.redraw(rows / 2, cols / 2, rows / 4, cols / 4);
				break;
			case Key.UP:
			case 'k':
				player.y = player.y - 1;
				break;
			case Key.DOWN:
			case 'j':
				player.y = player.y + 1;
				break;
			case Key.LEFT:
			case 'h':
				player.x = player.x - 1;
				break;
			case Key.RIGHT:
			case 'l':
				player.x = player.x + 1;
				break;
			default:
				break;
		}
		//player.y = clamp(player.y, gamebox.starty, gamebox.endy);
		//player.x = clamp(player.x, gamebox.startx, gamebox.endx);
		cs.wrefresh(gamebox.win);
	} while (ch != 'q');

	gamebox.destroy();

	endCurses();

	return 0;
}

void calcPositions(int rows, int cols,
                   ref int starty, ref int startx,
                   ref int endy, ref int endx)
{
	starty = (rows / 2).to!int();
	startx = (cols / 2).to!int();
	endy = ((rows / 2) + (rows / 4)).to!int();
	endx = ((cols / 2) + (cols / 4)).to!int();
}

/* destruct ncurses */
void endCurses() nothrow @nogc
{
	cs.refresh();
	cs.endwin();
}
