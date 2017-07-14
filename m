From: Oleg Drokin <oleg.drokin@intel.com>
Date: Fri, 14 Jul 2017 16:43:10 -0400
Subject: [lustre-devel] [PATCH] staging: lustre: fix spelling mistake,
	"grranted" -> "granted"
In-Reply-To: <20170714132602.27713-1-colin.king@canonical.com>
References: <20170714132602.27713-1-colin.king@canonical.com>
Message-ID: <6FB4ABAB-3CB3-470C-BFD1-A8DC02862D3F@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Colin King <colin.king@canonical.com>
Cc: Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "John L . Hammond" <john.hammond@intel.com>, Hongchao Zhang <hongchao.zhang@intel.com>, Alexander Boyko <alexander_boyko@xyratex.com>, wang di <di.wang@intel.com>, Niu Yawei <yawei.niu@intel.com>, Mikhal Pershin <mike.pershin@intel.com>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org


On Jul 14, 2017, at 9:26 AM, Colin King wrote:

> From: Colin Ian King <colin.king@canonical.com>
> 
> Trivial fix to spelling mistake in CERROR error message
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
> drivers/staging/lustre/lustre/ptlrpc/import.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
> index 52cb1f0c9c94..99877aa10d6f 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/import.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
> @@ -1026,7 +1026,7 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
> 	/* check that server granted subset of flags we asked for. */
> 	if ((ocd->ocd_connect_flags & imp->imp_connect_flags_orig) !=
> 	    ocd->ocd_connect_flags) {
> -		CERROR("%s: Server didn't granted asked subset of flags: asked=%#llx grranted=%#llx\n",
> +		CERROR("%s: Server didn't granted asked subset of flags: asked=%#llx granted=%#llx\n",

While we are at it can also address grammar problem: "didn't granted" -> "didn't grant"?

Thanks!

> 		       imp->imp_obd->obd_name, imp->imp_connect_flags_orig,
> 		       ocd->ocd_connect_flags);
> 		rc = -EPROTO;
> -- 
> 2.11.0
