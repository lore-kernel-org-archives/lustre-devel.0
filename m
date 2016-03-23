From: Joe Perches <joe@perches.com>
Date: Wed, 23 Mar 2016 11:47:44 -0700
Subject: [lustre-devel] [PATCH] Revert "Staging: lustre: o2iblnd: Use
 sizeof type *pointer instead of sizeof type."
In-Reply-To: <bb9ab572a3944b38814b0533323e0299@EXCHCS32.ornl.gov>
References: <1458685264-22755-1-git-send-email-jsimmons@infradead.org>
	<20160323014916.GF3190@kroah.com>
	<D317846B.138487%andreas.dilger@intel.com>
	<20160323134107.GA4356@kroah.com>
	<bb9ab572a3944b38814b0533323e0299@EXCHCS32.ornl.gov>
Message-ID: <1458758864.18165.4.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Simmons, James A." <simmonsja@ornl.gov>, 'Greg Kroah-Hartman' <gregkh@linuxfoundation.org>, "Dilger, Andreas" <andreas.dilger@intel.com>
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Wed, 2016-03-23 at 18:31 +0000, Simmons, James A. wrote:
> > On Wed, Mar 23, 2016 at 05:39:36AM +0000, Dilger, Andreas wrote:
> > > On 2016/03/22, 19:49, "lustre-devel on behalf of Greg Kroah-Hartman"
> > > <lustre-devel-bounces@lists.lustre.org on behalf of
> > > gregkh at linuxfoundation.org> wrote:
> > > > On Tue, Mar 22, 2016 at 06:21:04PM -0400, James Simmons wrote:
> > > > > 
> > > > > Latest testing fails when using ko2iblnd. It was tracked down
> > > > > to commit 4671a026616df26000f7d8ad2f2ea4b6de79263c.
> > > > > 
> > > > > This reverts commit 4671a026616df26000f7d8ad2f2ea4b6de79263c.
[]
> > > > > diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
[]
> > > > > @@ -1968,7 +1968,7 @@ static int kiblnd_net_init_pools(kib_net_t *net,
> > > > > __u32 *cpts, int ncpts)
> > > > > ?	?*/
> > > > > ?
> > > > > ?	net->ibn_fmr_ps = cfs_percpt_alloc(lnet_cpt_table(),
> > > > > -					???sizeof(*net->ibn_fmr_ps));
> > > > > +					???sizeof(kib_fmr_poolset_t));
> > > > Ok, why is this revert needed???Please give me a big huge comment about
> > > > why this is not the same size of the variable being assigned to it,
> > > > otherwise someone else is going to come along and make the exact same
> > > > change again.
[]
> > > Looks like the declarations are:
> > > 
> > > ????????kib_tx_poolset_t	**ibn_tx_ps;	/* tx pool-set */
> > > 	kib_fmr_poolset_t	**ibn_fmr_ps;	/* fmr pool-set */
[]
> > > so the right code should be:
> > > 
> > > ????????sizeof(**net->ibn_tx_ps);
> > > and the same for sizeof(**net->ibn_fmr_ps)
> > That's a mess, isn't there some other way to fix this up to be more
> > "obvious"?
> This must have been encountered in the past. How was it handle in those
> other cases?

I fail to see why it's a mess.  It's just **
and someone making a mistake.

Removing the "typedef struct" uses from lustre
would probably make a lot of this clearer though.

$ git grep -En "typedef\s+struct" drivers/staging/lustre/
drivers/staging/lustre/include/linux/libcfs/libcfs_workitem.h:76:typedef struct cfs_workitem {
drivers/staging/lustre/include/linux/lnet/lib-types.h:56:typedef struct lnet_msg {
drivers/staging/lustre/include/linux/lnet/lib-types.h:110:typedef struct lnet_libhandle {
drivers/staging/lustre/include/linux/lnet/lib-types.h:118:typedef struct lnet_eq {
drivers/staging/lustre/include/linux/lnet/lib-types.h:129:typedef struct lnet_me {
drivers/staging/lustre/include/linux/lnet/lib-types.h:141:typedef struct lnet_libmd {
drivers/staging/lustre/include/linux/lnet/lib-types.h:166:typedef struct {
drivers/staging/lustre/include/linux/lnet/lib-types.h:181:typedef struct lnet_lnd {
drivers/staging/lustre/include/linux/lnet/lib-types.h:256:typedef struct lnet_ni {
drivers/staging/lustre/include/linux/lnet/lib-types.h:297:typedef struct {
drivers/staging/lustre/include/linux/lnet/lib-types.h:305:typedef struct lnet_peer {
drivers/staging/lustre/include/linux/lnet/lib-types.h:369:typedef struct {
drivers/staging/lustre/include/linux/lnet/lib-types.h:384:typedef struct {
drivers/staging/lustre/include/linux/lnet/lib-types.h:396:typedef struct {
drivers/staging/lustre/include/linux/lnet/lib-types.h:410:typedef struct {
drivers/staging/lustre/include/linux/lnet/lib-types.h:497:typedef struct lnet_portal {
drivers/staging/lustre/include/linux/lnet/lib-types.h:545:typedef struct {
drivers/staging/lustre/include/linux/lnet/lnetst.h:71:typedef struct {
drivers/staging/lustre/include/linux/lnet/lnetst.h:78:typedef struct {
drivers/staging/lustre/include/linux/lnet/lnetst.h:88:typedef struct {
drivers/staging/lustre/include/linux/lnet/lnetst.h:93:typedef struct {
drivers/staging/lustre/include/linux/lnet/lnetst.h:101:typedef struct {
drivers/staging/lustre/include/linux/lnet/lnetst.h:108:typedef struct {
drivers/staging/lustre/include/linux/lnet/lnetst.h:115:typedef struct {
drivers/staging/lustre/include/linux/lnet/lnetst.h:127:typedef struct {
drivers/staging/lustre/include/linux/lnet/lnetst.h:140:typedef struct {
drivers/staging/lustre/include/linux/lnet/lnetst.h:242:typedef struct {
drivers/staging/lustre/include/linux/lnet/lnetst.h:254:typedef struct {
drivers/staging/lustre/include/linux/lnet/lnetst.h:265:typedef struct {
drivers/staging/lustre/include/linux/lnet/lnetst.h:275:typedef struct {
drivers/staging/lustre/include/linux/lnet/lnetst.h:296:typedef struct {
drivers/staging/lustre/include/linux/lnet/lnetst.h:302:typedef struct {
drivers/staging/lustre/include/linux/lnet/lnetst.h:313:typedef struct {
drivers/staging/lustre/include/linux/lnet/lnetst.h:325:typedef struct {
drivers/staging/lustre/include/linux/lnet/lnetst.h:337:typedef struct {
drivers/staging/lustre/include/linux/lnet/lnetst.h:344:typedef struct {
drivers/staging/lustre/include/linux/lnet/lnetst.h:357:typedef struct {
drivers/staging/lustre/include/linux/lnet/lnetst.h:363:typedef struct {
drivers/staging/lustre/include/linux/lnet/lnetst.h:369:typedef struct {
drivers/staging/lustre/include/linux/lnet/lnetst.h:379:typedef struct {
drivers/staging/lustre/include/linux/lnet/lnetst.h:389:typedef struct {
drivers/staging/lustre/include/linux/lnet/lnetst.h:402:typedef struct {
