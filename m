From: James Simmons <jsimmons@infradead.org>
Date: Tue, 20 Sep 2016 16:32:37 +0100 (BST)
Subject: [lustre-devel] [PATCH] staging: lustre: ptlrpc: re-export
 lustre_swab_[lmv|lov]_mds_md
In-Reply-To: <20160920111612.GK13620@mwanda>
References: <1474306025-1942-1-git-send-email-jsimmons@infradead.org>
	<20160920064702.GB8527@kroah.com> <20160920085134.GH13620@mwanda>
	<20160920110500.GB16639@kroah.com> <20160920111612.GK13620@mwanda>
Message-ID: <alpine.LFD.2.20.1609201620430.3557@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, James Simmons <uja.ornl@yahoo.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>


> > On Tue, Sep 20, 2016 at 11:52:19AM +0300, Dan Carpenter wrote:
> > > On Tue, Sep 20, 2016 at 08:47:02AM +0200, Greg Kroah-Hartman wrote:
> > > > On Mon, Sep 19, 2016 at 01:27:05PM -0400, James Simmons wrote:
> > > > > Being over zealous in removing unused EXPORT_SYMBOLs two functions
> > > > > lustre_swab_[lmv|lov]_mds_md exports were removed. They need to be
> > > > > exported so this patch restores those EXPORT_SYMBOLS. Same mistake
> > > > > was done when porting to the upstream client.
> > > > 
> > > > How did our build testing not catch this?  What needs these exports?  Is
> > > > it any in-kernel code?
> > > > 
> > > > confused,
> > > 
> > > It did catch it...
> > 
> > It did?  Works here for me, and I didn't see an error report anywhere...
> > 
> > > James, every patch has to be buildable (bisectable) so the original
> > > patch is never going to be merged.
> > 
> > What is the "original" patch here?
> > 
> 
> [PATCH 112/124] staging: lustre: ptlrpc: remove unnecessary EXPORT_SYMBOL
> 
> kbuild responded to the email that it broke compilation on s360 but I
> don't think the breakage is arch specific?

But it is. The breakage appears on only a subset of platforms. All the 
patches I sent are tested on a real file system setup using our special
test suite. This was done on x86 hardware where the problem doesn't show
up. I guess I need to ask work for a non-x86 platform to test with :-)
