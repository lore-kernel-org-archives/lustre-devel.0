From: Andreas Dilger <adilger@whamcloud.com>
Date: Thu, 10 Jan 2019 02:23:13 +0000
Subject: [lustre-devel] [PATCH 29/29] lustre: centralize handling of
 PTLRPCD_SET
In-Reply-To: <154701504291.26726.3018163382085938859.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
 <154701504291.26726.3018163382085938859.stgit@noble>
Message-ID: <2FEE80A4-7331-4877-B488-900266493524@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jan 8, 2019, at 23:24, NeilBrown <neilb@suse.com> wrote:
> 
> Various places test if a given rqset is PTLRPCD_SET
> and call either ptlrpcd_add_req() or ptlrpc_set_add_req()
> depending on the result.
> 
> This can be unified by putting the test of PTLRPCD_SET in
> ptlrpc_set_add_req(), and always calling that function.
> 
> This results in the being only one place that tests PTLRPCD_SET.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> 
> diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
> index 6d328b48a96b..e665f70e54a8 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_net.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_net.h
> @@ -1832,6 +1832,7 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set);
> int ptlrpc_set_wait(struct ptlrpc_request_set *);
> void ptlrpc_set_destroy(struct ptlrpc_request_set *);
> void ptlrpc_set_add_req(struct ptlrpc_request_set *, struct ptlrpc_request *);
> +#define PTLRPCD_SET ((struct ptlrpc_request_set*)1)

(style) space before that '*'

Nice cleanup otherwise.  Definitely removes a bunch of boilerplate code.

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
