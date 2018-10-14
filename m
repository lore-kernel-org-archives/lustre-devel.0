From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 20:39:14 +0100 (BST)
Subject: [lustre-devel] [PATCH 07/24] lustre: lnet: cleanup of
 lnet_peer_ni_addref/decref_locked()
In-Reply-To: <153895437782.16383.10279057472731467540.stgit@noble>
References: <153895417139.16383.3791701638653772865.stgit@noble>
 <153895437782.16383.10279057472731467540.stgit@noble>
Message-ID: <alpine.LFD.2.21.1810142038440.9543@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> From: Olaf Weber <olaf@sgi.com>
> 
> Address style issues in lnet_peer_ni_addref_locked() and
> lnet_peer_ni_decref_locked(). In the latter routine, replace
> a sequence of atomic_dec()/atomic_read() with atomic_dec_and_test().

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> WC-bug-id: https://jira.whamcloud.com/browse/LU-9480
> Signed-off-by: Olaf Weber <olaf@sgi.com>
> Reviewed-on: https://review.whamcloud.com/25777
> Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
> Reviewed-by: Amir Shehata <amir.shehata@intel.com>
> Tested-by: Amir Shehata <amir.shehata@intel.com>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/include/linux/lnet/lib-lnet.h   |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> index 2e2b5ed27116..f15f5c9c9a25 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> @@ -323,8 +323,7 @@ static inline void
>  lnet_peer_ni_decref_locked(struct lnet_peer_ni *lp)
>  {
>  	LASSERT(atomic_read(&lp->lpni_refcount) > 0);
> -	atomic_dec(&lp->lpni_refcount);
> -	if (atomic_read(&lp->lpni_refcount) == 0)
> +	if (atomic_dec_and_test(&lp->lpni_refcount))
>  		lnet_destroy_peer_ni_locked(lp);
>  }
>  
> 
> 
> 
