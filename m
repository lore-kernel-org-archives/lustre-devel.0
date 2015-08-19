From: Alexey Lyashkov <alexey.lyashkov@seagate.com>
Date: Wed, 19 Aug 2015 23:54:57 +0300
Subject: [lustre-devel] Why can you set concurrent_sends < peer_credits ?
In-Reply-To: <55D4EBB1.3000502@llnl.gov>
References: <A6550817-BCC0-49D6-A259-067A4CCA87B7@cray.com>
	<CAJ2e-W1S1FXnLLH30HOp=FzisXPy51eHJM+W+RYwmJVDcNjH1w@mail.gmail.com>
	<04556C78-49F4-4A78-A477-ADE76C7773BB@cray.com>
	<CAJ2e-W1ctBWG083t=pO=NmZwaiefx2eMJYqBpjC+K=HQ9PKJAg@mail.gmail.com>
	<EBC6621B-E96B-43B4-AAE2-B3C445BC41FD@cray.com>
	<CAJ2e-W3gt6SMjyCCZAkC_HyGmpNezZq4bqBRziwY-r45EeSPnw@mail.gmail.com>
	<55D4EBB1.3000502@llnl.gov>
Message-ID: <CAJ2e-W0h9HfHrrcOkimoHWhpNiAMzdo_C1WNinLLbGeLBF9X5A@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

In my invested case, I have see large number tx in sending queue with
negative credits. it's mean we don't able to resend these messages via
different gateway until message expired. But if we stop to queue messages
with reach a zero credits, we will able to send message via different
gateway after peer dead event without any notifications to ptlrpc layer. So
i think it's likely to be a bug as from my point view, we need to avoid
ptlrpc reconnects as possible.

On Wed, Aug 19, 2015 at 11:48 PM, Christopher J. Morrone <morrone2@llnl.gov>
wrote:

> LNet does stop sending LNet messages on a peer connection when that peer's
> credit count reaches zero.  LNet chose to then relate the count of messages
> awaiting credits by using negative values of the same variable.  It is just
> the convention chosen, and doesn't necessarily mean that there is a design
> problem there.
>




-- 
Alexey Lyashkov *?* Technical lead for a Morpheus team
Seagate Technology, LLC
www.seagate.com
www.lustre.org
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20150819/ab345067/attachment.htm>
