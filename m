From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 14 Aug 2019 16:58:52 +0000
Subject: [lustre-devel] [PATCH 3/8] lustre: fld: resend seq lookup RPC
 if it is on LWP
In-Reply-To: <1564022647-17351-4-git-send-email-jsimmons@infradead.org>
References: <1564022647-17351-1-git-send-email-jsimmons@infradead.org>
 <1564022647-17351-4-git-send-email-jsimmons@infradead.org>
Message-ID: <422455A8-A692-438E-863E-AB71C345565D@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This is functionality used only by the server (LWP connection and also
MDS-MDS connection flag).  But as I wrote previously, it will be tough to
track this patch to only apply it when the server code is landed. Instead,
it would likely just be a hard-to-find bug that needs to be tracked down
again and fixed again. 

My preference would be to land this and other similar patches in shared
code that is not easily separated into client- and server-only sections. 

Cheers, Andreas

> On Jul 24, 2019, at 19:44, James Simmons <jsimmons@infradead.org> wrote:
> 
> From: wang di <di.wang@intel.com>
> 
> Because Light Weight connection might be evicted after
> restart, then cause inflight RPC fails, to avoid this,
> we need resend seq lookup RPC.
> 
> remove "-f" from "stop mdt" in sanity 17m, so umount can
> keep the the connection, and otherwise the OSP might be
> evicted.
> 
> WC-bug-id: https://jira.whamcloud.com/browse/LU-4571
> Lustre-commit: cf7f66d87e52293535cde6e8cc7386e6c1bdfa46
> Signed-off-by: wang di <di.wang@intel.com>
> Reviewed-on: http://review.whamcloud.com/9106
> Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
> Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
> Reviewed-by: Niu Yawei <yawei.niu@intel.com>
> ---
> fs/lustre/fld/fld_request.c | 23 +++++++++++++++++++++--
> 1 file changed, 21 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/lustre/fld/fld_request.c b/fs/lustre/fld/fld_request.c
> index 248fffa..ec45ea6 100644
> --- a/fs/lustre/fld/fld_request.c
> +++ b/fs/lustre/fld/fld_request.c
> @@ -314,6 +314,7 @@ int fld_client_rpc(struct obd_export *exp,
> 
>    LASSERT(exp);
> 
> +again:
>    imp = class_exp2cliimp(exp);
>    switch (fld_op) {
>    case FLD_QUERY:
> @@ -329,8 +330,15 @@ int fld_client_rpc(struct obd_export *exp,
>        op = req_capsule_client_get(&req->rq_pill, &RMF_FLD_OPC);
>        *op = FLD_LOOKUP;
> 
> -        if (imp->imp_connect_flags_orig & OBD_CONNECT_MDS_MDS)
> +        /* For MDS_MDS seq lookup, it will always use LWP connection,
> +         * but LWP will be evicted after restart, so cause the error.
> +         * so we will set no_delay for seq lookup request, once the
> +         * request fails because of the eviction. always retry here
> +         */
> +        if (imp->imp_connect_flags_orig & OBD_CONNECT_MDS_MDS) {
>            req->rq_allow_replay = 1;
> +            req->rq_no_delay = 1;
> +        }
>        break;
>    case FLD_READ:
>        req = ptlrpc_request_alloc_pack(imp, &RQF_FLD_READ,
> @@ -358,8 +366,19 @@ int fld_client_rpc(struct obd_export *exp,
>    obd_get_request_slot(&exp->exp_obd->u.cli);
>    rc = ptlrpc_queue_wait(req);
>    obd_put_request_slot(&exp->exp_obd->u.cli);
> -    if (rc)
> +    if (rc != 0) {
> +        if (rc == -EWOULDBLOCK) {
> +            /* For no_delay req(see above), EWOULDBLOCK means the
> +             * connection is being evicted, but this seq lookup
> +             * should not return error, since it would cause
> +             * unecessary failure of the application, instead
> +             * it should retry here
> +             */
> +            ptlrpc_req_finished(req);
> +            goto again;
> +        }
>        goto out_req;
> +    }
> 
>    if (fld_op == FLD_QUERY) {
>        prange = req_capsule_server_get(&req->rq_pill, &RMF_FLD_MDFLD);
> -- 
> 1.8.3.1
> 
