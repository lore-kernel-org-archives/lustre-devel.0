From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 14 Aug 2019 16:58:37 +0000
Subject: [lustre-devel] [PATCH 8/8] lustre: ldlm: Don't check opcode
 with NULL rq_reqmsg
In-Reply-To: <1564022647-17351-9-git-send-email-jsimmons@infradead.org>
References: <1564022647-17351-1-git-send-email-jsimmons@infradead.org>
 <1564022647-17351-9-git-send-email-jsimmons@infradead.org>
Message-ID: <21043703-25CE-4764-910C-C716D0EC5277@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The ldlm code on the client acts as a "server" for some RPCs from the
OSS and MDS, namely lock cancellation and granting callbacks
(ASTs).

So even if some of this looks like server code it is also used on the client. 

Cheers, Andreas

> On Jul 24, 2019, at 19:44, James Simmons <jsimmons@infradead.org> wrote:
> 
> From: Jeremy Filizetti <jeremy.filizetti@gmail.com>
> 
> When GSS is enabled it's possible to have a NULL rq_reqmsg
> if a bad signature or no context is returned during the unwrap
> of the request.  Don't check the opcode in this case.
> 
> WC-bug-id: https://jira.whamcloud.com/browse/LU-7508
> Lustre-commit: 3f4572caef5f25f4a9b5347b2ccf933fdad9db9c
> Signed-off-by: Jeremy Filizetti <jeremy.filizetti@gmail.com>
> Reviewed-on: http://review.whamcloud.com/17414
> Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
> Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
> Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
> ---
> fs/lustre/ldlm/ldlm_lib.c | 8 ++++++--
> 1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
> index a3b8df4..04982b8 100644
> --- a/fs/lustre/ldlm/ldlm_lib.c
> +++ b/fs/lustre/ldlm/ldlm_lib.c
> @@ -689,8 +689,12 @@ int target_pack_pool_reply(struct ptlrpc_request *req)
>        DEBUG_REQ(D_ERROR, req, "dropping reply");
>        return -ECOMM;
>    }
> -    if (unlikely(lustre_msg_get_opc(req->rq_reqmsg) == MDS_REINT &&
> -             OBD_FAIL_CHECK(OBD_FAIL_MDS_REINT_MULTI_NET_REP)))
> +    /* We can have a null rq_reqmsg in the event of bad signature or
> +     * no context when unwrapping
> +     */
> +    if (req->rq_reqmsg &&
> +        unlikely(lustre_msg_get_opc(req->rq_reqmsg) == MDS_REINT &&
> +        OBD_FAIL_CHECK(OBD_FAIL_MDS_REINT_MULTI_NET_REP)))
>        return -ECOMM;
> 
>    if (unlikely(rc)) {
> -- 
> 1.8.3.1
> 
