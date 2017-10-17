From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Tue, 17 Oct 2017 23:05:05 +0000
Subject: [lustre-devel] [PATCH 20/20] staging: lustre: rpc: mark
 expected switch fall-throughs
In-Reply-To: <93be012259825eb72c235b293f44e729797b38c9.1507781178.git.garsilva@embeddedor.com>
References: <cover.1507781178.git.garsilva@embeddedor.com>
 <93be012259825eb72c235b293f44e729797b38c9.1507781178.git.garsilva@embeddedor.com>
Message-ID: <6EFF7C2E-4962-49DE-A71A-072C9E9FCBC1@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Oct 12, 2017, at 10:17, Gustavo A. R. Silva <garsilva@embeddedor.com> wrote:
> 
> In preparation to enabling -Wimplicit-fallthrough, mark switch cases
> where we are expecting to fall through.
> 
> Addresses-Coverity-ID: 1077604
> Addresses-Coverity-ID: 1077605
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> ---
> drivers/staging/lustre/lnet/selftest/rpc.c | 13 +++++++++----
> 1 file changed, 9 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
> index 77c222c..74ef3c3 100644
> --- a/drivers/staging/lustre/lnet/selftest/rpc.c
> +++ b/drivers/staging/lustre/lnet/selftest/rpc.c
> @@ -1037,6 +1037,7 @@ srpc_handle_rpc(struct swi_workitem *wi)
> 			ev->ev_status = rc;
> 		}
> 	}
> +		/* fall through */
> 	case SWI_STATE_BULK_STARTED:
> 		LASSERT(!rpc->srpc_bulk || ev->ev_fired);
> 
> @@ -1237,7 +1238,8 @@ srpc_send_rpc(struct swi_workitem *wi)
> 			break;
> 
> 		wi->swi_state = SWI_STATE_REQUEST_SENT;
> -		/* perhaps more events, fall thru */
> +		/* perhaps more events */
> +		/* fall through */
> 	case SWI_STATE_REQUEST_SENT: {
> 		enum srpc_msg_type type = srpc_service2reply(rpc->crpc_service);
> 
> @@ -1269,6 +1271,7 @@ srpc_send_rpc(struct swi_workitem *wi)
> 
> 		wi->swi_state = SWI_STATE_REPLY_RECEIVED;
> 	}
> +		/* fall through */
> 	case SWI_STATE_REPLY_RECEIVED:
> 		if (do_bulk && !rpc->crpc_bulkev.ev_fired)
> 			break;
> @@ -1448,6 +1451,7 @@ srpc_lnet_ev_handler(struct lnet_event *ev)
> 			srpc_data.rpc_counters.rpcs_sent++;
> 			spin_unlock(&srpc_data.rpc_glock);
> 		}
> +		/* fall through */
> 	case SRPC_REPLY_RCVD:
> 	case SRPC_BULK_REQ_RCVD:
> 		crpc = rpcev->ev_data;
> @@ -1570,7 +1574,7 @@ srpc_lnet_ev_handler(struct lnet_event *ev)
> 
> 		if (!ev->unlinked)
> 			break; /* wait for final event */
> -
> +		/* fall through */
> 	case SRPC_BULK_PUT_SENT:
> 		if (!ev->status && ev->type != LNET_EVENT_UNLINK) {
> 			spin_lock(&srpc_data.rpc_glock);
> @@ -1582,6 +1586,7 @@ srpc_lnet_ev_handler(struct lnet_event *ev)
> 
> 			spin_unlock(&srpc_data.rpc_glock);
> 		}
> +		/* fall through */
> 	case SRPC_REPLY_SENT:
> 		srpc = rpcev->ev_data;
> 		scd = srpc->srpc_scd;
> @@ -1674,14 +1679,14 @@ srpc_shutdown(void)
> 		spin_unlock(&srpc_data.rpc_glock);
> 
> 		stt_shutdown();
> -
> +		/* fall through */
> 	case SRPC_STATE_EQ_INIT:
> 		rc = LNetClearLazyPortal(SRPC_FRAMEWORK_REQUEST_PORTAL);
> 		rc = LNetClearLazyPortal(SRPC_REQUEST_PORTAL);
> 		LASSERT(!rc);
> 		rc = LNetEQFree(srpc_data.rpc_lnet_eq);
> 		LASSERT(!rc); /* the EQ should have no user by now */
> -
> +		/* fall through */
> 	case SRPC_STATE_NI_INIT:
> 		LNetNIFini();
> 	}
> -- 
> 2.7.4
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
