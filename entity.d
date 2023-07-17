module entity;

import std.meta : Alias;
import cs = deimos.curses;

alias Window = Alias!(cs.WINDOW *);

class Entity
{
	char ch;
	private {
		int _y;
		int _x;
		Window _win;
	}

	this(Window win, short y, short x, char ch)
	{
		this._win = win;
		this.ch = ch;
		this._y = y;
		this._x = x;
		cs.mvwaddch(win, y, x, ch);
		cs.wrefresh(_win);
	}

	@property y() const nothrow pure @nogc @safe
	{
		return _y;
	}
	@property void y(int newVal) nothrow @nogc
	{
		/* if the space is occupied, return */
		if (cs.mvwinch(_win, newVal, _x) != ' ') {
			return;
		}
		cs.mvwaddch(_win, _y, _x, ' '); /* remove character */
		_y = newVal;
		cs.mvwaddch(_win, _y, _x, ch); /* add character */
		cs.wrefresh(_win);
	}
	@property x() const nothrow pure @nogc @safe
	{
		return _x;
	}
	@property void x(int newVal) nothrow @nogc
	{
		int begx;
		int maxx;

		begx = cs.getbegx(_win);
		maxx = cs.getmaxx(_win);
		/* if the space is occupied, return */
		if (cs.mvwinch(_win, _y, newVal) != ' ' ||
		cs.mvwinch(_win, _y, (newVal + _x) / 2) != ' ' ||
		newVal + 2 == maxx ||
		newVal - 1 == 0) {
			return;
		}
		cs.mvwaddch(_win, _y, _x, ' '); /* remove character */
		_x = newVal;
		cs.mvwaddch(_win, _y, _x, ch); /* add character */
		cs.wrefresh(_win);
	}
}
