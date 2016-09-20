From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 20 Sep 2016 13:05:00 +0200
Subject: [lustre-devel] [PATCH] staging: lustre: ptlrpc: re-export
 lustre_swab_[lmv|lov]_mds_md
In-Reply-To: <20160920085134.GH13620@mwanda>
References: <1474306025-1942-1-git-send-email-jsimmons@infradead.org>
	<20160920064702.GB8527@kroah.com> <20160920085134.GH13620@mwanda>
Message-ID: <20160920110500.GB16639@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: James Simmons <jsimmons@infradead.org>, devel@driverdev.osuosl.org, James Simmons <uja.ornl@yahoo.com>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Tue, Sep 20, 2016 at 11:52:19AM +0300, Dan Carpenter wrote:
> On Tue, Sep 20, 2016 at 08:47:02AM +0200, Greg Kroah-Hartman wrote:
> > On Mon, Sep 19, 2016 at 01:27:05PM -0400, James Simmons wrote:
> > > Being over zealous in removing unused EXPORT_SYMBOLs two functions
> > > lustre_swab_[lmv|lov]_mds_md exports were removed. They need to be
> > > exported so this patch restores those EXPORT_SYMBOLS. Same mistake
> > > was done when porting to the upstream client.
> > 
> > How did our build testing not catch this?  What needs these exports?  Is
> > it any in-kernel code?
> > 
> > confused,
> 
> It did catch it...

It did?  Works here for me, and I didn't see an error report anywhere...

> James, every patch has to be buildable (bisectable) so the original
> patch is never going to be merged.

What is the "original" patch here?

totally confused,

greg k-h
