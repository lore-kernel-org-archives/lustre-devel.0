From: Peter Braam <peter.braam@clusterstor.com>
Date: Tue, 15 Dec 2009 19:01:33 -0700
Subject: [Lustre-devel] client side reply handling
In-Reply-To: <3ed212d00912150828u2fc58cf2v541c95989d220a85@mail.gmail.com>
References: <2b20c7140912090705s47667951w26fe6c95e81f2c8f@mail.gmail.com>
	<3ed212d00912150828u2fc58cf2v541c95989d220a85@mail.gmail.com>
Message-ID: <2b20c7140912151801m78871060pd20e5136c105b507@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

No - buffers can and probably should (because, for example, re-delivery may
leaver buffer state undefined) be unlinked from the match list before
passing the buffer up to any other layer.  Portals/LNET certainly can do
this.

The question is why isn't this done, Eric, Isaac, Andreas?

Peter

On Tue, Dec 15, 2009 at 9:28 AM, Yuriy Umanets <
yuriy.umanets@clusterstor.com> wrote:

>
>
> 2009/12/9 Peter Braam <peter.braam@clusterstor.com>
>
>> Hi,
>>
>> hi Peter,
>
>
>> I wonder if LNET doesn't have an atomic operation that unlinks the packet
>> from the delivery process upon receiving a packet.   Iirc it does.  Why
>> wouldn't one use that?
>>
> That is probably because it still may be in use by upper layers (ptlrpc,
> etc), i.e. it is up to upper layer to decide should its buffers be still
> linked for access or not.
>
> Thanks.
>
>>
>> Peter
>>
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>
>>
>
>
> --
> umka
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20091215/21a6c9bb/attachment.htm>
