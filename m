From: Brian J. Murrell <Brian.Murrell@oracle.com>
Date: Mon, 26 Apr 2010 17:08:16 -0400
Subject: [Lustre-devel] Build system and portability
In-Reply-To: <201004261815.o3QIFW55029195@hedwig.cmf.nrl.navy.mil>
References: <201004261815.o3QIFW55029195@hedwig.cmf.nrl.navy.mil>
Message-ID: <1272316096.19510.146.camel@pc.interlinx.bc.ca>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, 2010-04-26 at 14:15 -0400, Ken Hornstein wrote: 
> 
> Forgive me for implying otherwise;

No worries.  I totally understand where you are at with all of that.

> it's really more a bunch of
> portability cleanup issues.

Indeed.  More or less what I was saying.

> Like not doing Linux kernel feature tests
> on non-Linux systems,

Right.  The closer you look, you will notice there is an intention to
group macros that are O/S specific into their own files and macro
calling groups, but I would not at all be surprised to learn that there
is some (or even a lot of) leakage, as the reality is that we don't
really build on anything but Linux at this time and therefore we don't
really have an opportunity to catch that leakage.

I suspect as we get deeper into Solaris, a lot of this will get weeded
out.  Or as you contribute your patches, equally so.

> Again, I'm not the expert on how kernel module building works ...

Me neither.  :-)  I have a basic understanding, but that's it.

> but
> there seems to be some interdependency in the current Lustre setup (the
> Makefiles include Rules, which includes autoMakefile).

Yes, indeed.

> I would just be
> happy if we could get down to one Makefile; is that possible, given the
> way that Linux kernel module builds work?

Hrm.  Just given the existing relationship between Makefiles, the Rules
file and autoMakefiles, it seems probably not, without a lot of
duplication (and the ongoing maintenance nightmare) throughout
Makefiles.  I am happy to be proven wrong though.

I think the problem is that ultimately the code that is in the tree
needs to build for multiple platforms, including both traditional (Linux
kernel) lustre and liblustre.  So it's not just a case of separate bits
of code exclusive to the linux kernel and other separate bits exclusive
to userspace, but that a large part of the code that can be built into
linux modules (with it's particular Makefile requirements) is also used
to build liblustre.

I would think that MacOS/X has it's own kernel module build sequences
such that the Makefiles that are engineered for the Linux kernel build
tree are not suitable.  Or are the Linux module Makefiles also working
for the MacOS/X kernel?  That would add a third variant, I guess.  I
know zilch about building MacOS/X modules, so I can't really judge.

> Oh, as long as we're on the subject ... when I file portability bugs
> using bugzilla, I am never happy with the component I have to pick to
> file the bug under (I end up with something like "integration").  Can
> we get a Bugzilla component titled "portability"?  Or if people are
> happy with "integration" (or would rather I use something else), I
> guess that's okay as well.

Well, do as well as you can with the component, but indeed, there are a
lot of cases that are simply not a clear case of choosing one of those
components so choose something "close".  For this sort of Makefile stuff
you are doing, I think there is a component for "build system" or some
such.  That would likely be appropriate.

b.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: not available
Type: application/pgp-signature
Size: 197 bytes
Desc: This is a digitally signed message part
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20100426/c877fb18/attachment.pgp>
