From: Alexey Lyashkov <alexey.lyashkov@clusterstor.com>
Date: Wed, 17 Nov 2010 10:52:04 +0300
Subject: [Lustre-devel] extend lnet_notify to public LNet API
In-Reply-To: <4CE2AAAA.3000508@cray.com>
References: <4CE2AAAA.3000508@cray.com>
Message-ID: <9EC72A67-A9FB-41A8-8564-99903E08F047@clusterstor.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nic,

that idea discussed some time ago (as i remember with green and maxim), but have some objection.
Currently LNet hide from ptlrpc layer any network flaps, and LNet will resend request without notify ptlrpc about flap until ptlrpc request timeout.
But if ptlrpc will see node down event, ptlrpc will try reconnect  - that will produce extra overhead, because need to resend too much requests from sending and delay lists instead of lots requests in network flap time.
So, you need separate network flap from node down situation - before implementing that.
currently node marked down if node don't respond for request in ptlrpc timeout, which include network transmit and processing times, but it different then LNet message timeout.


On Nov 16, 2010, at 19:00, Nic Henke wrote:

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
