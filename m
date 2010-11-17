From: liang Zhen <liang@whamcloud.com>
Date: Wed, 17 Nov 2010 11:00:53 +0800
Subject: [Lustre-devel] extend lnet_notify to public LNet API
In-Reply-To: <4CE2AAAA.3000508@cray.com>
References: <4CE2AAAA.3000508@cray.com>
Message-ID: <4CE34565.8060007@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nic,

Are you suggesting to provide a new API like:

int LNetNotificationAttach(lnet_notification_callback_t callback);

to register a global callback for LNet, the callback will be called on 
any lnet_notify_locked? If so I don't see any reason we can't do this, 
at least from my point of view. One thing we need to concern is that we 
can't get such a notification for remote peers because no direct 
connection with them in LNDs, we can only get notification for routers 
but upper layer wouldn't be so interested in routers.

Also, seems to me it's a much bigger change in upper layer than in LNet.

Regards
Liang

On 11/17/10 12:00 AM, Nic Henke wrote:
> We'd like to allow upper layers (Lustre, Cray DVS, etc) to register a
> callback that would be called from lnet_notify. This will allow them to
> be notified when the lower layers have seen network problems between
> NIDs and let them take appropriate action. The upper layer could also be
> notified when that peer has returned to 'network health' after the LND
> gets its act together.
>
> This would help allow upper layers to aggressively resend/reconnect in
> the cases where all TX have completed successfully (meaning no LNet -EIO
> on LND errors) but there are LNET_MSG_ACK or other REPLY traffic
> outstanding.
>
> Initial proposal is on the verbose side, giving all data that
> lnet_notify sees:
> - lnet_nid_t
> - is_alive (boolean)
> - cfs_time_t when (unsigned long on Linux) - jiffies when last alive
>
> Is this workable and likely to be accepted up-stream ?
>
> Nic
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
