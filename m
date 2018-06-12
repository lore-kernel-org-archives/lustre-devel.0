From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Wed, 13 Jun 2018 00:41:12 +0530
Subject: [lustre-devel] [PATCH v3] staging: lustre: Change return type
 to vm_fault_t
In-Reply-To: <20180611210714.GB4023@kroah.com>
References: <20180521180937.GA19605@jordon-HP-15-Notebook-PC>
 <CAFqt6zamp=+adkyM+_4z405hN-9qOn1CsY_BgVtCrAfscBHhWg@mail.gmail.com>
 <20180611205058.GA30123@kroah.com>
 <CAFqt6zZJcN4=FDQSqiSznoEogavV9GBpqxx-onWG5Q3wQEM9cQ@mail.gmail.com>
 <20180611210714.GB4023@kroah.com>
Message-ID: <CAFqt6zYyy2yygmU+_KSNydjkW8V7A5oefcpMyMrFDd=2q1Ppdw@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Jun 12, 2018 at 2:37 AM, Greg KH <gregkh@linuxfoundation.org> wrote:
> On Tue, Jun 12, 2018 at 02:30:27AM +0530, Souptick Joarder wrote:
>> > >
>> > > If no further comment, we would like to get this patch in 4.18-rc-X.
>> >
>> > Why?  Is it a regression fix?  That's all that is allowed after -rc1.
>>
>> No, this is not regression fix. We need to get this into 4.18-rc-1.  But
>> mostly it can't make into linus tree in rc-1 :)
>
> Why does it _have_ to get into 4.18-rc1?  My tree is long-closed and
> Linus already has all of my patches in his tree for the staging section
> of the kernel.
>
>> > And have you tried applying it to Linus's current tree?  :)
>>
>> Last tested on 4.17-rc-6 and it worked fine. Let me verify in current tree.
>
> Try it, you might be surprised :)

Yes, got the surprise :)
Sorry for making noise, I will drop this patch as it is no more valid
in current Linus's tree.
