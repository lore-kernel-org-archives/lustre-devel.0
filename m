From: Deepa Dinamani <deepa.kernel@gmail.com>
Date: Tue, 16 Aug 2016 11:18:52 -0700
Subject: [lustre-devel] [GIT PULL] [PATCH v4 00/26] Delete CURRENT_TIME
 and CURRENT_TIME_SEC macros
In-Reply-To: <20160815162312.GA19794@kroah.com>
References: <1471128518-24075-1-git-send-email-deepa.kernel@gmail.com>
	<20160815162312.GA19794@kroah.com>
Message-ID: <CABeXuvp027DZR0=zQPp86oGdi2B+Gh16z8_FyoY5UDUdHXAngA@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Cc: Dave Kleikamp <shaggy-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, jfs-discussion-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>, Adrian Hunter <adrian.hunter-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Chris Mason <clm-b10kYP2dOMg@public.gmane.org>, Andreas Dilger <adilger.kernel-m1MBpc4rdrD3fQ9qLvQP4Q@public.gmane.org>, Brian Uchino <buchino-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, "Yan, Zheng" <zyan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "James E.J. Bottomley" <jejb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>, Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, y2038 Mailman List <y2038-cunTk1MwBs8s++Sfvej+rw@public.gmane.org>, Ilya Dryomov <idryomov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Changman Lee <cm224.lee-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>, Evgeniy Dushistov <dushistov-JGs/UdohzUI@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Mark Fasheh <mfasheh-IBi9RG/b67k@public.gmane.org>, Suma Ramars <sramars-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>, John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, David Sterba <dsterba-IBi9RG/b67k@public.gmane.org>, Jaegeuk Kim <jaege>

Thank you for the suggestion.

> Who are you execting to pull this huge patch series?

The last pull request was addressed to Al as per Arnd's suggestion.
I'm not completely sure who should it be addressed to.

> Why not just introduce the new api call, wait for that to be merged, and
> then push the individual patches through the different subsystems?
> After half of those get ignored, then provide a single set of patches
> that can go through Andrew or my trees.

Arnd and I tried to do this a few ways.

We can try to introduce the api first like you suggest.

There are a few Acks already on the patches.
And, patches 2-5 also need to be merged through some common tree like
yours or Andrew's as you suggest.

So, if everyone is ok, I could do the following:

1. Post patches 1-5 for rc-2.
2. Post all other patches to respective maintainers after rc-2
3. Then after patches get ignored or merged, post remaining as a
series for you or Andrew to pick up.

-Deepa
