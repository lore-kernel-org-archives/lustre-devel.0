From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Thu, 3 Nov 2016 22:12:26 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: fixed shadowed variable
	in socklnd_cb.c
In-Reply-To: <1478210059-6091-1-git-send-email-andrew.kanner@gmail.com>
References: <1478210059-6091-1-git-send-email-andrew.kanner@gmail.com>
Message-ID: <C754133A-93C3-4E41-92B2-F8CCA2B668FA@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Kanner <andrew.kanner@gmail.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, "bevans@cray.com" <bevans@cray.com>, "bhaktipriya96@gmail.com" <bhaktipriya96@gmail.com>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Nov 3, 2016, at 15:54, Andrew Kanner <andrew.kanner@gmail.com> wrote:
> 
> Changed variable 'tx' name in local scope
> Fixed: sparse warning:
> socklnd_cb.c:2476:41: warning: symbol 'tx' shadows an earlier one
> socklnd_cb.c:2435:25: originally declared here

Looking at this more closely (or from a greater distance, hard to say),
the outer-scope "tx" is used only after this inner-scope "tx", so in
fact there is no benefit to having the inner-scope declaration at all.

Removing it may save a stack variable (depending on how the compiler
optimizes), and shouldn't affect functionality.

Cheers, Andreas

> Signed-off-by: Andrew Kanner <andrew.kanner@gmail.com>
> ---
> drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> index c1c6f60..03fe4e5 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> @@ -2473,11 +2473,11 @@ ksocknal_check_peer_timeouts(int idx)
> 		 * holding only shared lock
> 		 */
> 		if (!list_empty(&peer->ksnp_tx_queue)) {
> -			struct ksock_tx *tx = list_entry(peer->ksnp_tx_queue.next,
> +			struct ksock_tx *_tx = list_entry(peer->ksnp_tx_queue.next,
> 						    struct ksock_tx, tx_list);
> 
> 			if (cfs_time_aftereq(cfs_time_current(),
> -					     tx->tx_deadline)) {
> +					     _tx->tx_deadline)) {
> 				ksocknal_peer_addref(peer);
> 				read_unlock(&ksocknal_data.ksnd_global_lock);
> 
> -- 
> 2.1.4
> 
