From: James Simmons <jsimmons@infradead.org>
Date: Sun, 29 Jul 2018 18:31:35 +0100 (BST)
Subject: [lustre-devel] [PATCH 9/9] lustre: lnet: discard LNET_LOCK()
In-Reply-To: <153232698505.26222.7268545921228126117.stgit@noble>
References: <153232696720.26222.9658151633697867322.stgit@noble>
 <153232698505.26222.7268545921228126117.stgit@noble>
Message-ID: <alpine.LFD.2.21.1807291831260.2402@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> This macro, and LNET_UNLOCK() are rarely used, don't
> add clarify, and make greping for lock usage harder.
> So discard macro and just the lnet_net_{un,}lock()
> like everyone else.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/include/linux/lnet/lib-lnet.h   |    3 ---
>  .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |    8 ++++----
>  drivers/staging/lustre/lnet/selftest/rpc.c         |    2 +-
>  3 files changed, 5 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> index 6b6289cfcd3d..8ff8139e04fe 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> @@ -177,9 +177,6 @@ lnet_net_lock_current(void)
>  	return cpt;
>  }
>  
> -#define LNET_LOCK()		lnet_net_lock(LNET_LOCK_EX)
> -#define LNET_UNLOCK()		lnet_net_unlock(LNET_LOCK_EX)
> -
>  #define lnet_ptl_lock(ptl)	spin_lock(&(ptl)->ptl_lock)
>  #define lnet_ptl_unlock(ptl)	spin_unlock(&(ptl)->ptl_lock)
>  #define lnet_eq_wait_lock()	spin_lock(&the_lnet.ln_eq_wait_lock)
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
> index 05982dac781c..aaa04a5f0527 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
> @@ -485,7 +485,7 @@ ksocknal_send_hello_v1(struct ksock_conn *conn, struct ksock_hello_msg *hello)
>  
>  	if (the_lnet.ln_testprotocompat) {
>  		/* single-shot proto check */
> -		LNET_LOCK();
> +		lnet_net_lock(LNET_LOCK_EX);
>  		if (the_lnet.ln_testprotocompat & 1) {
>  			hmv->version_major++;   /* just different! */
>  			the_lnet.ln_testprotocompat &= ~1;
> @@ -494,7 +494,7 @@ ksocknal_send_hello_v1(struct ksock_conn *conn, struct ksock_hello_msg *hello)
>  			hmv->magic = LNET_PROTO_MAGIC;
>  			the_lnet.ln_testprotocompat &= ~2;
>  		}
> -		LNET_UNLOCK();
> +		lnet_net_unlock(LNET_LOCK_EX);
>  	}
>  
>  	hdr->src_nid = cpu_to_le64(hello->kshm_src_nid);
> @@ -542,12 +542,12 @@ ksocknal_send_hello_v2(struct ksock_conn *conn, struct ksock_hello_msg *hello)
>  
>  	if (the_lnet.ln_testprotocompat) {
>  		/* single-shot proto check */
> -		LNET_LOCK();
> +		lnet_net_lock(LNET_LOCK_EX);
>  		if (the_lnet.ln_testprotocompat & 1) {
>  			hello->kshm_version++;   /* just different! */
>  			the_lnet.ln_testprotocompat &= ~1;
>  		}
> -		LNET_UNLOCK();
> +		lnet_net_unlock(LNET_LOCK_EX);
>  	}
>  
>  	rc = lnet_sock_write(sock, hello, offsetof(struct ksock_hello_msg, kshm_ips),
> diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
> index 9613b0a77007..e097ef8414a6 100644
> --- a/drivers/staging/lustre/lnet/selftest/rpc.c
> +++ b/drivers/staging/lustre/lnet/selftest/rpc.c
> @@ -1399,7 +1399,7 @@ srpc_send_reply(struct srpc_server_rpc *rpc)
>  	return rc;
>  }
>  
> -/* when in kernel always called with LNET_LOCK() held, and in thread context */
> +/* when in kernel always called with lnet_net_lock() held, and in thread context */
>  static void
>  srpc_lnet_ev_handler(struct lnet_event *ev)
>  {
> 
> 
> 
