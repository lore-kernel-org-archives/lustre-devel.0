From: James Simmons <jsimmons@infradead.org>
Date: Thu, 7 Jun 2018 06:25:17 +0100 (BST)
Subject: [lustre-devel] A new drivers/staging/lustre
In-Reply-To: <874lifnxbp.fsf@notabene.neil.brown.name>
References: <874lifnxbp.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1806070557300.23188@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> Greg's patch to remove lustre has now landed in this staging-next tree,
> so I suspect it will get to Linus before too long.  So I have to find a
> new place to work on lustre.
> 
> I've added 2 branches to
>    git://git.neil.brown.name/linux
> 
> lustre:
>    is based on Greg's patch that removes lustre, and starts with a
>    revert of the patch, followed by a merge of v4.17.
>    I plan to merge each release and RC from Linus, and also
>    add lustre patches that I think are "ready".  That will usually mean
>    they have been posted to this list at least a week earlier, and
>    have not had a credible negative response (Acks and Reviewed-by
>    would be nice).
>    I plan to update this branch about once a week, and to never rebase
>    it.

I know Oleg also started to play with a tree but I don't know if he can
keep it up like you can. I added the parties interested so they can bless
this tree if they want. Mainly Oleg wanted to see what breaks when moving
to fs directory and the proper UAPI headers directory as well.

Please be patience with me. I normally do this work on the weekend. I put
it into my test bed and try it out. Getting reviews can at times be 
challenging to get. Hopefully people at Cray and Intel are willing to
step in for this as well. Patrick from Cray has been most helpful.

> lustre-testing:
>    is based on 'lustre' and has most of my current lustre-related work.
>    It includes assorted patches that are not specifically for lustre
>    (rhashtables mostly at the moment).  Patches will move from here
>    to 'lustre' or to mainline when they are ready.
>    I plan to update this branch on most days that I work on Lustre,
>    and expect it to rebase frequently.

I had question about that. Some things in Lustre could in theory be merged
into the linux kernel proper. Can that be done still?
 
> I'm happy to review and, if acceptable, apply patches from other
> developers.  I have fairly high standards, but if I don't accept your
> patch I'll explain why and possible help fix it.

Also long as you talk to me :-) I'm an easy person to work with. If I 
refuse a patch with do the same. I might sometimes seem irrational 
but I have valid reasons. Well at least in my head.

We need to really layout the roadmap.

> I'm happy to accept enhancements and new features, but these need
> to be of a quality that would be accepted upstream.

Absolutely. This should be music to some peoples ears. 

> I'm only interested in client-side code at present - nothing that is
> only used on the server.  I do want to include server-side eventually,
> but I need some focus for now.

Make sense. Anyways the backend file systems used are ldiskfs which is
a heavily modified ext4 filesystem and ZFS on the server side. I doubt
the kernel would accept ZFS backend suppport and the changes Lustre
does to ext4 have been mostly merged but a few pieces are missing.
So pushing the server code at this point wouldn't benefit us.

> I hope to get to a stage where the code is of suitable quality that I
> can submit it to Linux as a new filesystem.  I hope that will happen
> this year.

Are you thinking going back into staging or straight to the fs tree

> I hope we can continue to work together to make all this happen.
> (That's enough hope for now, time to get back to code).
