From: Nic Henke <nic@cray.com>
Date: Mon, 22 Nov 2010 11:29:47 -0600
Subject: [Lustre-devel] extend lnet_notify to public LNet API
In-Reply-To: <4CE2AAAA.3000508@cray.com>
References: <4CE2AAAA.3000508@cray.com>
Message-ID: <4CEAA88B.4080406@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 11/16/2010 10:00 AM, Nic Henke wrote:
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

One oddity - if the LND has peer_health disabled (no ni_peertimeout 
value), there doesn't seem to be anything that'd set the peer back to 
'up'. Am I missing something or is this as desired ?

Nic
