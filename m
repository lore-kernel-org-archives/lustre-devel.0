From: Oleg Drokin <oleg.drokin@intel.com>
Date: Sun, 15 Jan 2017 22:33:47 -0500
Subject: [lustre-devel] [patch] staging: lustre: ptlrpc: silence a shift
	wrapping warning
In-Reply-To: <20170115081407.GA29823@mwanda>
References: <20170115081407.GA29823@mwanda>
Message-ID: <DB46033C-BD85-41DA-B9EF-EA02020BFF86@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Jan 15, 2017, at 3:14 AM, Dan Carpenter wrote:

> "svcpt->scp_hist_seq" is a u64 so static checkers complain that 1U
> should be 1ULL.  I looked at REQS_SEQ_SHIFT() a little and it seems to
> be capped by the number of CPUs online and the amount of memory, but I
> think it could go above 32 possibly.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>

> ---
> I have not tested this change.
> 
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c b/drivers/staging/lustre/lustre/ptlrpc/events.c
> index 49f3e63..ae1650d 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/events.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/events.c
> @@ -277,7 +277,7 @@ static void ptlrpc_req_add_history(struct ptlrpc_service_part *svcpt,
> 		 * then we hope there will be less RPCs per bucket at some
> 		 * point, and sequence will catch up again
> 		 */
> -		svcpt->scp_hist_seq += (1U << REQS_SEQ_SHIFT(svcpt));
> +		svcpt->scp_hist_seq += (1ULL << REQS_SEQ_SHIFT(svcpt));
> 		new_seq = svcpt->scp_hist_seq;
> 	}
> 
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
