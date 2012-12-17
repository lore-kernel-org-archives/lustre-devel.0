From: Ken Hornstein <kenh@cmf.nrl.navy.mil>
Date: Mon, 17 Dec 2012 00:44:24 -0500
Subject: [Lustre-devel] [wc-discuss] Important changes to libcfs
	primitives usage.
In-Reply-To: <2BD6B3FE-788D-4B27-8759-FFCB2EC612D6@intel.com>
Message-ID: <201212170544.qBH5iOuM019618@hedwig.cmf.nrl.navy.mil>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>While I would be thrilled if there was a native MacOS and Windows client
>for Lustre, realistically there is nothing today.  The MacOS client is
>not maintained, and the Windows client is stick inside Oracle.
>
>In contrast, only the Linux client is on use today, so it makes sense to
>focus effort on this instead of spending time on maintaining portability
>code that is not useful to us.
>
>If the other clients were usable, perhaps a different decision would be
>made.

So, let me speak to that a bit since I was the one who did the MacOS X port
which has been langunishing.

Andreas is completely right that 90% of libcfs library for Linux at least
is adding to kernel internal interfaces a "cfs_" prefix.  So that part at
least isn't going to change the issues with porting Lustre to other operating
systems; you have to pretty much emulate a whole pile of Linux interfaces.
So that doesn't really worry me in terms of future portability.

What _does_ concern me is that to be portable Lustre needs some code in the
generic side of things.  Example: locks in MacOS X are done via allocated
memory, so you need to release that memory when you're done.  Lustre never
does this (because it's not needed under Linux since locks use statically
allocated memory).  So is it going to be possible in the future to put
generic code to aid portabiliy in Lustre?  I don't know.

Personally, I think putting Lustre in the Linux kernel is a terrible
idea, but since I was obviously in the minority on that one I figured
there was no reason to really say anything about it.  Also, it's hard
for me to voice objections about possible MacOS X portability issues
when I can't dedicate any resources to cleaning up the MacOS X port.

--Ken
