From: Oleg Drokin <oleg.drokin@intel.com>
Date: Fri, 14 Jul 2017 17:46:29 -0400
Subject: [lustre-devel] [PATCH][V2] staging: lustre: fix spelling
	mistake, "grranted" -> "granted"
In-Reply-To: <20170714213354.25101-1-colin.king@canonical.com>
References: <20170714213354.25101-1-colin.king@canonical.com>
Message-ID: <D03F15A6-04AE-46C3-9564-55CA055C08DF@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Colin King <colin.king@canonical.com>
Cc: Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "John L . Hammond" <john.hammond@intel.com>, Hongchao Zhang <hongchao.zhang@intel.com>, Alexander Boyko <alexander_boyko@xyratex.com>, Gregoire Pichon <gregoire.pichon@bull.net>, Mikhal Pershin <mike.pershin@intel.com>, Niu Yawei <yawei.niu@intel.com>, Thibaut Robert <thibaut.robert@gmail.com>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org


On Jul 14, 2017, at 5:33 PM, Colin King wrote:

> From: Colin Ian King <colin.king@canonical.com>
> 
> Trivial fix to spelling mistake in CERROR error message. Also
> clean up the grammar.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>

> ---
> drivers/staging/lustre/lustre/ptlrpc/import.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
> index 52cb1f0c9c94..b19dac15e901 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/import.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
> @@ -1026,7 +1026,7 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
> 	/* check that server granted subset of flags we asked for. */
> 	if ((ocd->ocd_connect_flags & imp->imp_connect_flags_orig) !=
> 	    ocd->ocd_connect_flags) {
> -		CERROR("%s: Server didn't granted asked subset of flags: asked=%#llx grranted=%#llx\n",
> +		CERROR("%s: Server didn't grant the asked for subset of flags: asked=%#llx granted=%#llx\n",
> 		       imp->imp_obd->obd_name, imp->imp_connect_flags_orig,
> 		       ocd->ocd_connect_flags);
> 		rc = -EPROTO;
> -- 
> 2.11.0
