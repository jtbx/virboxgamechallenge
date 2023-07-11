module box;

import std.meta : Alias;

import cs = deimos.curses;

alias Window = Alias!(cs.WINDOW *);

class Box
{
	int starty, startx;
	int endy, endx;
	Window win;

	this(int height, int width, int starty, int startx) nothrow @nogc
	{
		this.starty = starty;
		this.startx = startx;
		this.endy = starty + height;
		this.endx = startx + width;
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

	void redraw(int height, int width, int starty, int startx) nothrow @nogc
	{
		/* delete window */
		cs.wborder(win, ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');
		cs.wrefresh(win);
		cs.delwin(win);
		/* set new positions */
		this.starty = starty;
		this.startx = startx;
		this.endy = starty + height;
		this.endx = startx + width;
		/* create window */
		win = cs.newwin(height, width, starty, startx);
		cs.box(win, 0, 0); /* make a box border */
		cs.wrefresh(win);
	}
}

