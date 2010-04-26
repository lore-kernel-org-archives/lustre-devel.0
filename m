From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Mon, 26 Apr 2010 17:20:39 -0600
Subject: [Lustre-devel] Build system and portability
In-Reply-To: <1272316096.19510.146.camel@pc.interlinx.bc.ca>
References: <201004261815.o3QIFW55029195@hedwig.cmf.nrl.navy.mil>
	<1272316096.19510.146.camel@pc.interlinx.bc.ca>
Message-ID: <0C946F67-6483-4781-ADB6-465F25D3B828@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2010-04-26, at 15:08, Brian J. Murrell wrote:
> On Mon, 2010-04-26 at 14:15 -0400, Ken Hornstein wrote: 
>> it's really more a bunch of
>> portability cleanup issues.
> 
> Indeed.  More or less what I was saying.
> 
>> Like not doing Linux kernel feature tests on non-Linux systems,
> 
> Right.  The closer you look, you will notice there is an intention to
> group macros that are O/S specific into their own files and macro
> calling groups, but I would not at all be surprised to learn that there
> is some (or even a lot of) leakage, as the reality is that we don't
> really build on anything but Linux at this time and therefore we don't
> really have an opportunity to catch that leakage.

Exactly what I was going to say.  I don't think there is any reason we would want to do it in a bad way, just that people weren't thinking of cross-platform portability when they added some check, and didn't put it in the right file at the time.

> I suspect as we get deeper into Solaris, a lot of this will get weeded
> out.  Or as you contribute your patches, equally so.

I'm happy to see them as soon as they are ready (which seems to be on the client for MacOS, and is being done on the server for Solaris).  No point in duplicating effort.

>> I would just be
>> happy if we could get down to one Makefile; is that possible, given the
>> way that Linux kernel module builds work?
> 
> Hrm.  Just given the existing relationship between Makefiles, the Rules
> file and autoMakefiles, it seems probably not, without a lot of
> duplication (and the ongoing maintenance nightmare) throughout
> Makefiles.  I am happy to be proven wrong though.
> 
> I think the problem is that ultimately the code that is in the tree
> needs to build for multiple platforms, including both traditional (Linux
> kernel) lustre and liblustre.  So it's not just a case of separate bits
> of code exclusive to the linux kernel and other separate bits exclusive
> to userspace, but that a large part of the code that can be built into
> linux modules (with it's particular Makefile requirements) is also used
> to build liblustre.

Actually, if we could get liblustre to become "just another client arch" (like MacOS and WinNT) I think it would do wonders for the portability as well.  As it stands today, liblustre is kind of a mismash of Linux emulation and its own thing.

> I would think that MacOS/X has it's own kernel module build sequences
> such that the Makefiles that are engineered for the Linux kernel build
> tree are not suitable.  Or are the Linux module Makefiles also working
> for the MacOS/X kernel?  That would add a third variant, I guess.  I
> know zilch about building MacOS/X modules, so I can't really judge.

I suspect that we might be able to get something like a "Makefile fragment" that is containing all of the build targets, that is included in an arch-specific top-level Makefile to specify exactly how those files will be built.  Sadly, I don't know anything about this area.

>> Oh, as long as we're on the subject ... when I file portability bugs
>> using bugzilla, I am never happy with the component I have to pick to
>> file the bug under (I end up with something like "integration").  Can
>> we get a Bugzilla component titled "portability"?  Or if people are
>> happy with "integration" (or would rather I use something else), I
>> guess that's okay as well.
> 
> Well, do as well as you can with the component, but indeed, there are a
> lot of cases that are simply not a clear case of choosing one of those
> components so choose something "close".  For this sort of Makefile stuff
> you are doing, I think there is a component for "build system" or some
> such.  That would likely be appropriate.


The intention of "component" is e.g. "what part of the code the defect is in (e.g. client, server, quota, etc).  I'd think most of your problems are in "Build/Release Engineering" and "OS X", though some will be "llite/mdc", "llite/vfs", and "IO/llite/lov/osc".

In this light, it would be interesting to know whether you were able to re-use parts of the lustre/llite code (e.g. llite_lib.c) and it should be moved into a shared directory like lustre/lclient (which is supposed to be entirely portable).  Spending some time to incrementally move (and get upstream) parts of the llite code that are portable between linux and macos would ensure that the ongoing maintenance is reduced.  The problem with making too many changes in a port and not returning them upstream is that eventually the code diverges so much that the ongoing 

Cheers, Andreas
--
Andreas Dilger
Lustre Technical Lead
Oracle Corporation Canada Inc.
