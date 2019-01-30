From: NeilBrown <neilb@suse.com>
Date: Wed, 30 Jan 2019 13:55:08 +1100
Subject: [lustre-devel] [PATCH 4/4] lustre: ptlrpc: change some foo0()
 to __foo()
In-Reply-To: <98B8BD52-731B-4D5C-8D71-09FCA3BC34F5@cray.com>
References: <154716475327.28978.3817067697027604609.stgit@noble>
 <154716484609.28978.296505839179223953.stgit@noble>
 <98B8BD52-731B-4D5C-8D71-09FCA3BC34F5@cray.com>
Message-ID: <87tvhqlur7.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Jan 14 2019, Nikitas Angelinas wrote:

> On 1/10/19, 4:01 PM, "NeilBrown" <neilb@suse.com> wrote:
>
>     Change:
>       nrs_policy_stop0 -> __nrs_policy_stop
>       nrs_svcpt_setup_locked0 -> __nrs_svcpt_setup_locked
>       ptlrpc_nrs_req_get_nolock0 -> __ptlrpc_nrs_req_get_nolock
>     
>     This is more consistent with Linux naming style.
>     
>     Signed-off-by: NeilBrown <neilb@suse.com>
>     ---
>      drivers/staging/lustre/lustre/ptlrpc/nrs.c         |   20 ++++++++++----------
>      drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c    |    2 +-
>      .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |    6 +++---
>      3 files changed, 14 insertions(+), 14 deletions(-)
>     
>     diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs.c b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
>     index e09b86529c5d..248ba045fb79 100644
>     --- a/drivers/staging/lustre/lustre/ptlrpc/nrs.c
>     +++ b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
>     @@ -82,7 +82,7 @@ static int nrs_policy_ctl_locked(struct ptlrpc_nrs_policy *policy,
>      	       -ENOSYS;
>      }
>      
>     -static void nrs_policy_stop0(struct ptlrpc_nrs_policy *policy)
>     +static void __nrs_policy_stop(struct ptlrpc_nrs_policy *policy)
>      {
>      	if (policy->pol_desc->pd_ops->op_policy_stop)
>      		policy->pol_desc->pd_ops->op_policy_stop(policy);
>     @@ -126,7 +126,7 @@ static int nrs_policy_stop_locked(struct ptlrpc_nrs_policy *policy)
>      
>      	/* I have the only refcount */
>      	if (policy->pol_ref == 1)
>     -		nrs_policy_stop0(policy);
>     +		__nrs_policy_stop(policy);
>      
>      	return 0;
>      }
>     @@ -151,7 +151,7 @@ static void nrs_policy_stop_primary(struct ptlrpc_nrs *nrs)
>      	tmp->pol_state = NRS_POL_STATE_STOPPING;
>      
>      	if (tmp->pol_ref == 0)
>     -		nrs_policy_stop0(tmp);
>     +		__nrs_policy_stop(tmp);
>      }
>      
>      /**
>     @@ -300,7 +300,7 @@ static void nrs_policy_put_locked(struct ptlrpc_nrs_policy *policy)
>      	policy->pol_ref--;
>      	if (unlikely(policy->pol_ref == 0 &&
>      		     policy->pol_state == NRS_POL_STATE_STOPPING))
>     -		nrs_policy_stop0(policy);
>     +		__nrs_policy_stop(policy);
>      }
> "nrs_policy_stop0()" also appears in a comment in drivers/staging/lustre/lustre/include/lustre_nrs.h, if you would like to change that as well? Other than that, please feel free to add:
>
> Reviewed-by: Nikitas Angelinas <nangelinas@cray.com>

Thanks!  I've fixed that missing change, and added your Reviewed-by.

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190130/12cd3a12/attachment.sig>
