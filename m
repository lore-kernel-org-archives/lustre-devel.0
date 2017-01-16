From: Oleg Drokin <oleg.drokin@intel.com>
Date: Mon, 16 Jan 2017 11:45:38 -0500
Subject: [lustre-devel] [PATCH v2] Style fixes
In-Reply-To: <20170113204834.4941-1-kedrot@gmail.com>
References: <20161226154339.8916-2-kedrot@gmail.com>
	<20170113204834.4941-1-kedrot@gmail.com>
Message-ID: <4B1BA531-56B4-4DF2-B1BD-D7BFD5DFACA7@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Guillermo O. Freschi" <kedrot@gmail.com>
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>


On Jan 13, 2017, at 3:48 PM, Guillermo O. Freschi wrote:

> Missing braces on `if` statement.
> 
> Signed-off-by: Guillermo O. Freschi <kedrot@gmail.com>
> 
> Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> ---
> drivers/staging/lustre/lustre/ldlm/ldlm_lock.c | 9 +++++----
> 1 file changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
> index f4cbc89b4f24..b66bc02646f1 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
> @@ -1024,11 +1024,11 @@ void ldlm_grant_lock(struct ldlm_lock *lock, struct list_head *work_list)
> 	if (work_list && lock->l_completion_ast)
> 		ldlm_add_ast_work_item(lock, NULL, work_list);
> 
> -	if (res->lr_type == LDLM_PLAIN || res->lr_type == LDLM_IBITS)
> +	if (res->lr_type == LDLM_PLAIN || res->lr_type == LDLM_IBITS) {
> 		ldlm_grant_lock_with_skiplist(lock);
> -	else if (res->lr_type == LDLM_EXTENT)
> +	} else if (res->lr_type == LDLM_EXTENT) {
> 		ldlm_extent_add_lock(res, lock);
> -	else if (res->lr_type == LDLM_FLOCK) {
> +	} else if (res->lr_type == LDLM_FLOCK) {
> 		/*
> 		 * We should not add locks to granted list in the following cases:
> 		 * - this is an UNLOCK but not a real lock;
> @@ -1040,8 +1040,9 @@ void ldlm_grant_lock(struct ldlm_lock *lock, struct list_head *work_list)
> 		    ldlm_is_test_lock(lock) || ldlm_is_flock_deadlock(lock))
> 			return;
> 		ldlm_resource_add_lock(res, &res->lr_granted, lock);
> -	} else
> +	} else {
> 		LBUG();
> +	}
> 
> 	ldlm_pool_add(&ldlm_res_to_ns(res)->ns_pool, lock);
> }
> -- 
> 2.11.0
