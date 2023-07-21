module player;

import std.meta : Alias;
import cs = deimos.curses;

alias Window = Alias!(cs.WINDOW *);

class Player
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

	int getY() const nothrow pure @nogc @safe
	{
		return _y;
	}
	void moveUp() nothrow @nogc
	{
		/* if the space is occupied, return */
		if (cs.mvwinch(_win, _y - 1, _x) != ' ') {
			return;
		}
		cs.mvwaddch(_win, _y, _x, ' '); /* remove character */
		_y -= 1;
		cs.mvwaddch(_win, _y, _x, ch); /* add character */
		cs.wrefresh(_win);
	}
	void moveDown() nothrow @nogc
	{
		/* if the space is occupied, return */
		if (cs.mvwinch(_win, _y + 1, _x) != ' ') {
			return;
		}
		cs.mvwaddch(_win, _y, _x, ' '); /* remove character */
		_y += 1;
		cs.mvwaddch(_win, _y, _x, ch); /* add character */
		cs.wrefresh(_win);
	}
	int getX() const nothrow pure @nogc @safe
	{
		return _x;
	}
	void moveLeft() nothrow @nogc
	{
		int newX;

		newX = _x - 2;
		/* if the space is occupied, return */
		if (cs.mvwinch(_win, _y, newX) != ' ' ||
		cs.mvwinch(_win, _y, (newX + _x) / 2) != ' ' ||
		newX + 2 == cs.getmaxx(_win) ||
		newX - 1 == 0) {
			return;
		}
		cs.mvwaddch(_win, _y, _x, ' '); /* remove character */
		_x = newX;
		cs.mvwaddch(_win, _y, _x, ch); /* add character */
		cs.wrefresh(_win);
	}
	void moveRight() nothrow @nogc
	{
		int newX;

		newX = _x + 2;
		/* if the space is occupied, return */
		if (cs.mvwinch(_win, _y, newX) != ' ' ||
		cs.mvwinch(_win, _y, (newX + _x) / 2) != ' ' ||
		newX + 2 == cs.getmaxx(_win) ||
		newX - 1 == 0) {
			return;
		}
		cs.mvwaddch(_win, _y, _x, ' '); /* remove character */
		_x = newX;
		cs.mvwaddch(_win, _y, _x, ch); /* add character */
		cs.wrefresh(_win);
	}
}
