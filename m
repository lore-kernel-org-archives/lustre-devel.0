From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Fri, 13 Jan 2017 01:17:39 +0000
Subject: [lustre-devel] [PATCH 1/2] Fixed signedness check
In-Reply-To: <20161226154339.8916-1-kedrot@gmail.com>
References: <20161226154339.8916-1-kedrot@gmail.com>
Message-ID: <0EF6ABF1-1E3F-46DF-90CA-DA890027DEC4@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Guillermo O. Freschi" <kedrot@gmail.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Dec 26, 2016, at 08:43, Guillermo O. Freschi <kedrot@gmail.com> wrote:
> 
> Was `unsigned int`, but `enum`s are signed.

Interesting that GCC didn't complain that the itree_overlap_cb() function
signature didn't match the argument prototype for interval_search():

  typedef enum interval_iter (*interval_callback_t)(struct interval_node *node,
                                                    void *args);

In the end it is a somewhat cosmetic fix, because the only enum values
(1, 2) were unsigned, but good to be consistent.  Thanks for the fix.

> Signed-off-by: Guillermo O. Freschi <kedrot@gmail.com>

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> ---
> drivers/staging/lustre/lustre/ldlm/ldlm_lock.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
> index a4a291acb659..f4cbc89b4f24 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
> @@ -1148,7 +1148,7 @@ static int lock_matches(struct ldlm_lock *lock, struct lock_match_data *data)
> 	return INTERVAL_ITER_STOP;
> }
> 
> -static unsigned int itree_overlap_cb(struct interval_node *in, void *args)
> +static enum interval_iter itree_overlap_cb(struct interval_node *in, void *args)
> {
> 	struct ldlm_interval *node = to_ldlm_interval(in);
> 	struct lock_match_data *data = args;
> -- 
> 2.11.0
> 
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
