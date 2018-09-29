From: James Simmons <jsimmons@infradead.org>
Date: Sat, 29 Sep 2018 22:11:37 +0100 (BST)
Subject: [lustre-devel] [PATCH 11/30] lustre: mdc: allow setting readdir
 RPC size parameter
In-Reply-To: <7503F4FB-D93E-4CD1-9DF3-C00C51528E93@whamcloud.com>
References: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
 <1537205440-6656-12-git-send-email-jsimmons@infradead.org>
 <8736u76j7g.fsf@notabene.neil.brown.name>
 <7503F4FB-D93E-4CD1-9DF3-C00C51528E93@whamcloud.com>
Message-ID: <alpine.LFD.2.21.1809292206330.25547@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> On Sep 18, 2018, at 09:14, NeilBrown <neilb@suse.com> wrote:
> > 
> > On Mon, Sep 17 2018, James Simmons wrote:
> > 
> >> From: Andreas Dilger <adilger@whamcloud.com>
> >> 
> >> diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
> >> index 2dbd208..cf630db 100644
> >> --- a/drivers/staging/lustre/lustre/include/lustre_net.h
> >> +++ b/drivers/staging/lustre/lustre/include/lustre_net.h
> >> @@ -104,15 +104,15 @@
> >>  * currently supported maximum between peers at connect via ocd_brw_size.
> >>  */
> >> #define PTLRPC_MAX_BRW_BITS	(LNET_MTU_BITS + PTLRPC_BULK_OPS_BITS)
> >> -#define PTLRPC_MAX_BRW_SIZE	(1 << PTLRPC_MAX_BRW_BITS)
> >> +#define PTLRPC_MAX_BRW_SIZE	BIT(PTLRPC_MAX_BRW_BITS)
> >> #define PTLRPC_MAX_BRW_PAGES	(PTLRPC_MAX_BRW_SIZE >> PAGE_SHIFT)
> >> 
> >> -#define ONE_MB_BRW_SIZE		(1 << LNET_MTU_BITS)
> >> -#define MD_MAX_BRW_SIZE		(1 << LNET_MTU_BITS)
> >> +#define ONE_MB_BRW_SIZE		BIT(LNET_MTU_BITS)
> >> +#define MD_MAX_BRW_SIZE		BIT(LNET_MTU_BITS)
> >> #define MD_MAX_BRW_PAGES	(MD_MAX_BRW_SIZE >> PAGE_SHIFT)
> >> #define DT_MAX_BRW_SIZE		PTLRPC_MAX_BRW_SIZE
> >> #define DT_MAX_BRW_PAGES	(DT_MAX_BRW_SIZE >> PAGE_SHIFT)
> >> -#define OFD_MAX_BRW_SIZE	(1 << LNET_MTU_BITS)
> >> +#define OFD_MAX_BRW_SIZE	BIT(LNET_MTU_BITS)
> > 
> > Argg!!  No!!  Names are important.
> > "SIZE" means the value is a size, a number.  The bit-representation is
> > largely irrelevant, it is the number that is important.
> > BIT(x) returns a single bit - lots of zeros and just one '1' bit.  This
> > is not a number, it is a bit pattern.
> > 
> > So settings FOO_SIZE to BIT(bar) is wrong.  It is a type error.  It uses
> > a bit pattern when a number is expected.  The C compiler won't notice, but I will.
> > 
> > When I apply this (which probably won't be until next week), I'll just
> > remove this section of the patch.
> 
> Just to confirm, my original patch didn't have these BIT() macros in it,
> and I agree with your statements, so I'm fine with you removing them again.

That was my attempting to handle a checkpatch complaint with this patch. I 
do see your point in this. Still I like to keep the checkpatch numbers 
down to to remove a potential barrier to the acceptance into the fs tree.
We could replace (1 << LNET_MTU_BITS) with LNET_MTU which is the same 
value. I will latter post a separate patch to fix those checkpatch issues
up. 
 
> >> diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
> >> index 6c9fe49..d3b0445 100644
> >> --- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
> >> +++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
> >> @@ -267,27 +267,22 @@ void cl_inode_fini(struct inode *inode)
> >> /**
> >>  * build inode number from passed @fid
> >>  */
> >> -__u64 cl_fid_build_ino(const struct lu_fid *fid, int api32)
> >> +u64 cl_fid_build_ino(const struct lu_fid *fid, int api32)
> >> {
> >> 	if (BITS_PER_LONG == 32 || api32)
> >> 		return fid_flatten32(fid);
> >> -	else
> >> -		return fid_flatten(fid);
> >> +
> >> +	return fid_flatten(fid);
> > 
> > I preferred that as it was - it makes the either/or nature more obvious.
> 
> Kernel style generally recommends no "else" after a return, and checkpatch.pl will complain in this case.
> 
> Cheers, Andreas
> ---
> Andreas Dilger
> Principal Lustre Architect
> Whamcloud
> 
> 
> 
> 
> 
> 
> 
> 
