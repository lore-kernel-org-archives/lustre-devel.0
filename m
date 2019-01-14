From: Nikitas Angelinas <nangelinas@cray.com>
Date: Mon, 14 Jan 2019 11:27:37 +0000
Subject: [lustre-devel] [PATCH 4/4] lustre: ptlrpc: change some foo0()
 to __foo()
In-Reply-To: <154716484609.28978.296505839179223953.stgit@noble>
References: <154716475327.28978.3817067697027604609.stgit@noble>
 <154716484609.28978.296505839179223953.stgit@noble>
Message-ID: <98B8BD52-731B-4D5C-8D71-09FCA3BC34F5@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 1/10/19, 4:01 PM, "NeilBrown" <neilb@suse.com> wrote:

    Change:
      nrs_policy_stop0 -> __nrs_policy_stop
      nrs_svcpt_setup_locked0 -> __nrs_svcpt_setup_locked
      ptlrpc_nrs_req_get_nolock0 -> __ptlrpc_nrs_req_get_nolock
    
    This is more consistent with Linux naming style.
    
    Signed-off-by: NeilBrown <neilb@suse.com>
    ---
     drivers/staging/lustre/lustre/ptlrpc/nrs.c         |   20 ++++++++++----------
     drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c    |    2 +-
     .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |    6 +++---
     3 files changed, 14 insertions(+), 14 deletions(-)
    
    diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs.c b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
    index e09b86529c5d..248ba045fb79 100644
    --- a/drivers/staging/lustre/lustre/ptlrpc/nrs.c
    +++ b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
    @@ -82,7 +82,7 @@ static int nrs_policy_ctl_locked(struct ptlrpc_nrs_policy *policy,
     	       -ENOSYS;
     }
     
    -static void nrs_policy_stop0(struct ptlrpc_nrs_policy *policy)
    +static void __nrs_policy_stop(struct ptlrpc_nrs_policy *policy)
     {
     	if (policy->pol_desc->pd_ops->op_policy_stop)
     		policy->pol_desc->pd_ops->op_policy_stop(policy);
    @@ -126,7 +126,7 @@ static int nrs_policy_stop_locked(struct ptlrpc_nrs_policy *policy)
     
     	/* I have the only refcount */
     	if (policy->pol_ref == 1)
    -		nrs_policy_stop0(policy);
    +		__nrs_policy_stop(policy);
     
     	return 0;
     }
    @@ -151,7 +151,7 @@ static void nrs_policy_stop_primary(struct ptlrpc_nrs *nrs)
     	tmp->pol_state = NRS_POL_STATE_STOPPING;
     
     	if (tmp->pol_ref == 0)
    -		nrs_policy_stop0(tmp);
    +		__nrs_policy_stop(tmp);
     }
     
     /**
    @@ -300,7 +300,7 @@ static void nrs_policy_put_locked(struct ptlrpc_nrs_policy *policy)
     	policy->pol_ref--;
     	if (unlikely(policy->pol_ref == 0 &&
     		     policy->pol_state == NRS_POL_STATE_STOPPING))
    -		nrs_policy_stop0(policy);
    +		__nrs_policy_stop(policy);
     }
"nrs_policy_stop0()" also appears in a comment in drivers/staging/lustre/lustre/include/lustre_nrs.h, if you would like to change that as well? Other than that, please feel free to add:

Reviewed-by: Nikitas Angelinas <nangelinas@cray.com>
     
     static void nrs_policy_put(struct ptlrpc_nrs_policy *policy)
    @@ -888,8 +888,8 @@ static int nrs_register_policies_locked(struct ptlrpc_nrs *nrs)
      *
      * \pre mutex_is_locked(&nrs_core.nrs_mutex)
      */
    -static int nrs_svcpt_setup_locked0(struct ptlrpc_nrs *nrs,
    -				   struct ptlrpc_service_part *svcpt)
    +static int __nrs_svcpt_setup_locked(struct ptlrpc_nrs *nrs,
    +				    struct ptlrpc_service_part *svcpt)
     {
     	enum ptlrpc_nrs_queue_type queue;
     
    @@ -931,7 +931,7 @@ static int nrs_svcpt_setup_locked(struct ptlrpc_service_part *svcpt)
     	 * Initialize the regular NRS head.
     	 */
     	nrs = nrs_svcpt2nrs(svcpt, false);
    -	rc = nrs_svcpt_setup_locked0(nrs, svcpt);
    +	rc = __nrs_svcpt_setup_locked(nrs, svcpt);
     	if (rc < 0)
     		goto out;
     
    @@ -951,7 +951,7 @@ static int nrs_svcpt_setup_locked(struct ptlrpc_service_part *svcpt)
     	}
     
     	nrs = nrs_svcpt2nrs(svcpt, true);
    -	rc = nrs_svcpt_setup_locked0(nrs, svcpt);
    +	rc = __nrs_svcpt_setup_locked(nrs, svcpt);
     
     out:
     	return rc;
    @@ -1444,8 +1444,8 @@ static void nrs_request_removed(struct ptlrpc_nrs_policy *policy)
      * \retval NULL the head has no requests to serve
      */
     struct ptlrpc_request *
    -ptlrpc_nrs_req_get_nolock0(struct ptlrpc_service_part *svcpt, bool hp,
    -			   bool peek, bool force)
    +__ptlrpc_nrs_req_get_nolock(struct ptlrpc_service_part *svcpt, bool hp,
    +			    bool peek, bool force)
     {
     	struct ptlrpc_nrs *nrs = nrs_svcpt2nrs(svcpt, hp);
     	struct ptlrpc_nrs_policy *policy;
    diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c b/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
    index ff630d94dd26..7fe8aeeff428 100644
    --- a/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
    +++ b/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
    @@ -96,7 +96,7 @@ static int nrs_fifo_start(struct ptlrpc_nrs_policy *policy)
      *
      * \param[in] policy The policy to stop
      *
    - * \see nrs_policy_stop0()
    + * \see __nrs_policy_stop()
      */
     static void nrs_fifo_stop(struct ptlrpc_nrs_policy *policy)
     {
    diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
    index 177010cf7148..da42b99fc36f 100644
    --- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
    +++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
    @@ -133,14 +133,14 @@ void ptlrpc_nrs_req_add(struct ptlrpc_service_part *svcpt,
     			struct ptlrpc_request *req, bool hp);
     
     struct ptlrpc_request *
    -ptlrpc_nrs_req_get_nolock0(struct ptlrpc_service_part *svcpt, bool hp,
    -			   bool peek, bool force);
    +__ptlrpc_nrs_req_get_nolock(struct ptlrpc_service_part *svcpt, bool hp,
    +			    bool peek, bool force);
     
     static inline struct ptlrpc_request *
     ptlrpc_nrs_req_get_nolock(struct ptlrpc_service_part *svcpt, bool hp,
     			  bool force)
     {
    -	return ptlrpc_nrs_req_get_nolock0(svcpt, hp, false, force);
    +	return __ptlrpc_nrs_req_get_nolock(svcpt, hp, false, force);
     }
     
     bool ptlrpc_nrs_req_pending_nolock(struct ptlrpc_service_part *svcpt, bool hp);
    
Cheers,
Nikitas
