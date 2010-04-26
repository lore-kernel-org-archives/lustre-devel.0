From: Ken Hornstein <kenh@cmf.nrl.navy.mil>
Date: Mon, 26 Apr 2010 14:15:32 -0400
Subject: [Lustre-devel] Build system and portability
In-Reply-To: <1272290167.19510.102.camel@pc.interlinx.bc.ca>
Message-ID: <201004261815.o3QIFW55029195@hedwig.cmf.nrl.navy.mil>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>The autoconf portion is not terribly bad, I think.  It could probably
>use a bit of macro reorganization, and some more reasonable defaults for
>things like kernel, etc. but I am working on the latter currently.  It
>seemed a real mess to me at first, but the more I worked with it, the
>more I understood the organization of it.

Forgive me for implying otherwise; it's really more a bunch of
portability cleanup issues.  Like not doing Linux kernel feature tests
on non-Linux systems, that sort of thing (I guess those don't technically
harm anything, but there were a few things that would fail and those needed
to be system-dependent).

>Why we cannot/didn't just put the modules into it's own tree with kernel
>build system Makefiles and keep everything in a separate tree with their
>own non-kernel build system Makefiles... I am not sure, but as Andreas
>mentioned, is likely just due to the history and the baggage that has
>not been shed when support for historical systems was dropped.

Again, I'm not the expert on how kernel module building works ... but
there seems to be some interdependency in the current Lustre setup (the
Makefiles include Rules, which includes autoMakefile).  I would just be
happy if we could get down to one Makefile; is that possible, given the
way that Linux kernel module builds work?

Oh, as long as we're on the subject ... when I file portability bugs
using bugzilla, I am never happy with the component I have to pick to
file the bug under (I end up with something like "integration").  Can
we get a Bugzilla component titled "portability"?  Or if people are
happy with "integration" (or would rather I use something else), I
guess that's okay as well.

--Ken
