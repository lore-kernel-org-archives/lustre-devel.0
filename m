From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Fri, 27 Oct 2017 09:20:31 +0000
Subject: [lustre-devel] [PATCH 5/9] staging: lustre: ldlm: remove unused
 'overlaps' variable
In-Reply-To: <150872002972.3340.9372825368625571993.stgit@noble>
References: <150871988297.3340.4522589460981284121.stgit@noble>
 <150872002972.3340.9372825368625571993.stgit@noble>
Message-ID: <77ADF410-2FBC-4F06-B5C5-275EE18D703D@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Oct 22, 2017, at 18:53, NeilBrown <neilb@suse.com> wrote:
> 
> 'overlaps' is never used, only incremented.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> ---
> drivers/staging/lustre/lustre/ldlm/ldlm_flock.c |    3 ---
> 1 file changed, 3 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
> index 2d1fa2b33129..d5a5742a1171 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
> @@ -133,7 +133,6 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req)
> 	struct ldlm_lock *new2 = NULL;
> 	enum ldlm_mode mode = req->l_req_mode;
> 	int added = (mode == LCK_NL);
> -	int overlaps = 0;
> 	int splitted = 0;
> 	const struct ldlm_callback_suite null_cbs = { };
> 
> @@ -226,8 +225,6 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req)
> 		    lock->l_policy_data.l_flock.start)
> 			break;
> 
> -		++overlaps;
> -
> 		if (new->l_policy_data.l_flock.start <=
> 		    lock->l_policy_data.l_flock.start) {
> 			if (new->l_policy_data.l_flock.end <
> 
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
