From: James Simmons <jsimmons@infradead.org>
Date: Mon, 7 Nov 2016 01:57:21 +0000 (GMT)
Subject: [lustre-devel] [PATCH 09/14] staging/lustre/ptlrpc: Suppress
 error for flock requests
In-Reply-To: <1478136304-867780-10-git-send-email-green@linuxhacker.ru>
References: <1478136304-867780-1-git-send-email-green@linuxhacker.ru>
	<1478136304-867780-10-git-send-email-green@linuxhacker.ru>
Message-ID: <alpine.LFD.2.20.1611070157110.21293@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Patrick Farrell <paf@cray.com>


> From: Patrick Farrell <paf@cray.com>
> 
> -EAGAIN is a normal return when requesting POSIX flocks.
> We can't recognize exactly that case here, but it's the
> only case that should result in -EAGAIN on LDLM_ENQUEUE, so
> don't print to console in that case.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: Patrick Farrell <paf@cray.com>
> Reviewed-on: http://review.whamcloud.com/22856
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8658
> Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
> Reviewed-by: Bob Glossman <bob.glossman@intel.com>
> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
> ---
>  drivers/staging/lustre/lustre/ptlrpc/client.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
> index 7cbfb4c..bb7ae4e 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/client.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
> @@ -1191,7 +1191,9 @@ static int ptlrpc_check_status(struct ptlrpc_request *req)
>  		lnet_nid_t nid = imp->imp_connection->c_peer.nid;
>  		__u32 opc = lustre_msg_get_opc(req->rq_reqmsg);
>  
> -		if (ptlrpc_console_allow(req))
> +		/* -EAGAIN is normal when using POSIX flocks */
> +		if (ptlrpc_console_allow(req) &&
> +		    !(opc == LDLM_ENQUEUE && err == -EAGAIN))
>  			LCONSOLE_ERROR_MSG(0x011, "%s: operation %s to node %s failed: rc = %d\n",
>  					   imp->imp_obd->obd_name,
>  					   ll_opcode2str(opc),
> -- 
> 2.7.4
> 
> 
