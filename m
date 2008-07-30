From: Andreas Dilger <adilger@Sun.COM>
Date: Wed, 30 Jul 2008 15:19:26 -0600
Subject: [Lustre-devel] Lustre version patchless kernel?
In-Reply-To: <93703EDD1F125544A59BD25384B175621F5A36DCF0@G1W0485.americas.hpqcorp.net>
References: <488DD7C1.7010807@hp.com> <488DD9D0.5080902@hp.com>
	<20080730093550.GS3342@webber.adilger.int>
	<93703EDD1F125544A59BD25384B175621F5A36DCF0@G1W0485.americas.hpqcorp.net>
Message-ID: <20080730211926.GA3342@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jul 30, 2008  15:52 +0000, Kossey, Robert wrote:
> Thanks for the explanation.  I actually sent my response, and created
> bug 16516, before you sent your response, but my posting was delayed
> by the list moderator since I am not a list subscriber.  I modifed the
> bug to request that the wording of the program output be changed to
> something like:
>
> kernel: no VFS patches
> 
> This could reduce the confusion that Brian and I and probably others
> would have with the current wording.

Yes, the wording will be changed to "kernel: patchless client", because
several of the regression tests depend on "patchless" being there.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
