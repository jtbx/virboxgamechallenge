module entity;

import std.meta : Alias;
import cs = deimos.ncurses;

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
	@property y(int newVal) nothrow @nogc
	{
		cs.mvwaddch(_win, _y, _x, ' ');
		_y = newVal;
		cs.mvwaddch(_win, _y, _x, ch);
		cs.wrefresh(_win);
	}
	@property x() const nothrow pure @nogc @safe
	{
		return _x;
	}
	@property x(int newVal) nothrow @nogc
	{
		cs.mvwaddch(_win, y, x, ' ');
		_x = newVal;
		cs.mvwaddch(_win, y, x, ch);
		cs.wrefresh(_win);
	}
}
