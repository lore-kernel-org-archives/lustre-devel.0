From: Ken Hornstein <kenh@cmf.nrl.navy.mil>
Date: Fri, 23 Apr 2010 12:27:11 -0400
Subject: [Lustre-devel] Build system and portability
Message-ID: <201004231627.o3NGRBxu029735@hedwig.cmf.nrl.navy.mil>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

(I wanted to start some discussions on portability.  This is one of the
earliest things that I ran into for the MacOS X port).

So, the build system was one of my earliest challenges, and I wanted to get
some ideas from other people.

Aside from the various Linux-specific autoconf tests (those are relatively
straightforward to deal with), one big issue that has cropped up is the
way that the build system ends up building Makefiles.

Specifically, there seems to be a disconnect between Makefile.in and
autoMakefile.am.  Let's take lustre/obdclass as an example.

The object files for the kernel module for Linux are listed in Makefile.in
(they're in the variables obdclass-linux-objs and obdclass-all-objs, and
those are combined into obdclass-objs).  However, the actual definitions
of the modules to build get set in autoMakefile.am (by setting the
modulefs_DATA variable).

For MacOS X, the kext is listed under macos_PROGRAM, and the _sources_
are listed (instead of objects).  This all happens in autoMakefile.am
(and is ifdef'd protected for DARWIN only); it doesn't use anything in
Makefile.in.  The special flags needed for MacOS X module builds are
overridden for those builds by setting obdclass_CFLAGS (or whatever is
the appropriate name for the module you're building).

This feels ... inelegant to me.  For one, if new source code files are added,
you have to add them two places (this bit me a number of times).  And it's
a lot of extra work to support different OS's.

Now I inherited this build system and it was 90% of the way there, so I
can't complain about it that much.  But I think we could do better.

What do people think about what this current mess?  Should it be normalized?
What's the right way to clean this up?  If it's to support module building
similar to the way Linux kernel modules are declared in the
Makefile/autoMakefile, then I'm okay with that.

--Ken
