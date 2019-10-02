From: NeilBrown <neilb@suse.de>
Date: Wed, 02 Oct 2019 10:52:39 +1000
Subject: [lustre-devel] [PATCH 000/151] lustre: update to 2.11 support
In-Reply-To: <alpine.LFD.2.21.1910011904390.15141@casper.infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
 <87imp96jb8.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1910011904390.15141@casper.infradead.org>
Message-ID: <877e5o6ka0.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Oct 01 2019, James Simmons wrote:

>> > This patchset covers 3 areas. The fix 6 patches resolves critical
>> > bugs in the linux client. Mainly for handling of LNet with secondary
>> > IP aliases as well as an RCU issue reported with debugging enabled.
>> > This consoldation of IP handling makes any kernel API changes in the
>> > future easier to handle.
>> >
>> > The last 9 patches cover patches in the lustre-testing that landed
>> > to the OpenSFS branch.
>> >
>> > The rest of the patches cover all the patches missing from the
>> > Lustre 2.11 release. I have done extentsive testing of these
>> > patches (sanity, sanity-pfl, sanity-dom, sanity-pfl). Only
>> > regression I saw was sanity-flr 200 which needs to be investiaged.
>> > So we are in very good shape.
>> 
>> Thanks a lot for these James!
>> Though I only received up to 133/151 - are 18 missing, or was there a
>> miscount??
>
> Their should be 151 patches. I have had this problem of patches not making
> it to my mailbox. That is why I have:
>
> https://patchwork.kernel.org/project/lustre-devel/list
>
> All the patches are there.

So they are.  There is even a nice "series" line so I can grab them
call.
I wonder why they didn't get delivered to me ...

I've applied them all to my tree with no further issues. I'll push
something out later today.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20191002/5fe40eac/attachment.sig>
