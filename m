From: Kossey, Robert <bob.kossey@hp.com>
Date: Wed, 30 Jul 2008 15:52:26 +0000
Subject: [Lustre-devel] Lustre version patchless kernel?
In-Reply-To: <20080730093550.GS3342@webber.adilger.int>
References: <488DD7C1.7010807@hp.com> <488DD9D0.5080902@hp.com>
	<20080730093550.GS3342@webber.adilger.int>
Message-ID: <93703EDD1F125544A59BD25384B175621F5A36DCF0@G1W0485.americas.hpqcorp.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Andreas,

Thanks for the explanation.  I actually sent my response, and created bug 16516, before you sent your response, but my posting was delayed by the list moderator since I am not a list subscriber.  I modifed the bug to request that the wording of the program output be changed to something like:

kernel: no VFS patches

This could reduce the confusion that Brian and I and probably others would have with the current wording.

Thanks,
Bob

> -----Original Message-----
> From: Andreas.Dilger at sun.com [mailto:Andreas.Dilger at sun.com]
> On Behalf Of Andreas Dilger
> Sent: Wednesday, July 30, 2008 5:36 AM
> To: Kossey, Robert
> Cc: lustre-devel at lists.lustre.org
> Subject: Re: [Lustre-devel] Lustre version patchless kernel?
>
> On Jul 28, 2008  10:38 -0400, Kossey, Robert wrote:
> > Yes, we see patchless reported on our RHEL5U1 Opteron servers with
> > 1.6.5.1and 1.6.4.3:
> >
> > In  both cases, these nodes are running kernels from the
> > kernel-lustre-smp RPMs downloaded from the Sun Lustre site. I don't
> > see a bug reported for this, so I will submit one.
>
> You missed my reply.  This is normal, please do not file a bug.
>
> Cheers, Andreas
> --
> Andreas Dilger
> Sr. Staff Engineer, Lustre Group
> Sun Microsystems of Canada, Inc.
>
>
