From: Ken Hornstein <kenh@cmf.nrl.navy.mil>
Date: Mon, 26 Apr 2010 20:50:15 -0400
Subject: [Lustre-devel] Build system and portability
In-Reply-To: <1272316096.19510.146.camel@pc.interlinx.bc.ca>
Message-ID: <201004270050.o3R0oGG0001302@hedwig.cmf.nrl.navy.mil>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>> I would just be
>> happy if we could get down to one Makefile; is that possible, given the
>> way that Linux kernel module builds work?
>
>Hrm.  Just given the existing relationship between Makefiles, the Rules
>file and autoMakefiles, it seems probably not, without a lot of
>duplication (and the ongoing maintenance nightmare) throughout
>Makefiles.  I am happy to be proven wrong though.

You mean, as opposed to the duplication and maintenance nightmare
that already exists? :-)

I guess my largest issue is that the files necessary to build a
kernel module have to be listed twice (one for the Linux kernel
module, once for the MacOS X kernel modules); that caused a ton of
issues that had to be tracked down and it was rather tedious.
If we could get rid of that, then I'd mostly be happy.

>I would think that MacOS/X has it's own kernel module build sequences
>such that the Makefiles that are engineered for the Linux kernel build
>tree are not suitable.  Or are the Linux module Makefiles also working
>for the MacOS/X kernel?  That would add a third variant, I guess.  I
>know zilch about building MacOS/X modules, so I can't really judge.

Heh, actually, the code mostly existed and was close to working
(well, other than plenty of files had been added in 5 years).  You
can see it in the autoMakefiles; look for ifdef DARWIN and you'll
see what I mean.

Kernel modules on MacOS X (assuming you're not using Xcode environment,
which I'm not) are built using the normal compilers and your own Makefiles;
they just have different flags for compilation and linking.  The MacOS X
kernel modules are built using relatively standard automake descriptions
(see macos_PROGRAM).

--Ken
