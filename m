From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 15 Dec 2015 14:42:40 +0300
Subject: [lustre-devel] staging: lustre: Less checks in
 mgc_process_recover_log() after error detection
In-Reply-To: <566EFFB3.708@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
	<566D7952.7090401@users.sourceforge.net>
	<20151214110003.GV5284@mwanda>
	<566EB03E.2000007@users.sourceforge.net>
	<20151214123840.GX5284@mwanda>
	<566EB9D7.9090904@users.sourceforge.net>
	<20151214135750.GY5284@mwanda> <566EFFB3.708@users.sourceforge.net>
Message-ID: <20151215114240.GB5284@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Dec 14, 2015 at 06:43:15PM +0100, SF Markus Elfring wrote:
> Our software development dialogue seems to trigger special
> challenges between us so far.

I try very hard to review patches mechanically and not be biased so that
after a while people know if their patches will be merged or not without
waiting for feedback.

In this case, I had asked you not to send patches renaming out labels
and then the next day you sent me a string of patches renaming out
labels.  If you were a lustre dev then I would accept these renames
definitely.  But I believe that for anyone else, I would ask them what
the point of doing these renames is.  I do not think I have been unfair
to you.  There was no element of surprise.

Part of the reason we have CodingStyle is so that we can tell people
"That's not in CodingStyle, that's just your own opinion so don't redo
code just because you have a different opinion from the maintainer."

> Are you generally willing to change the exception handling for
> the memory allocations in the function "mgc_process_recover_log"
> at all?

I like the first patch in this series.  I do not like the renames.  I
don't care too much about patches 5 and 6 except that they should be
folded together and you should not move "req" and "eof" around.

Mostly I wish you would just focus on fixing bugs instead of these sorts
of patches.  It is a lot of work for me to explain how to redo patches
but it is worth it for bugfixes.

regards,
dan carpenter
