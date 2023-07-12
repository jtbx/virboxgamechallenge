module box;

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

	void clear()
	{
		cs.wclear(win); /* Clear window */
		redraw(height, width,
               starty, startx); /* Redraw text box */
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
		this.endy = starty + height;
		this.endx = startx + width;
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

