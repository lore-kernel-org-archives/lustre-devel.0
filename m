From: James Simmons <jsimmons@infradead.org>
Date: Thu, 8 Dec 2016 00:27:27 +0000 (GMT)
Subject: [lustre-devel] [PATCH 8/8] staging/lustre/ptlrpc: Move
 nrs_conf_fifo extern to a header
In-Reply-To: <1481150494-1853127-9-git-send-email-green@linuxhacker.ru>
References: <1481150494-1853127-1-git-send-email-green@linuxhacker.ru>
	<1481150494-1853127-9-git-send-email-green@linuxhacker.ru>
Message-ID: <alpine.LFD.2.20.1612080027191.14850@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

> This avoids having an extern definition in a C file which is bad,
> and also silences sparse complaint as well.
> 
> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>

Reviewed-by: James Simmons <jsimmons@infradead.org>

> ---
>  drivers/staging/lustre/lustre/ptlrpc/nrs.c             | 3 ---
>  drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h | 3 +++
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs.c b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
> index 7b6ffb1..ef19dbe 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/nrs.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
> @@ -1559,9 +1559,6 @@ int ptlrpc_nrs_policy_control(const struct ptlrpc_service *svc,
>  	return rc;
>  }
>  
> -/* ptlrpc/nrs_fifo.c */
> -extern struct ptlrpc_nrs_pol_conf nrs_conf_fifo;
> -
>  /**
>   * Adds all policies that ship with the ptlrpc module, to NRS core's list of
>   * policies \e nrs_core.nrs_policies.
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
> index e0f859c..8e6a805 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
> +++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
> @@ -226,6 +226,9 @@ struct ptlrpc_nrs_policy *nrs_request_policy(struct ptlrpc_nrs_request *nrq)
>   sizeof(NRS_LPROCFS_QUANTUM_NAME_REG __stringify(LPROCFS_NRS_QUANTUM_MAX) " "  \
>  	NRS_LPROCFS_QUANTUM_NAME_HP __stringify(LPROCFS_NRS_QUANTUM_MAX))
>  
> +/* ptlrpc/nrs_fifo.c */
> +extern struct ptlrpc_nrs_pol_conf nrs_conf_fifo;
> +
>  /* recovd_thread.c */
>  
>  int ptlrpc_expire_one_request(struct ptlrpc_request *req, int async_unlink);
> -- 
> 2.7.4
> 
> 
