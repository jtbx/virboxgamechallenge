/* misc. utility functions */
module util;

import std.conv : to;
import std.file : remove;

import cs = deimos.curses;

import box : Box;

public alias stdscr = cs.stdscr;
public alias ColourPair = cs.COLOR_PAIR;


/*
 * Check the screen's dimensions and display a white-on-red
 * message if it isn't the right size.
 *
 * mincols is the minimum amount of columns, minrows is the
 * minimum amount of rows, dumpfile is the name of the file
 * to dump the screen state to, and dumped is set to true if
 * the screen state has been dumped, or false otherwise.
 */
void checkDimensions(in ushort mincols, in ushort minrows,
	in char *dumpfile, ref bool dumped)
{
	int rows, cols;

	cs.getmaxyx(cs.stdscr, rows, cols); /* get terminal size */
	/* if the screen state has not been dumped
	 * AND the terminal is too small: */
	if (!dumped && (rows < minrows || cols < mincols)) {
		cs.scr_dump(dumpfile); /* dump screen to file */
		dumped = true;
		cs.attron(ColourPair(1)); /* enable white-on-red palette */
		cs.mvprintw(0, 0, "terminal size too small (%d x %d)", cols, rows);
		cs.mvprintw(1, 0, "must be at least %d columns by %d rows",
			mincols, minrows);
		cs.attroff(ColourPair(1)); /* disable palette */
		cs.refresh();
	/* else, if the screen state HAS been dumped
	   AND the temrinal is still too small */
	} else if (dumped && (rows < minrows || cols < mincols)) {
		/* print the message again */
		cs.attron(ColourPair(1)); /* enable white-on-red palette */
		cs.mvprintw(0, 0, "terminal size too small (%d x %d)", cols, rows);
		cs.mvprintw(1, 0, "must be at least %d columns by %d rows",
			mincols, minrows);
		cs.attroff(ColourPair(1)); /* disable palette */
		cs.refresh();
	/* else, if the screen state HAS been dumped
	   AND the terminal is a good size */
	} else if (dumped && (rows >= minrows || cols >= mincols)) {
		/* restore screen state */
		cs.scr_restore(dumpfile); /* restore screen from file */
		cs.use_default_colors();
		cs.refresh();
		remove(dumpfile.to!string()); /* remove the dump file */
		dumped = false;
	}
}
/* destruct ncurses */
void endCurses() nothrow @nogc
{
	cs.refresh();
	cs.endwin();
}
