From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 3 Apr 2019 20:26:12 +0000
Subject: [lustre-devel] [PATCH 23/32] lustre: ptlrpc: make
 ptlrpc_last_xid an atomic64_t
In-Reply-To: <155252231106.26912.1651233909473573691.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
 <155252231106.26912.1651233909473573691.stgit@noble.brown>
Message-ID: <D98CA13E-14C3-4EA4-A7D0-F632C52858F3@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mar 13, 2019, at 18:11, NeilBrown <neilb@suse.com> wrote:
> 
> This variable is treated like ant atomic64_t,
> so change it's type and simplify the code.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

I can't comment on all the LNet changes, but this looks reasonable.

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>

> ---
> drivers/staging/lustre/lustre/ptlrpc/client.c |   39 ++++++-------------------
> 1 file changed, 10 insertions(+), 29 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
> index 2514a142e799..ddf44c854200 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/client.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
> @@ -2999,8 +2999,7 @@ void ptlrpc_abort_set(struct ptlrpc_request_set *set)
> 	}
> }
> 
> -static u64 ptlrpc_last_xid;
> -static spinlock_t ptlrpc_last_xid_lock;
> +static atomic64_t ptlrpc_last_xid;
> 
> /**
>  * Initialize the XID for the node.  This is common among all requests on
> @@ -3021,19 +3020,20 @@ static spinlock_t ptlrpc_last_xid_lock;
> void ptlrpc_init_xid(void)
> {
> 	time64_t now = ktime_get_real_seconds();
> +	u64 xid;
> 
> -	spin_lock_init(&ptlrpc_last_xid_lock);
> 	if (now < YEAR_2004) {
> -		get_random_bytes(&ptlrpc_last_xid, sizeof(ptlrpc_last_xid));
> -		ptlrpc_last_xid >>= 2;
> -		ptlrpc_last_xid |= (1ULL << 61);
> +		get_random_bytes(&xid, sizeof(xid));
> +		xid >>= 2;
> +		xid |= (1ULL << 61);
> 	} else {
> -		ptlrpc_last_xid = (u64)now << 20;
> +		xid = (u64)now << 20;
> 	}
> 
> 	/* Always need to be aligned to a power-of-two for multi-bulk BRW */
> 	BUILD_BUG_ON(((PTLRPC_BULK_OPS_COUNT - 1) & PTLRPC_BULK_OPS_COUNT) != 0);
> -	ptlrpc_last_xid &= PTLRPC_BULK_OPS_MASK;
> +	xid &= PTLRPC_BULK_OPS_MASK;
> +	atomic64_set(&ptlrpc_last_xid, xid);
> }
> 
> /**
> @@ -3050,14 +3050,7 @@ void ptlrpc_init_xid(void)
>  */
> u64 ptlrpc_next_xid(void)
> {
> -	u64 next;
> -
> -	spin_lock(&ptlrpc_last_xid_lock);
> -	next = ptlrpc_last_xid + PTLRPC_BULK_OPS_COUNT;
> -	ptlrpc_last_xid = next;
> -	spin_unlock(&ptlrpc_last_xid_lock);
> -
> -	return next;
> +	return atomic64_add_return(PTLRPC_BULK_OPS_COUNT, &ptlrpc_last_xid);
> }
> 
> /**
> @@ -3131,19 +3124,7 @@ void ptlrpc_set_bulk_mbits(struct ptlrpc_request *req)
>  */
> u64 ptlrpc_sample_next_xid(void)
> {
> -#if BITS_PER_LONG == 32
> -	/* need to avoid possible word tearing on 32-bit systems */
> -	u64 next;
> -
> -	spin_lock(&ptlrpc_last_xid_lock);
> -	next = ptlrpc_last_xid + PTLRPC_BULK_OPS_COUNT;
> -	spin_unlock(&ptlrpc_last_xid_lock);
> -
> -	return next;
> -#else
> -	/* No need to lock, since returned value is racy anyways */
> -	return ptlrpc_last_xid + PTLRPC_BULK_OPS_COUNT;
> -#endif
> +	return atomic64_read(&ptlrpc_last_xid) + PTLRPC_BULK_OPS_COUNT;
> }
> EXPORT_SYMBOL(ptlrpc_sample_next_xid);
> 
> 
> 

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
