From: Alexey Lyashkov <alexey.lyashkov@seagate.com>
Date: Wed, 19 Aug 2015 21:58:49 +0300
Subject: [lustre-devel] Why can you set concurrent_sends < peer_credits ?
In-Reply-To: <04556C78-49F4-4A78-A477-ADE76C7773BB@cray.com>
References: <A6550817-BCC0-49D6-A259-067A4CCA87B7@cray.com>
	<CAJ2e-W1S1FXnLLH30HOp=FzisXPy51eHJM+W+RYwmJVDcNjH1w@mail.gmail.com>
	<04556C78-49F4-4A78-A477-ADE76C7773BB@cray.com>
Message-ID: <CAJ2e-W1ctBWG083t=pO=NmZwaiefx2eMJYqBpjC+K=HQ9PKJAg@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Chris,

In current code it's may be same. Let me finish some bugs before look to
code. But with "good" code - you should have a different cost (credits
count) for different messages. 1Mb bulk transfer should eats more credits
than simple 4kb message. So you "should" have a two limits first one for
parallel send with zero/low cost messages and second one for large messages.
But as i understand credit based flow control don't work now - i see
several situations when server have a negative number a credits, which
indicate we have sending queue more than limits and parallel sends limits
will work in that situation..

It's know bug for me but need large time to create a network model to
create a correct credits distribution.


On Wed, Aug 19, 2015 at 9:24 PM, Chris Horn <hornc@cray.com> wrote:

> They sure look pretty related to me. In kiblnd_post_tx_locked() we return
> EAGAIN if ibc_nsends_posted == IBLND_CONCURRENT_SENDS. ibc_nsends_posted is
> incremented on every send. So it looks like you couldn?t ever send more
> than concurrent_sends messages to a single peer, which is exactly what
> peer_credits is supposed to govern, no?  What am I missing?
>
> Chris Horn
>
>
> On Aug 19, 2015, at 12:28 PM, Alexey Lyashkov <alexey.lyashkov@seagate.com>
> wrote:
>
> Chris,
>
> concurrent_sends is measurement about parallel operations, but credits is
> flow control artifact.
> each operations may eats different number credits and calculated in per
> link and per destination basic, so it's completely different attributes.
>
>
>
>
> On Wed, Aug 19, 2015 at 7:31 PM, Chris Horn <hornc@cray.com> wrote:
>
>> A thread on HPDD-discuss made me think about this question. AFAICT, the
>> o2iblnd driver code will not let you have more that concurrent_sends
>> messages in flight at the same time(in fact, we LASSERT on this fact in
>> kiblnd_check_sends). Thus peer_credits is effectively limited by
>> concurrent_sends anyways. What?s the reasoning behind allowing peer_credits
>> to be larger than concurrent_sends?
>>
>> Chris Horn
>> _______________________________________________
>> lustre-devel mailing list
>> lustre-devel at lists.lustre.org
>> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>> <https://urldefense.proofpoint.com/v2/url?u=http-3A__lists.lustre.org_listinfo.cgi_lustre-2Ddevel-2Dlustre.org&d=AwMGaQ&c=IGDlg0lD0b-nebmJJ0Kp8A&r=m8P9AM2wTf4l79yg9e1LHD5IHagtwa3P4AXaemlM6Lg&m=mGEpe9i1Xe69mkwImOAP_rhH7F-u64SSh70zy-1fqz4&s=B9m6PgjBPBZiV_CIxXPJRU5EoTEXV1rQYtuQGjwcOiU&e=>
>>
>
>
>
> --
> Alexey Lyashkov *?* Technical lead for a Morpheus team
> Seagate Technology, LLC
> www.seagate.com
> www.lustre.org
> <https://urldefense.proofpoint.com/v2/url?u=http-3A__www.lustre.org_&d=AwMGaQ&c=IGDlg0lD0b-nebmJJ0Kp8A&r=m8P9AM2wTf4l79yg9e1LHD5IHagtwa3P4AXaemlM6Lg&m=mGEpe9i1Xe69mkwImOAP_rhH7F-u64SSh70zy-1fqz4&s=ndWLD_9DiIMxtYFvQrJRumfN-MZTMVBJQdeid6tdKAw&e=>
>
>
>


-- 
Alexey Lyashkov *?* Technical lead for a Morpheus team
Seagate Technology, LLC
www.seagate.com
www.lustre.org
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20150819/c28d78f8/attachment-0001.htm>
