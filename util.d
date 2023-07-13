/* misc. utility functions */
module util;

import cs = deimos.curses;
import core.thread : Thread;

import box;

void bquotew(Box b, string s)
{
	int i;

	for (i = 0; i < s.length; i++) {
		cs.waddch(b.win, s[i]);
		Thread.sleep(dur!"msecs"(100));
	}
}
