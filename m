From: Ken Hornstein <kenh@cmf.nrl.navy.mil>
Date: Thu, 22 Jul 2010 11:10:27 -0400
Subject: [Lustre-devel] clio layer & portability
Message-ID: <201007221510.o6MFARem014801@hedwig.cmf.nrl.navy.mil>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

In conversations with Andreas, he suggested I send some of this to a wider
audience.

Everyone knows by now I'm working on the MacOS X port, right?  Okay, good.

As part of that work, I've been working on attribute caching.  Right now
I'm hitting a bit of a snag when it comes to caching the file size; unlike
all of the metadata attributes, this requires getting glimpse locks on
the OSTs.  And this starts bringing up the large outstanding issue of
the clio layer.

Specifically, clio has ... portability problems.  The big one that
crops up right away is the general assumption that OS memory pages are
indexed via a radix tree.  This sort of also ties into the way memory
management is handled (I'm not aware of any OS, other than Linux, that
provides a callback that the OS can use if they are experiencing memory
pressure to tell kernel modules to give up pages).

Obviously these aren't new issues.  For the first release of the MacOS port,
I didn't use clio at all.  But now it's coming up and I'm wondering ...
since Lustre is now being ported to other OSes, what did everyone else
do about these issues?

--Ken
