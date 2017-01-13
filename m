From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Fri, 13 Jan 2017 01:20:18 +0000
Subject: [lustre-devel] [PATCH 2/2] Style fixes
In-Reply-To: <20161226154339.8916-2-kedrot@gmail.com>
References: <20161226154339.8916-1-kedrot@gmail.com>
	<20161226154339.8916-2-kedrot@gmail.com>
Message-ID: <03F47D3D-C497-4138-A168-5A4A3B20CF77@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Guillermo O. Freschi" <kedrot@gmail.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>


> On Dec 26, 2016, at 08:43, Guillermo O. Freschi <kedrot@gmail.com> wrote:
> 
> Missing braces on `if` statement; misaligned parameter.
> 
> Signed-off-by: Guillermo O. Freschi <kedrot@gmail.com>
> ---
> drivers/staging/lustre/lustre/ldlm/ldlm_lock.c | 12 +++++++-----
> 1 file changed, 7 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
> index f4cbc89b4f24..a23e7ada3891 100644
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

This part is fine.

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

Fine.

> @@ -1481,7 +1482,8 @@ int ldlm_fill_lvb(struct ldlm_lock *lock, struct req_capsule *pill,
> 							lustre_swab_ost_lvb_v1);
> 			else
> 				lvb = req_capsule_server_sized_swab_get(pill,
> -						&RMF_DLM_LVB, size,
> +									&RMF_DLM_LVB,
> +									size,
> 						lustre_swab_ost_lvb_v1);

Not so keen on this one, since "lustre_swab_ost_lvb_v1" can't fit after the
'(' of the original function line, there isn't any benefit to aligning the
other two arguments but not that one.  Better to keep the indentation the
same and save one line of whitespace.

Can you please resubmit without this hunk.

Cheers, Andreas
