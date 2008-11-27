From: Andreas Dilger <adilger@sun.com>
Date: Thu, 27 Nov 2008 01:51:52 -0700
Subject: [Lustre-devel] sparse files
In-Reply-To: <004701c94fdf$f4255b40$dc7011c0$@com>
References: <004701c94fdf$f4255b40$dc7011c0$@com>
Message-ID: <20081127085152.GA3186@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Nov 26, 2008  15:59 +0000, Eric Barton wrote:
> Question for the HSM team.
> 
> Do we need to make the allocation map of a lustre file available
> to the HSM agent so it can avoid copying all the holes in sparse
> files?

There is already an ioctl for this supported by Lustre and ldiskfs
that will allow dumping the extent maps if the HSM so chooses.  This
ioctl is also supported in the upstream Linux kernels, so it will
be possible to have generic tools take advantage of it as well.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
