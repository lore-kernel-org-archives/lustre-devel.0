From: Brian J. Murrell <Brian.Murrell@Oracle.COM>
Date: Mon, 26 Apr 2010 09:56:07 -0400
Subject: [Lustre-devel] Build system and portability
In-Reply-To: <201004252333.o3PNWxxw019025@hedwig.cmf.nrl.navy.mil>
References: <201004252333.o3PNWxxw019025@hedwig.cmf.nrl.navy.mil>
Message-ID: <1272290167.19510.102.camel@pc.interlinx.bc.ca>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, 2010-04-25 at 19:32 -0400, Ken Hornstein wrote: 
> 
> I think it's obvious that the autoconf system needs some work as well;
> no one disagrees, do they?

The autoconf portion is not terribly bad, I think.  It could probably
use a bit of macro reorganization, and some more reasonable defaults for
things like kernel, etc. but I am working on the latter currently.  It
seemed a real mess to me at first, but the more I worked with it, the
more I understood the organization of it.

> I guess the first thing that comes to mind is ... what's the deal with
> Makefile.in and autoMakefile.am?  Why not just one Makefile.am?

I have not really delved terribly deeply into the organization of an
external (linux) kernel module source tree, but I am at least familiar
with it.

My (self-attained, admittedly, so take it with a grain of salt)
understanding of the reason for both Makefiles and autoMakefiles is that
the Makefiles are what the kernel build system uses to build the kernel
modules portion of lustre and the autoMakefiles are for everything else.

Why we cannot/didn't just put the modules into it's own tree with kernel
build system Makefiles and keep everything in a separate tree with their
own non-kernel build system Makefiles... I am not sure, but as Andreas
mentioned, is likely just due to the history and the baggage that has
not been shed when support for historical systems was dropped.

b.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: not available
Type: application/pgp-signature
Size: 197 bytes
Desc: This is a digitally signed message part
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20100426/82b83503/attachment.pgp>
