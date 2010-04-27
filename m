From: Ken Hornstein <kenh@cmf.nrl.navy.mil>
Date: Mon, 26 Apr 2010 21:37:30 -0400
Subject: [Lustre-devel] Build system and portability
In-Reply-To: <0C946F67-6483-4781-ADB6-465F25D3B828@oracle.com>
Message-ID: <201004270137.o3R1bUYE001797@hedwig.cmf.nrl.navy.mil>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>I suspect that we might be able to get something like a "Makefile fragment"
>that is containing all of the build targets, that is included in an
>arch-specific top-level Makefile to specify exactly how those files will
>be built.  Sadly, I don't know anything about this area.

I am thinking along these lines as well; the wrinkle is the way that
the Linux module building process works.

>The intention of "component" is e.g. "what part of the code the defect is in
>(e.g. client, server, quota, etc).  I'd think most of your problems are in
>"Build/Release Engineering" and "OS X", though some will be "llite/mdc",
>"llite/vfs", and "IO/llite/lov/osc".

Well, take a look at bug 22692 as an example.  That doesn't feel like
build/release engineering.  And it's not really MacOS X either.

Another example: if I include a bunch of patches to clean up lock leaks
in libcfs ... where should that go?  Perhaps it's not a huge deal; I can
just take my best guess at it and go from there.

(Actually, can we add MacOS X as one of the "OS" choices?).

>In this light, it would be interesting to know whether you were able to
>re-use parts of the lustre/llite code (e.g. llite_lib.c) and it should be
>moved into a shared directory like lustre/lclient (which is supposed to be
>entirely portable).  Spending some time to incrementally move (and get
>upstream) parts of the llite code that are portable between linux and
>macos would ensure that the ongoing maintenance is reduced.  The problem
>with making too many changes in a port and not returning them upstream
>is that eventually the code diverges so much that the ongoing 

Sadly, I could not use anything from llite_lib.c (or anything from
llite, really) at all; it's way Linux-specific.  Given the way the
code is structured, I'm not sure there is any alternative; Linux
is so different in terms of filesystem implementation I don't see
very much in llite that could be made generic (I guess I could
imagine some generic stuff, but it would probably be a mess of
ifdefs).  It's actually even worse than that; the "generic" code
in obdclass/mount.c is also Linux-specific (that file had to be
split off into a Linux and Darwin version, although I think that
could be cleaned up a fair amount; I am unclear as to why some of
that split exists, although it might be required for the server
support).  I did steal a few routines from lclient, but a large
number of those routines were extrememly non-portable so I couldn't
use those files as-is; I didn't want to have a huge mess of ifdef's
in there so I just stole the few routines I needed.

However ... I think the changes for the Mac client are pretty
self-contained; the vast majority of the "real" magic is in libcfs
and lvnode.  From my experience in tracking master, very few changes
affect me.

(You can look at this yourself once we get the repository stuff
straightened out; I think we're almost there).

--Ken
