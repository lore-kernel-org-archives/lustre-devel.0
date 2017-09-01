From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Fri, 1 Sep 2017 20:13:18 +0000
Subject: [lustre-devel] [PATCH] lustre: ptlrpc: kfree used instead of
	kvfree
In-Reply-To: <20170831225516.41922-1-namit@vmware.com>
References: <20170831225516.41922-1-namit@vmware.com>
Message-ID: <23708A03-C3C1-4270-AB59-8E1A17FB6EBA@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Aug 31, 2017, at 16:55, Nadav Amit <namit@vmware.com> wrote:
> 
> rq_reqbuf is allocated using kvmalloc() but released in one occasion
> using kfree() instead of kvfree().
> 
> The issue was found using grep based on a similar bug.
> 
> Fixes: d7e09d0397e8 ("add Lustre file system client support")

It would appear that this bug was introduced by ee0ec1946ec2
"lustre: ptlrpc: Replace uses of OBD_{ALLOC,FREE}_LARGE", but
it looks like the problem predates this patch, since it was
originally using OBD_FREE() instead of OBD_FREE_LARGE() here
so the Coccinelle script wouldn't have caught the issue.

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> 
> Cc: Peng Tao <bergwolf@gmail.com>
> Cc: Oleg Drokin <oleg.drokin@intel.com>
> Cc: Andreas Dilger <andreas.dilger@intel.com>
> Cc: James Simmons <jsimmons@infradead.org>
> 
> Signed-off-by: Nadav Amit <namit@vmware.com>
> ---
> drivers/staging/lustre/lustre/ptlrpc/sec.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
> index 366f2ce20f5e..2f1c9e15f47c 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
> @@ -847,7 +847,7 @@ void sptlrpc_request_out_callback(struct ptlrpc_request *req)
> 	if (req->rq_pool || !req->rq_reqbuf)
> 		return;
> 
> -	kfree(req->rq_reqbuf);
> +	kvfree(req->rq_reqbuf);
> 	req->rq_reqbuf = NULL;
> 	req->rq_reqbuf_len = 0;
> }
> -- 
> 2.11.0
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
