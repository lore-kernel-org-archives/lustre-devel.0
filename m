From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Thu, 8 Mar 2018 00:20:00 +0000
Subject: [lustre-devel] [PATCH 07/17] staging: lustre: ptlrpc: change
 GFP_NOFS to GFP_KERNEL
In-Reply-To: <151994708527.7628.4121961365281382022.stgit@noble>
References: <151994679573.7628.1024109499321778846.stgit@noble>
 <151994708527.7628.4121961365281382022.stgit@noble>
Message-ID: <D522B515-A92B-4169-9B98-31F99ABF1D49@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Linux
 Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mar 1, 2018, at 16:31, NeilBrown <neilb@suse.com> wrote:
> 
> These allocations are performed during initialization,
> so they don't need GFP_NOFS.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> ---
> drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c |    2 +-
> drivers/staging/lustre/lustre/ptlrpc/service.c  |    4 ++--
> 2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
> index 577c5822b823..625b9520d78f 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
> @@ -377,7 +377,7 @@ static inline void enc_pools_alloc(void)
> 	page_pools.epp_pools =
> 		kvzalloc(page_pools.epp_max_pools *
> 				sizeof(*page_pools.epp_pools),
> -				GFP_NOFS);
> +				GFP_KERNEL);
> }
> 
> static inline void enc_pools_free(void)
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
> index 49417228b621..f37364e00dfe 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/service.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
> @@ -2046,7 +2046,7 @@ static int ptlrpc_main(void *arg)
> 			goto out;
> 	}
> 
> -	env = kzalloc(sizeof(*env), GFP_NOFS);
> +	env = kzalloc(sizeof(*env), GFP_KERNEL);
> 	if (!env) {
> 		rc = -ENOMEM;
> 		goto out_srv_fini;
> @@ -2072,7 +2072,7 @@ static int ptlrpc_main(void *arg)
> 	}
> 
> 	/* Alloc reply state structure for this one */
> -	rs = kvzalloc(svc->srv_max_reply_size, GFP_NOFS);
> +	rs = kvzalloc(svc->srv_max_reply_size, GFP_KERNEL);
> 	if (!rs) {
> 		rc = -ENOMEM;
> 		goto out_srv_fini;
> 
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
