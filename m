From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Wed, 19 Aug 2015 13:48:49 -0700
Subject: [lustre-devel] Why can you set concurrent_sends < peer_credits ?
In-Reply-To: <CAJ2e-W3gt6SMjyCCZAkC_HyGmpNezZq4bqBRziwY-r45EeSPnw@mail.gmail.com>
References: <A6550817-BCC0-49D6-A259-067A4CCA87B7@cray.com>	<CAJ2e-W1S1FXnLLH30HOp=FzisXPy51eHJM+W+RYwmJVDcNjH1w@mail.gmail.com>	<04556C78-49F4-4A78-A477-ADE76C7773BB@cray.com>	<CAJ2e-W1ctBWG083t=pO=NmZwaiefx2eMJYqBpjC+K=HQ9PKJAg@mail.gmail.com>	<EBC6621B-E96B-43B4-AAE2-B3C445BC41FD@cray.com>
	<CAJ2e-W3gt6SMjyCCZAkC_HyGmpNezZq4bqBRziwY-r45EeSPnw@mail.gmail.com>
Message-ID: <55D4EBB1.3000502@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

As a quick aside to all developers: _This_ is why code comments are so 
important.  We can probably all figure out _what_ this code does, but 
without comments explaining _why_ it is doing what it does, the reader 
is spending way too much time trying to fathom what possible purpose 
this could be for.

LNet does stop sending LNet messages on a peer connection when that 
peer's credit count reaches zero.  LNet chose to then relate the count 
of messages awaiting credits by using negative values of the same 
variable.  It is just the convention chosen, and doesn't necessarily 
mean that there is a design problem there.

I think the major difference between o2iblnd's usage of peer_credits and 
concurrent_sends (besides being inverses of one another) is that 
peer_credits only counts outstanding LNet level messages, whereas 
concurrent_sends tracks _all_ outstanding sends that the o2iblnd puts on 
the wire for that peer.

The messages IBLND_MSG_PUT_NAK, IBLND_MSG_PUT_ACK, IBLND_MSG_PUT_DONE, 
and IBLND_MSG_GET_DONE do not use peer credits.  NOOP messages also skip 
using peer credits if the device support out-of-band messages.

So I would assume that there are some hardware devices out there with 
limitations that mean that we need to precisely count and limit the 
number of IB level sends in flight at one time.  Since some o2iblnd 
messaging skips using the peer credits value, that value did not server 
as a precise limit on the number of IB messages in flight.

As far as I can tell, routers don't have anything to do with this.

Chris

On 08/19/2015 12:54 PM, Alexey Lyashkov wrote:
> In credit based theory - credits should never to be less zero, as credit
> is resources to send. If credits set to zero we just stop send.
> My assumption base on book "Traffic Management for High-speed Networks
> International Science Lecture Series ; 4th Lecture".
>
>> This is counterintuitive, and I don?t understand why the code was written this way.
> if i understand correctly it code was originally written for a direct
> connected network, but credits distribution model forget to change when
> lnet routers was created. So we continue to count credits in peers base
> instead of distribute credits only in next hop base where a router
> should distribute a provided credits over connected clients. It provide
> a router overloading with huge parallel sends and new limit was added.
>
>
>
> On Wed, Aug 19, 2015 at 10:38 PM, Chris Horn <hornc@cray.com
> <mailto:hornc@cray.com>> wrote:
>
>>     But as i understand credit based flow control don't work now - i
>>     see several situations when server have a negative number a
>>     credits, which indicate we have sending queue more than limits and
>>     parallel sends limits will work in that situation..
>
>     Well, I think that depends on how the flow control is supposed to
>     work. The code definitely prevents *more* than peer_credits sends to
>     a single peer. And negative number of credits indeed indicates a
>     queue which, I think, is fine. What is non-obvious is that it
>     appears that the code may prevent fewer than peer_credits sends to a
>     single peer, even if there aren?t any other outstanding sends to
>     other peers. i.e. we hit the concurrent_sends limit before we hit
>     the peer_credits limit. This is counterintuitive, and I don?t
>     understand why the code was written this way.
>
>     Chris Horn
>
>>     On Aug 19, 2015, at 1:58 PM, Alexey Lyashkov
>>     <alexey.lyashkov at seagate.com <mailto:alexey.lyashkov@seagate.com>>
>>     wrote:
>>
>>     Chris,
>>
>>     In current code it's may be same. Let me finish some bugs before
>>     look to code. But with "good" code - you should have a different
>>     cost (credits count) for different messages. 1Mb bulk transfer
>>     should eats more credits than simple 4kb message. So you "should"
>>     have a two limits first one for parallel send with zero/low cost
>>     messages and second one for large messages.
>>     But as i understand credit based flow control don't work now - i
>>     see several situations when server have a negative number a
>>     credits, which indicate we have sending queue more than limits and
>>     parallel sends limits will work in that situation..
>>
>>     It's know bug for me but need large time to create a network model
>>     to create a correct credits distribution.
>>
>>
>>     On Wed, Aug 19, 2015 at 9:24 PM, Chris Horn<hornc@cray.com
>>     <mailto:hornc@cray.com>>wrote:
>>
>>         They sure look pretty related to me. In
>>         kiblnd_post_tx_locked() we return EAGAIN if ibc_nsends_posted
>>         == IBLND_CONCURRENT_SENDS. ibc_nsends_posted is incremented on
>>         every send. So it looks like you couldn?t ever send more than
>>         concurrent_sends messages to a single peer, which is exactly
>>         what peer_credits is supposed to govern, no?  What am I missing?
>>
>>         Chris Horn
>>
>>
>>>         On Aug 19, 2015, at 12:28 PM, Alexey Lyashkov
>>>         <alexey.lyashkov@seagate.com
>>>         <mailto:alexey.lyashkov@seagate.com>> wrote:
>>>
>>>         Chris,
>>>
>>>         concurrent_sends is measurement about parallel operations,
>>>         but credits is flow control artifact.
>>>         each operations may eats different number credits and
>>>         calculated in per link and per destination basic, so it's
>>>         completely different attributes.
>>>
>>>
>>>
>>>
>>>         On Wed, Aug 19, 2015 at 7:31 PM, Chris Horn<hornc@cray.com
>>>         <mailto:hornc@cray.com>>wrote:
>>>
>>>             A thread on HPDD-discuss made me think about this
>>>             question. AFAICT, the o2iblnd driver code will not let
>>>             you have more that concurrent_sends messages in flight at
>>>             the same time(in fact, we LASSERT on this fact in
>>>             kiblnd_check_sends). Thus peer_credits is effectively
>>>             limited by concurrent_sends anyways. What?s the reasoning
>>>             behind allowing peer_credits to be larger than
>>>             concurrent_sends?
>>>
>>>             Chris Horn
>>>             _______________________________________________
>>>             lustre-devel mailing list
>>>             lustre-devel at lists.lustre.org
>>>             <mailto:lustre-devel@lists.lustre.org>
>>>             http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>>>             <https://urldefense.proofpoint.com/v2/url?u=http-3A__lists.lustre.org_listinfo.cgi_lustre-2Ddevel-2Dlustre.org&d=AwMGaQ&c=IGDlg0lD0b-nebmJJ0Kp8A&r=m8P9AM2wTf4l79yg9e1LHD5IHagtwa3P4AXaemlM6Lg&m=mGEpe9i1Xe69mkwImOAP_rhH7F-u64SSh70zy-1fqz4&s=B9m6PgjBPBZiV_CIxXPJRU5EoTEXV1rQYtuQGjwcOiU&e=>
>>>
>>>
>>>
>>>
>>>         --
>>>         Alexey Lyashkov *?* Technical lead for a Morpheus team
>>>         Seagate Technology, LLC
>>>         www.seagate.com <http://www.seagate.com/>
>>>         www.lustre.org
>>>         <https://urldefense.proofpoint.com/v2/url?u=http-3A__www.lustre.org_&d=AwMGaQ&c=IGDlg0lD0b-nebmJJ0Kp8A&r=m8P9AM2wTf4l79yg9e1LHD5IHagtwa3P4AXaemlM6Lg&m=mGEpe9i1Xe69mkwImOAP_rhH7F-u64SSh70zy-1fqz4&s=ndWLD_9DiIMxtYFvQrJRumfN-MZTMVBJQdeid6tdKAw&e=>
>>
>>
>>
>>
>>     --
>>     Alexey Lyashkov *?* Technical lead for a Morpheus team
>>     Seagate Technology, LLC
>>     www.seagate.com <http://www.seagate.com/>
>>     www.lustre.org
>>     <https://urldefense.proofpoint.com/v2/url?u=http-3A__www.lustre.org_&d=AwMGaQ&c=IGDlg0lD0b-nebmJJ0Kp8A&r=m8P9AM2wTf4l79yg9e1LHD5IHagtwa3P4AXaemlM6Lg&m=xj-N9a-E5CgJ_rYAs23V93tTuZ1HyQw2yltXnCNAgSI&s=HES5frmlzutMi-g6kgm_00bfdDBM6r3ot5yMOL5buP0&e=>
>
>
>
>
> --
> Alexey Lyashkov *?* Technical lead for a Morpheus team
> Seagate Technology, LLC
> www.seagate.com <http://www.seagate.com>
> www.lustre.org <http://www.lustre.org>
>
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>
