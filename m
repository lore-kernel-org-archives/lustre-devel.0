From: NeilBrown <neilb@suse.de>
Date: Wed, 29 Apr 2020 13:32:31 +1000
Subject: [lustre-devel] [PATCH 000/622] lustre: sync closely to 2.13.52
In-Reply-To: <alpine.LFD.2.21.2004280119520.27227@casper.infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
 <87r1wdqv59.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.2004280119520.27227@casper.infradead.org>
Message-ID: <87pnbrj7ao.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Apr 28 2020, James Simmons wrote:

>> > These patches need to be applied to the lustre-backport branch
>> > starting at commit a436653f641e4b3e2841f38113620535e918dd3f.
>> 
>> Hi James et al,
>>  I applied these patches on top of a43.... then added the other patches I
>>  had an looked for difference to my previous tree.
>>  I found a bunch of improvements you had made, plus some errors that
>>  came through your patches, plus some other problems that already
>>  existed...
>> 
>>  I've then added patches from OpenSFS master to get uptodate.
>>  The result is not on my github tree in the lustre/lustre branch.  It
>>  has 226 patches on top of the set you posted.
>> 
>>  git log 823691f8d49c~3..823691f8d49c
>> 
>>  will show you some error I fixed, in case you are interested.
>
> I grabbed those fixes and applied them to my tree. Its nice to see my 
> tree, your tree, and the OpenSFS branch starting to merge. I updated
> my tree to the same OpenSFS commit as your tree and have started to look 
> at difference. I noticed the sync with my tree didn't exactly match up. 
> You lost a few changes. Some of the major changes missing are
>
> 1) LU-9679 llite: Discard LUSTRE_FPRIVATE()
>    OpenSFS hash : 9e5cb57addbb5d7bc1596096821ad8dcac7a939b

Thanks.  I've also added

2bea4a7a3706 LU-5432 fld: don't loop forever on bogus FID sequences
2f66b4903516 LU-7768 fld: Do not retry fld request
8d4ef45e0780 LU-7524 fld: fld_clientlookup retries next target

which I had found by comparison myself but not applied yet.

> 2) LU-13274 uapi: make lnet UAPI headers C99 compliant 
>    OpenSFS hash: 742897a967cff5be53c447d14b17ae405c2b31f2

I have that...
Commit 619f523e5c36 ("lustre: uapi: make lnet UAPI headers C99 compliant")

What did I miss?

>
> Also their are some kmem_cache bugs that causes several of the sanity
> test to crash the client. I need to do more comparing of our tree and
> sort out the changes that haven't landed or been pushed to the OpenSFS 
> branch to figure out these regressions. I can easily see in the 4 to 8 
> weeks all the patches in your tree to land to OpenSFS as well as my tree. 
> So we could sort everything out once everything has landed. I need to 
> pull a few changes you have as well to my tree for cleanups like for the 
> fid layer that seem to have gotten lost. Mostly likely from people doing
> cleanups while in staging.
>
> Now for some important info. I noticed sanity test failing recently
> which I tracked down to me not updating my lustre utilities. This is
> going to be a problem so to make it painless I created a few patches
> to enable building the lustre utilies only against the linux
> client. If you apply the following patches:
>
> https://review.whamcloud.com/#/c/38369
> https://review.whamcloud.com/#/c/38370

This one:
 LU-12511 build: don't use OpenSFS UAPI headers with --disable-modules

doesn't seem like a good thing.  It implies that the UAPI headers in
OpenSFS give different results than the ones in Linux.
If this is true - we need to fix it. The UAPI needs to be stable.

Do you know what the important differences are.

> https://review.whamcloud.com/#/c/38105
> https://review.whamcloud.com/#/c/36603
> https://review.whamcloud.com/#/c/34954
>
> Now for 33603 patch it exposes a regression with LSOM and 
> open_by_handle_at(). This patch removes the need for dot_lustre which is 
> broken anyways for submounts (filesets). The 'dot_lustre' in the UAPI 
> header is used for general utilites as well as the kernel server code. 
> Since it had no use in the linux client it was nuked :-) Instead of 
> restoring it we can resolve the LSOM issues for 33603 patch.
>
> Once you apply the above patches just run:
>
> sh autogen.sh
> ./configure --disable-modules --disable-server
> make rpms
>
> and you will have proper rpms to use with the linux client. I recommend
> after updating the linux client to update your utilities as well 
> everytime.

Thanks from the thorough response.  I'll keep this in mind when I next
refresh my linux test setup.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20200429/cb1f1b9a/attachment.sig>
