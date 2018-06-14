From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Jun 2018 17:29:13 +1000
Subject: [lustre-devel] [PATCH v3] staging: lustre: Change return type
 to vm_fault_t
In-Reply-To: <CAFqt6zZJcN4=FDQSqiSznoEogavV9GBpqxx-onWG5Q3wQEM9cQ@mail.gmail.com>
References: <20180521180937.GA19605@jordon-HP-15-Notebook-PC>
 <CAFqt6zamp=+adkyM+_4z405hN-9qOn1CsY_BgVtCrAfscBHhWg@mail.gmail.com>
 <20180611205058.GA30123@kroah.com>
 <CAFqt6zZJcN4=FDQSqiSznoEogavV9GBpqxx-onWG5Q3wQEM9cQ@mail.gmail.com>
Message-ID: <87lgbhhlme.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Jun 12 2018, Souptick Joarder wrote:

> On 12-Jun-2018 2:21 AM, "Greg KH" <gregkh@linuxfoundation.org> wrote:
>>
>> On Tue, Jun 12, 2018 at 02:00:47AM +0530, Souptick Joarder wrote:
>> > On Mon, May 21, 2018 at 11:39 PM, Souptick Joarder <jrdr.linux@gmail.com>
>> >
>> > If no further comment, we would like to get this patch in 4.18-rc-X.
>>
>> Why?  Is it a regression fix?  That's all that is allowed after -rc1.
>
> No, this is not regression fix. We need to get this into 4.18-rc-1.  But
> mostly it can't make into linus tree in rc-1 :)
>>
>> And have you tried applying it to Linus's current tree?  :)
>
> Last tested on 4.17-rc-6 and it worked fine. Let me verify in current tree.
>

As you have undoubtedly noticed, lustre is no longer in Linus' tree.
I'm experimenting with maintaining a branch which retains the code
(lustre/* in github.com/neilbrown/linux) so we can get it ready for
merging properly.
I've added you patch to my tree.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180614/940a8594/attachment.sig>
