From: Ben Evans <bevans@cray.com>
Date: Tue, 9 Jun 2015 19:48:13 +0000
Subject: [lustre-devel] wiretest.c
Message-ID: <6E6D936CCB2E3C428716BD24C5C6CDF264330C@CFWEX01.americas.cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I'm trying to help out with the client code merging into the kernel project.  The first thing I dove into was ptlrpc, as it's a space that's been singled out as needing help.

In order to get my head around it, I'm just going through the code, and one of the first things that pops up is wiretest.c, which looks to be checking that things that have been #defined have the values that they are #defined to have, that structures are offset correctly (for a given value of 'correctly') etc.

So, I've started going through wiretest and seeing how much of the things that are defined are actually used in the code, and I find that some just aren't used at all, or at least not in other places than where they're defined, and wiretest. HSM_GHOST_COPY is a good example of it.  I can't find any usage in the mainline lustre-release code, or in the drivers/staging/lustre code.  Is this the sort of thing that should be flagged for deletion?

Secondly, if the code boils down to:
#define SOME_VAR 10

and

LASSERT(SOME_VAR == 10);

What's the point from a design perspective other than making it mildly more difficult to change?

Thanks for any help, or insight you can give

-Ben Evans
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20150609/157737dc/attachment-0001.htm>
