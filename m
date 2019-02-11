From: James Simmons <jsimmons@infradead.org>
Date: Mon, 11 Feb 2019 01:48:54 +0000 (GMT)
Subject: [lustre-devel] [PATCH 09/21] lustre: use list_last_entry()
 throughout
In-Reply-To: <154949781307.10620.3918792136275031845.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781307.10620.3918792136275031845.stgit@noble.brown>
Message-ID: <alpine.LFD.2.21.1902110148440.24975@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> Convert
>   list_entry(foo->prev .....)
> to
>   list_last_entry(foo, ....)
> 
> throughout lustre.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/include/cl_object.h |    2 +-
>  drivers/staging/lustre/lustre/ptlrpc/client.c     |    6 +++---
>  drivers/staging/lustre/lustre/ptlrpc/service.c    |    5 +++--
>  3 files changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
> index 53fd8d469e55..bf7678aed6bf 100644
> --- a/drivers/staging/lustre/lustre/include/cl_object.h
> +++ b/drivers/staging/lustre/lustre/include/cl_object.h
> @@ -2329,7 +2329,7 @@ do {									\
>  static inline struct cl_page *cl_page_list_last(struct cl_page_list *plist)
>  {
>  	LASSERT(plist->pl_nr > 0);
> -	return list_entry(plist->pl_pages.prev, struct cl_page, cp_batch);
> +	return list_last_entry(&plist->pl_pages, struct cl_page, cp_batch);
>  }
>  
>  static inline struct cl_page *cl_page_list_first(struct cl_page_list *plist)
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
> index a78d49621c42..b2b11047ea19 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/client.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
> @@ -1464,9 +1464,9 @@ static int after_reply(struct ptlrpc_request *req)
>  		if (!list_empty(&imp->imp_replay_list)) {
>  			struct ptlrpc_request *last;
>  
> -			last = list_entry(imp->imp_replay_list.prev,
> -					  struct ptlrpc_request,
> -					  rq_replay_list);
> +			last = list_last_entry(&imp->imp_replay_list,
> +					       struct ptlrpc_request,
> +					       rq_replay_list);
>  			/*
>  			 * Requests with rq_replay stay on the list even if no
>  			 * commit is expected.
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
> index a69736dfe8b7..35a59e5a5e9d 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/service.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
> @@ -2255,8 +2255,9 @@ static int ptlrpc_hr_main(void *arg)
>  		while (!list_empty(&replies)) {
>  			struct ptlrpc_reply_state *rs;
>  
> -			rs = list_entry(replies.prev, struct ptlrpc_reply_state,
> -					rs_list);
> +			rs = list_last_entry(&replies,
> +					     struct ptlrpc_reply_state,
> +					     rs_list);
>  			list_del_init(&rs->rs_list);
>  			ptlrpc_handle_rs(rs);
>  		}
> 
> 
> 
