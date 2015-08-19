From: Chris Horn <hornc@cray.com>
Date: Wed, 19 Aug 2015 18:24:41 +0000
Subject: [lustre-devel] Why can you set concurrent_sends < peer_credits ?
In-Reply-To: <CAJ2e-W1S1FXnLLH30HOp=FzisXPy51eHJM+W+RYwmJVDcNjH1w@mail.gmail.com>
References: <A6550817-BCC0-49D6-A259-067A4CCA87B7@cray.com>
	<CAJ2e-W1S1FXnLLH30HOp=FzisXPy51eHJM+W+RYwmJVDcNjH1w@mail.gmail.com>
Message-ID: <04556C78-49F4-4A78-A477-ADE76C7773BB@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

They sure look pretty related to me. In kiblnd_post_tx_locked() we return EAGAIN if ibc_nsends_posted == IBLND_CONCURRENT_SENDS. ibc_nsends_posted is incremented on every send. So it looks like you couldn?t ever send more than concurrent_sends messages to a single peer, which is exactly what peer_credits is supposed to govern, no?  What am I missing?

Chris Horn


On Aug 19, 2015, at 12:28 PM, Alexey Lyashkov <alexey.lyashkov at seagate.com<mailto:alexey.lyashkov@seagate.com>> wrote:

Chris,

concurrent_sends is measurement about parallel operations, but credits is flow control artifact.
each operations may eats different number credits and calculated in per link and per destination basic, so it's completely different attributes.




On Wed, Aug 19, 2015 at 7:31 PM, Chris Horn <hornc at cray.com<mailto:hornc@cray.com>> wrote:
A thread on HPDD-discuss made me think about this question. AFAICT, the o2iblnd driver code will not let you have more that concurrent_sends messages in flight at the same time(in fact, we LASSERT on this fact in kiblnd_check_sends). Thus peer_credits is effectively limited by concurrent_sends anyways. What?s the reasoning behind allowing peer_credits to be larger than concurrent_sends?

Chris Horn
_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org



--
Alexey Lyashkov ? Technical lead for a Morpheus team
Seagate Technology, LLC
www.seagate.com<http://www.seagate.com/>
www.lustre.org<http://www.lustre.org/>

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20150819/a84ff708/attachment.htm>
