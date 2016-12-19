From: James Simmons <jsimmons@infradead.org>
Date: Mon, 19 Dec 2016 16:22:58 +0000 (GMT)
Subject: [lustre-devel] [PATCH] staging: lustre: ldlm: use designated
	initializers
In-Reply-To: <20161217010045.GA140343@beast>
References: <20161217010045.GA140343@beast>
Message-ID: <alpine.LFD.2.20.1612191614320.25173@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "John L. Hammond" <john.hammond@intel.com>, Emoly Liu <emoly.liu@intel.com>, Vitaly Fertman <vitaly_fertman@xyratex.com>, Bruno Faccini <bruno.faccini@intel.com>, Bruce Korb <bruce.korb@gmail.com>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org


> Prepare to mark sensitive kernel structures for randomization by making
> sure they're using designated initializers. These were identified during
> allyesconfig builds of x86, arm, and arm64, with most initializer fixes
> extracted from grsecurity.
> 
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
>  drivers/staging/lustre/lustre/ldlm/ldlm_flock.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
> index 722160784f83..f815827532dc 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
> @@ -143,7 +143,7 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req, __u64 *flags,
>  	int added = (mode == LCK_NL);
>  	int overlaps = 0;
>  	int splitted = 0;
> -	const struct ldlm_callback_suite null_cbs = { NULL };
> +	const struct ldlm_callback_suite null_cbs = { };
>  
>  	CDEBUG(D_DLMTRACE,
>  	       "flags %#llx owner %llu pid %u mode %u start %llu end %llu\n",

Nak. Filling null_cbs with random data is a bad idea. If you look at 
ldlm_lock_create() where this is used you have

if (cbs) {
	lock->l_blocking_ast = cbs->lcs_blocking;
	lock->l_completion_ast = cbs->lcs_completion;
	lock->l_glimpse_ast = cbs->lcs_glimpse;
}

Having lock->l_* point to random addresses is a bad idea.
What really needs to be done is proper initialization of that
structure. A bunch of patches will be coming to address this.
