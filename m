From: Drokin, Oleg <oleg.drokin@intel.com>
Date: Sat, 21 Nov 2015 15:09:22 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: lov: Fix sparse warning
In-Reply-To: <56502ab9.8e4b620a.55593.5357@mx.google.com>
References: <56502ab9.8e4b620a.55593.5357@mx.google.com>
Message-ID: <6F4A320D-0C7C-4F7F-B3AD-D241A22F6F51@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Nov 21, 2015, at 3:26 AM, Paul Davies C wrote:

> This patch fixes the following warnings:-
> 
> drivers/staging/lustre/lustre/lov/lov_object.c:926:22: warning: symbol 'lov_lsm_get' was not declared. Should it be static?
> drivers/staging/lustre/lustre/lov/lov_object.c:942:6: warning: symbol 'lov_lsm_put' was not declared. Should it be static?
> 
> Signed-off-by: Paul Davies C <pauldaviesc@gmail.com>
> ---
> drivers/staging/lustre/lustre/lov/lov_object.c | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
> index c7ff817..a667336 100644
> --- a/drivers/staging/lustre/lustre/lov/lov_object.c
> +++ b/drivers/staging/lustre/lustre/lov/lov_object.c
> @@ -923,7 +923,7 @@ static struct lov_stripe_md *lov_lsm_addref(struct lov_object *lov)
> 	return lsm;
> }
> 
> -struct lov_stripe_md *lov_lsm_get(struct cl_object *clobj)
> +static struct lov_stripe_md *lov_lsm_get(struct cl_object *clobj)
> {
> 	struct lu_object *luobj;
> 	struct lov_stripe_md *lsm = NULL;
> @@ -939,7 +939,7 @@ struct lov_stripe_md *lov_lsm_get(struct cl_object *clobj)
> }
> EXPORT_SYMBOL(lov_lsm_get);

You did not compile-tested this, did you?
This symbol is still used in lustre/lclient/lcommon_cl.c but also
leaving EXPORT_SYMBOL intact for a static symbol?

> 
> -void lov_lsm_put(struct cl_object *unused, struct lov_stripe_md *lsm)
> +static void lov_lsm_put(struct cl_object *unused, struct lov_stripe_md *lsm)
> {
> 	if (lsm != NULL)
> 		lov_free_memmd(&lsm);
> -- 
> 1.9.1
> 
