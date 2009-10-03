From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Fri, 02 Oct 2009 17:36:11 -0700
Subject: [Lustre-devel] Lustre version number and rpm "Release"
In-Reply-To: <1254491700.26203.251.camel@pc.interlinx.bc.ca>
References: <4AC56205.5060403@llnl.gov>
	<1254491700.26203.251.camel@pc.interlinx.bc.ca>
Message-ID: <4AC69C7B.2020201@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Brian J. Murrell wrote:

>> $ rpm -qpi lustre-1.8.1.50-2.6.18_70chaos_200910011803.x86_64.rpm
>> Name        : lustre                       Relocations: (not relocatable)
>> Version     : 1.8.1.50                          Vendor: (none)
>> Release     : 2.6.18_70chaos_200910011803   Build Date: Thu Oct  1
> 
> Then presumably the kernel you built against is 2.6.18_70chaos.  Is that
> correct?

That is correct.

> %{!?release: %define release @RELEASE@}
> 
> That means you can define Release for your rpm build on the command line
> with:
> 
> $ rpmbuild --define 'release whatever_you_want' ... lustre.spec

Well, that is true, except that we just want to prefix the release, not
replace it.  If we replace it with our own definition, we have to repeat
the kernel detection, and timestamp part.  So really, we'll want an
additional "release_prefix" rpm variable.

There is an additional wrinkle that I didn't mention.  Our automated
build system is designed to take source rpms and build the binary rpms
from that.  If we just set "release" at source rpm build time, I don't
think that it will be remember later when the binary rpms are built.

Part of the reason that our build farm works that way is that we would
like other users of our linux distribution to be able to easily rebuild
lustre (and any other kernel modules) from the source rpm.

In the end though, it looks like the most reasonable way to handle this
is to have our own spec file for the chaos linux distribution.

Chris
