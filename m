From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 14 Aug 2019 16:58:42 +0000
Subject: [lustre-devel] [PATCH 4/8] lustre: fld: retry fld rpc even for
 ESHUTDOWN
In-Reply-To: <1564022647-17351-5-git-send-email-jsimmons@infradead.org>
References: <1564022647-17351-1-git-send-email-jsimmons@infradead.org>
 <1564022647-17351-5-git-send-email-jsimmons@infradead.org>
Message-ID: <04591359-31D0-44BA-B9F0-732101057FFB@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

While FLD is used on both client and server, the LWP connections are only used on clients. However, I don't see any harm to keep this code consistent with the master branch. 

Otherwise, you would have to remember to apply this patch at some point in the future when the server code is landed, which is more likely to leave the bug in place 

Cheers, Andreas

> On Jul 24, 2019, at 19:44, James Simmons <jsimmons@infradead.org> wrote:
> 
> From: wang di <di.wang@intel.com>
> 
> when LWP is being evicted, because it is not replayable,
> the request might return ESHUTDOWN or EWOULDBLOCK, instead
> of failed, which might cause application failure, fld
> client will retry RPC, until the connection is being setup
> again or the LWP is being closed.
> 
> WC-bug-id: https://jira.whamcloud.com/browse/LU-4420
> Lustre-commit: d335e310d4bf490509998ddbb1824e38cff20998
> Signed-off-by: wang di <di.wang@intel.com>
> Reviewed-on: http://review.whamcloud.com/10285
> Reviewed-by: Fan Yong <fan.yong@intel.com>
> Reviewed-by: Johann Lombardi <johann.lombardi@intel.com>
> ---
> fs/lustre/fld/fld_request.c | 12 ++++++------
> 1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/lustre/fld/fld_request.c b/fs/lustre/fld/fld_request.c
> index ec45ea6..ba0ef82 100644
> --- a/fs/lustre/fld/fld_request.c
> +++ b/fs/lustre/fld/fld_request.c
> @@ -367,12 +367,12 @@ int fld_client_rpc(struct obd_export *exp,
>    rc = ptlrpc_queue_wait(req);
>    obd_put_request_slot(&exp->exp_obd->u.cli);
>    if (rc != 0) {
> -        if (rc == -EWOULDBLOCK) {
> -            /* For no_delay req(see above), EWOULDBLOCK means the
> -             * connection is being evicted, but this seq lookup
> -             * should not return error, since it would cause
> -             * unecessary failure of the application, instead
> -             * it should retry here
> +        if (rc == -EWOULDBLOCK || rc == -ESHUTDOWN) {
> +            /* For no_delay req(see above), EWOULDBLOCK and
> +             * ESHUTDOWN means the connection is being evicted,
> +             * but this seq lookup should not return error,
> +             * since it would cause unecessary failure of the
> +             * application, instead it should retry here
>             */
>            ptlrpc_req_finished(req);
>            goto again;
> -- 
> 1.8.3.1
> 
