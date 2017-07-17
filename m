From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 17 Jul 2017 21:21:43 +0300
Subject: [lustre-devel] [PATCH v2 4/4] Staging: Lustre Fix block
	statement style issue
In-Reply-To: <20170717175017.GA32268@battlestar>
References: <cover.1499849566.git.Craig@craiginches.com>
	<774a2f25b839305f100e7fa99ebf835fb2ab7d44.1499849566.git.Craig@craiginches.com>
	<F6F7D587-CD46-40B8-A5B5-678B6A16AD8F@intel.com>
	<20170717175017.GA32268@battlestar>
Message-ID: <20170717182143.6xns7ncwdn2wqxyf@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Dilger, Andreas" <andreas.dilger@intel.com>, "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Jul 17, 2017 at 05:50:27PM +0000, Craig Inches wrote:
> On Mon, Jul 17, 2017 at 05:44:59PM +0000, Dilger, Andreas wrote:
> > On Jul 12, 2017, at 03:03, Craig Inches <craig@craiginches.com> wrote:
> > > 
> > > This fixes a block statement which didnt end with */
> > > 
> > > Signed-off-by: Craig Inches <Craig@craiginches.com>
> > > ---
> > > drivers/staging/lustre/include/linux/lnet/socklnd.h | 3 ++-
> > > 1 file changed, 2 insertions(+), 1 deletion(-)
> > > 
> > > diff --git a/drivers/staging/lustre/include/linux/lnet/socklnd.h b/drivers/staging/lustre/include/linux/lnet/socklnd.h
> > > index dd5bc0e46560..a1ae66ede7a8 100644
> > > --- a/drivers/staging/lustre/include/linux/lnet/socklnd.h
> > > +++ b/drivers/staging/lustre/include/linux/lnet/socklnd.h
> > > @@ -76,7 +76,8 @@ struct ksock_msg {
> > > 	__u64	ksm_zc_cookies[2];	/* Zero-Copy request/ACK cookie */
> > > 	union {
> > > 		struct ksock_lnet_msg lnetmsg; /* lnet message, it's empty if
> > > -					  * it's NOOP */
> > > +						* it's NOOP
> > > +						*/
> > 
> > Rather than making the multi-line comments even more space consuming (I'm not a big
> > fan of "*/ must be on a line by itself" since it wastes a lot of vertical space),
> > I'd prefer to just shorten the comment, if possible, like:
> > 
> > 		struct ksock_lnet_msg lnetmsg; /* lnet message, empty if NOOP */
> 
> That makes sense, I believe the series has already made it to
> staging-next, so not sure what the process would be to fix it up.

staging-next can't be rebased (barring something very drastic).  Send a
new patch based on what's been committed.

regards,
dan carpenter
