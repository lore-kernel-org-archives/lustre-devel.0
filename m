From: Patrick Farrell <paf@cray.com>
Date: Mon, 16 May 2016 12:57:55 -0500
Subject: [lustre-devel] [PATCH v2] staging/lustre/ptlrpc: Removes
 potential null dereference
In-Reply-To: <1463408271-18079-1-git-send-email-lidza.louina@oracle.com>
References: <1463408271-18079-1-git-send-email-lidza.louina@oracle.com>
Message-ID: <573A0A23.2010705@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This looks wrong - You return -EINVAL from sptlrpc_pack_user_desc, but 
then the caller checks "!desc".  Desc will not be null, since you've 
returned -EINVAL.

- Patrick

On 05/16/2016 09:17 AM, Lidza Louina wrote:
> The lustre_msg_buf method could return NULL. Subsequent code didn't
> check if it's null before using it. This patch adds two checks.
>
> Signed-off-by: Lidza Louina <lidza.louina@oracle.com>
> ---
>   drivers/staging/lustre/lustre/ptlrpc/sec.c       | 2 ++
>   drivers/staging/lustre/lustre/ptlrpc/sec_plain.c | 9 +++++++--
>   2 files changed, 9 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
> index 187fd1d..e6fedc3 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
> @@ -2195,6 +2195,8 @@ int sptlrpc_pack_user_desc(struct lustre_msg *msg, int offset)
>   	struct ptlrpc_user_desc *pud;
>   
>   	pud = lustre_msg_buf(msg, offset, 0);
> +	if (!pud)
> +		return -EINVAL;
>   
>   	pud->pud_uid = from_kuid(&init_user_ns, current_uid());
>   	pud->pud_gid = from_kgid(&init_user_ns, current_gid());
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
> index 37c9f4c..51741c8 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
> @@ -542,6 +542,7 @@ int plain_alloc_reqbuf(struct ptlrpc_sec *sec,
>   {
>   	__u32 buflens[PLAIN_PACK_SEGMENTS] = { 0, };
>   	int alloc_len;
> +	int desc;
>   
>   	buflens[PLAIN_PACK_HDR_OFF] = sizeof(struct plain_header);
>   	buflens[PLAIN_PACK_MSG_OFF] = msgsize;
> @@ -574,8 +575,12 @@ int plain_alloc_reqbuf(struct ptlrpc_sec *sec,
>   	lustre_init_msg_v2(req->rq_reqbuf, PLAIN_PACK_SEGMENTS, buflens, NULL);
>   	req->rq_reqmsg = lustre_msg_buf(req->rq_reqbuf, PLAIN_PACK_MSG_OFF, 0);
>   
> -	if (req->rq_pack_udesc)
> -		sptlrpc_pack_user_desc(req->rq_reqbuf, PLAIN_PACK_USER_OFF);
> +	if (req->rq_pack_udesc) {
> +		desc = sptlrpc_pack_user_desc(req->rq_reqbuf,
> +					      PLAIN_PACK_USER_OFF);
> +		if (!desc)
> +			return desc;
> +	}
>   
>   	return 0;
>   }
