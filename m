From: James Simmons <jsimmons@infradead.org>
Date: Fri, 30 Mar 2018 19:57:08 +0100 (BST)
Subject: [lustre-devel] [PATCH 02/17] staging: lustre: remove unused
 ldlm_completion_ast_async()
In-Reply-To: <152229760829.27689.12680083968318847851.stgit@noble>
References: <152229732768.27689.4800156943561963977.stgit@noble>
 <152229760829.27689.12680083968318847851.stgit@noble>
Message-ID: <alpine.LFD.2.21.1803301957010.9681@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


> This function is unused.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/include/lustre_dlm.h |    1 -
>  drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   23 --------------------
>  2 files changed, 24 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
> index 239aa2b1268f..7407acf60cf8 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
> @@ -1227,7 +1227,6 @@ int ldlm_lock_change_resource(struct ldlm_namespace *, struct ldlm_lock *,
>   * processing.
>   * @{
>   */
> -int ldlm_completion_ast_async(struct ldlm_lock *lock, __u64 flags, void *data);
>  int ldlm_completion_ast(struct ldlm_lock *lock, __u64 flags, void *data);
>  /** @} ldlm_local_ast */
>  
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
> index c3c9186b74ce..be43958e4090 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
> @@ -191,29 +191,6 @@ static int ldlm_completion_tail(struct ldlm_lock *lock, void *data)
>  	return result;
>  }
>  
> -/**
> - * Implementation of ->l_completion_ast() for a client, that doesn't wait
> - * until lock is granted. Suitable for locks enqueued through ptlrpcd, of
> - * other threads that cannot block for long.
> - */
> -int ldlm_completion_ast_async(struct ldlm_lock *lock, __u64 flags, void *data)
> -{
> -	if (flags == LDLM_FL_WAIT_NOREPROC) {
> -		LDLM_DEBUG(lock, "client-side enqueue waiting on pending lock");
> -		return 0;
> -	}
> -
> -	if (!(flags & LDLM_FL_BLOCKED_MASK)) {
> -		wake_up(&lock->l_waitq);
> -		return ldlm_completion_tail(lock, data);
> -	}
> -
> -	LDLM_DEBUG(lock,
> -		   "client-side enqueue returned a blocked lock, going forward");
> -	return 0;
> -}
> -EXPORT_SYMBOL(ldlm_completion_ast_async);
> -
>  /**
>   * Generic LDLM "completion" AST. This is called in several cases:
>   *
> 
> 
> 
