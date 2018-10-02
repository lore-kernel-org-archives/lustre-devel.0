From: NeilBrown <neilb@suse.com>
Date: Tue, 02 Oct 2018 13:41:26 +1000
Subject: [lustre-devel] [PATCH 00/34] lustre: remainder of multi-rail
 series.
In-Reply-To: <alpine.LFD.2.21.1809300305290.25547@casper.infradead.org>
References: <153783752960.32103.8394391715843917125.stgit@noble>
 <alpine.LFD.2.21.1809300305290.25547@casper.infradead.org>
Message-ID: <87efd9rp5l.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Sep 30 2018, James Simmons wrote:

>> Hi,
>>  following is the remainder of the Multi-Rail series, ported
>>  to drivers/staging.
>>  The previous series was only the first patch from upstream.
>>  This series is mostly the individual patches from upstream,
>>  though I did split some up a bit, and merged at least one bugfix back
>>  to where the bug was introduced.
>> 
>>  Comments, review, and explanations of bits I didn't understand, are
>>  most welcome.  I confess that I haven't looked at the code very
>>  closely, just a superficially scan for things that look odd (there
>>  weren't many).
>
> Thanks for doing this. It makes my life easier. With the patches:
>
> lustre: lnet: copy the correct amount of cpts to lnet_cpts
> lustre: lnd: resolve IP query code in LND drivers

I've moved these two to the top of the series.

>
> and the fixup in patch 11 it runs flawless in my testing. I do recommend
> land the two above patches first so no git bisect will end up blowing up
> someones nodes :-)
>
> Just have a bunch of commit recommendations. I noticed some MR patches
> landed to the main lustre branch. Perhaps those should be fixed as well.
> The only reason I ask is that I worry about kernel developers might not
> like that style of commit messages. In the past Greg pointed such things
> out to me. Thanks for hearing me out about that concern.

While I hope that this will eventually get merged by Linus pulling my
tree, complete with history, that might not work out.  New clean patches
might be required.
But if pulling my tree is an option, Greg (at least) cannot in good
faith complain about the commit messages or patch breakdown as he
explicitly said that we would be freed from that requirement by working
out-of-tree.  So I'm inclined not to put much effort into things that
don't benefit us now.

>
> I will poke Doug about looking at some of the commit messages you had
> concern about.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181002/2e4a2df7/attachment.sig>
