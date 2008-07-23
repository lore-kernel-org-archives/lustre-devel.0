From: Andreas Dilger <adilger@sun.com>
Date: Tue, 22 Jul 2008 19:20:28 -0600
Subject: [Lustre-devel] Lustre version patchless kernel?
In-Reply-To: <Pine.LNX.4.64.0807222059350.7033@pscuxa.psc.edu>
References: <4884A4BA.3010409@Sun.COM> <4884F19F.40604@Sun.COM>
	<Pine.LNX.4.64.0807222059350.7033@pscuxa.psc.edu>
Message-ID: <20080723012028.GC20749@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jul 22, 2008  21:02 -0400, Josephine Palencia wrote:
> 
> For the lustre version, the kernel portion indicates patchless...
> Should it be something else?
> 
> [root at operon22 lustre]# more /proc/fs/lustre/version
> > lustre: 1.9.50
> > kernel: patchless
> > build:  1.9.50-19691231190000-PRISTINE-.extra.linux-2.6.18-92.1.6-2.6.18-92.1.6-lustre-1.9.50

This is correct.  For patched kernels there will be a version number here,
indicating the VFS patch API version number.  This hasn't changed in a
long time because we are no longer changing the kernel VFS patches, and
only a few older kernels still need them.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
