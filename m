From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Sat, 24 Jun 2017 00:15:13 +0800
Subject: [lustre-devel] [PATCH 5/6] staging: lustre: lustre: several
 over 80 characters cleanups
In-Reply-To: <1497452481-31124-6-git-send-email-jsimmons@infradead.org>
References: <1497452481-31124-1-git-send-email-jsimmons@infradead.org>
	<1497452481-31124-6-git-send-email-jsimmons@infradead.org>
Message-ID: <20170623161513.GB20104@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Wed, Jun 14, 2017 at 11:01:20AM -0400, James Simmons wrote:
> -void ldlm_extent_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
> -				      union ldlm_policy_data *lpolicy)
> +void
> +ldlm_extent_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
> +				 union ldlm_policy_data *lpolicy)

Stuff like this is not really needed.

But you could work on making your function names smaller and more
concise, that is one major reason why you have so many line-length
issues in your codebase.


> -	LDLM_LRU_FLAG_AGED	= BIT(0), /* Cancel aged locks (non lru resize). */
> +	LDLM_LRU_FLAG_AGED	= BIT(0), /* Cancel aged locks (non lru resize).
> +					   */

Not needed to be changed.

> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
> @@ -1035,7 +1035,8 @@ void ldlm_grant_lock(struct ldlm_lock *lock, struct list_head *work_list)
>  		ldlm_extent_add_lock(res, lock);
>  	else if (res->lr_type == LDLM_FLOCK) {
>  		/*
> -		 * We should not add locks to granted list in the following cases:
> +		 * We should not add locks to granted list in the following
> +		 * cases:

That's a good fix, as is:

>  		 * - this is an UNLOCK but not a real lock;
>  		 * - this is a TEST lock;
>  		 * - this is a F_CANCELLK lock (async flock has req_mode == 0)
> @@ -2050,13 +2051,16 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
>  		libcfs_debug_vmsg2(msgdata, fmt, args,
>  				   " ns: \?\? lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: \?\? rrc=\?\? type: \?\?\? flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lu lvb_type: %d\n",
>  				   lock,
> -				   lock->l_handle.h_cookie, atomic_read(&lock->l_refc),
> +				   lock->l_handle.h_cookie,
> +				   atomic_read(&lock->l_refc),

That one.

So do it where it maes the code better looking and easier to understand.
Not just where you have to work around crazy limitations.

Please fix this patch up and resend.

thanks,

greg k-h
