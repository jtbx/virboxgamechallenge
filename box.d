module box;

import core.thread : Thread;
import core.time   : dur;

import std.meta : Alias;

import cs = deimos.curses;

alias Window = Alias!(cs.WINDOW *);

class Box
{
	int starty, startx;
	int endy, endx;
	int height, width;
	Window win;

	this(int height, int width, int starty, int startx) nothrow @nogc
	{
		this.starty = starty;
		this.startx = startx;
		this.endy = starty + height;
		this.endx = startx + width;
		this.height = height;
		this.width = width;
		/* create window */
		win = cs.newwin(height, width, starty, startx);
		cs.box(win, 0, 0); /* make a box border */
		cs.wrefresh(win);
	}
	~this() nothrow @nogc
	{
		cs.wborder(win, ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
		cs.wrefresh(win);
		cs.delwin(win);
	}

	void clear() nothrow @nogc
	{
		cs.wclear(win); /* Clear window */
		redraw(height, width,
               starty, startx); /* Redraw text box */
	}

	void newline() nothrow @nogc
	{
		int y, x;

		cs.getyx(win, y, x);
		cs.wmove(win, y + 1, 2);
	}

	/*
	 * Display text using a typewriter-like text effect.
	 */
	void quote(string s, long interval = 30)
	{
		int i;
		int y, x;
	
		cs.wmove(win, 1, 2);
		for (i = 0; i < s.length; i++) {
			if (s[i] == '\n') {
				newline();
				continue;
			}
			cs.getyx(win, y, x);
			if (x + 3 == width) {
				if (s[i] == ' ') {
					cs.waddch(win, s[i]);
					newline();
					continue;
				} else {
					cs.waddch(win, '-');
				}
				newline();
			}
			cs.waddch(win, s[i]);
			cs.wrefresh(win);
			cs.flushinp();
			Thread.sleep(dur!"msecs"(interval));
		}
	}
	void quotew(string s, long interval = 30)
	{
		quote(s, interval);
		while (cs.wgetch(win) != '\n') {}
		clear();
	}

	void redraw(int height, int width, int starty, int startx) nothrow @nogc
	{
		/* delete window */
		cs.wclear(win);
		cs.wrefresh(win);
		cs.delwin(win);
		/* set new positions */
		this.starty = starty;
		this.startx = startx;
		this.endy = starty + height - 1;
		this.endx = startx + width - 1;
		this.height = height;
		this.width = width;
		/* create window */
		win = cs.newwin(height, width, starty, startx);
		cs.box(win, 0, 0); /* make a box border */
		cs.wrefresh(win);
	}
	void redraw() nothrow @nogc
	{
		redraw(height, width, starty, startx);
	}
}

