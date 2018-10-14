From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 23:44:12 +0100 (BST)
Subject: [lustre-devel] [PATCH 15/24] lustre: lnet: add msg_type to
 lnet_event
In-Reply-To: <153895437812.16383.7373974293282162856.stgit@noble>
References: <153895417139.16383.3791701638653772865.stgit@noble>
 <153895437812.16383.7373974293282162856.stgit@noble>
Message-ID: <alpine.LFD.2.21.1810142343370.9543@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> From: Olaf Weber <olaf@sgi.com>
> 
> Add a msg_type field to the lnet_event structure. This makes
> it possible for an event handler to tell whether LNET_EVENT_SEND
> corresponds to a GET or a PUT message.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> WC-bug-id: https://jira.whamcloud.com/browse/LU-9480
> Signed-off-by: Olaf Weber <olaf@sgi.com>
> Reviewed-on: https://review.whamcloud.com/25785
> Reviewed-by: Amir Shehata <amir.shehata@intel.com>
> Tested-by: Amir Shehata <amir.shehata@intel.com>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../lustre/include/uapi/linux/lnet/lnet-types.h    |    5 +++++
>  drivers/staging/lustre/lnet/lnet/lib-msg.c         |    1 +
>  2 files changed, 6 insertions(+)
> 
> diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
> index e0e4fd259795..1ecf18e4a278 100644
> --- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
> +++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
> @@ -650,6 +650,11 @@ struct lnet_event {
>  	 * \see LNetPut
>  	 */
>  	__u64			hdr_data;
> +	/**
> +	 * The message type, to ensure a handler for LNET_EVENT_SEND can
> +	 * distinguish between LNET_MSG_GET and LNET_MSG_PUT.
> +	 */
> +	__u32               msg_type;
>  	/**
>  	 * Indicates the completion status of the operation. It's 0 for
>  	 * successful operations, otherwise it's an error code.
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
> index 1817e54a16a5..db13d01d366f 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
> @@ -63,6 +63,7 @@ lnet_build_msg_event(struct lnet_msg *msg, enum lnet_event_kind ev_type)
>  	LASSERT(!msg->msg_routing);
>  
>  	ev->type = ev_type;
> +	ev->msg_type = msg->msg_type;
>  
>  	if (ev_type == LNET_EVENT_SEND) {
>  		/* event for active message */
> 
> 
> 
