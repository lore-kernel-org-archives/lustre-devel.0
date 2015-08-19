From: Chris Horn <hornc@cray.com>
Date: Wed, 19 Aug 2015 21:16:29 +0000
Subject: [lustre-devel] Why can you set concurrent_sends < peer_credits ?
In-Reply-To: <FA332012-D83C-41BA-969D-2EA17A23C058@cray.com>
References: <A6550817-BCC0-49D6-A259-067A4CCA87B7@cray.com>
	<CAJ2e-W1S1FXnLLH30HOp=FzisXPy51eHJM+W+RYwmJVDcNjH1w@mail.gmail.com>
	<04556C78-49F4-4A78-A477-ADE76C7773BB@cray.com>
	<CAJ2e-W1ctBWG083t=pO=NmZwaiefx2eMJYqBpjC+K=HQ9PKJAg@mail.gmail.com>
	<EBC6621B-E96B-43B4-AAE2-B3C445BC41FD@cray.com>
	<CAJ2e-W3gt6SMjyCCZAkC_HyGmpNezZq4bqBRziwY-r45EeSPnw@mail.gmail.com>
	<55D4EBB1.3000502@llnl.gov>
	<CAJ2e-W0h9HfHrrcOkimoHWhpNiAMzdo_C1WNinLLbGeLBF9X5A@mail.gmail.com>
	<FA332012-D83C-41BA-969D-2EA17A23C058@cray.com>
Message-ID: <0D0C00EC-C1C6-4360-BA73-730B97F2D85A@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

To clarify, the lnet_compare_routes() does look at peer credits, but only if priority, hops and queued nob are all the same. It would probably be better to weight all of these things together as was suggested at one of the developer conferences recently.

Chris Horn

On Aug 19, 2015, at 4:14 PM, Chris Horn <hornc at cray.com<mailto:hornc@cray.com>> wrote:

We could more easily help that situation by changing the lnet_compare_routes() method to look at the number of credits available when deciding which router peer to use as a next hop.

Chris Horn

On Aug 19, 2015, at 3:54 PM, Alexey Lyashkov <alexey.lyashkov at seagate.com<mailto:alexey.lyashkov@seagate.com>> wrote:

In my invested case, I have see large number tx in sending queue with negative credits. it's mean we don't able to resend these messages via different gateway until message expired. But if we stop to queue messages with reach a zero credits, we will able to send message via different gateway after peer dead event without any notifications to ptlrpc layer. So i think it's likely to be a bug as from my point view, we need to avoid ptlrpc reconnects as possible.

On Wed, Aug 19, 2015 at 11:48 PM, Christopher J. Morrone <morrone2 at llnl.gov<mailto:morrone2@llnl.gov>> wrote:
LNet does stop sending LNet messages on a peer connection when that peer's credit count reaches zero.  LNet chose to then relate the count of messages awaiting credits by using negative values of the same variable.  It is just the convention chosen, and doesn't necessarily mean that there is a design problem there.




--
Alexey Lyashkov ? Technical lead for a Morpheus team
Seagate Technology, LLC
www.seagate.com<http://www.seagate.com/>
www.lustre.org<http://www.lustre.org/>
_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20150819/6dae99f7/attachment.htm>
