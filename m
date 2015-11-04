From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Wed, 4 Nov 2015 09:20:19 -0800
Subject: [lustre-devel] [PATCH v2 1/7] staging: lustre: remove white
 space in libcfs_hash.h
In-Reply-To: <12a3bc6fd3414ba5b4fac029749675db@EXCHCS32.ornl.gov>
References: <1446484933-23571-1-git-send-email-jsimmons@infradead.org>
	<1446484933-23571-2-git-send-email-jsimmons@infradead.org>
	<20151104034607.GA12870@kroah.com> <20151104114135.GB7587@sudip-pc>
	<12a3bc6fd3414ba5b4fac029749675db@EXCHCS32.ornl.gov>
Message-ID: <20151104172019.GB8504@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Nov 04, 2015 at 03:07:13PM +0000, Simmons, James A. wrote:
> >On Tue, Nov 03, 2015 at 07:46:07PM -0800, Greg Kroah-Hartman wrote:
> >> On Mon, Nov 02, 2015 at 12:22:07PM -0500, James Simmons wrote:
> >> > Cleanup all the unneeded white space in libcfs_hash.h.
> >> > 
> >> > Signed-off-by: James Simmons <jsimmons@infradead.org>
> >> > ---
> >> >  .../lustre/include/linux/libcfs/libcfs_hash.h      |  135 ++++++++++----------
> >> >  1 files changed, 70 insertions(+), 65 deletions(-)
> >> 
> >> Doesn't apply, did I already queue up this series?
> >
> >No. This did not apply because of:
> >c7fdf4a3959f ("staging: lustre: fix remaining checkpatch issues for libcfs_hash.h")
> 
> Surprise this was merged which is why I did a second series for this.

Oops, my mistake, I've now dropped this patch from my tree.  Please
resend this series so I can try to sync up properly.

thanks,

greg k-h
