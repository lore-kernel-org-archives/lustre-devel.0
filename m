From: Nikita Danilov <danilov@gmail.com>
Date: Thu, 9 Apr 2009 12:58:41 +0400
Subject: [Lustre-devel] WBC HLD outline
In-Reply-To: <200904082041.28945.alexander.zarochentsev@sun.com>
References: <200903240058.30343.alexander.zarochentsev@sun.com>
	<m3k55x3rik.fsf@bzzz.home.net>
	<8acda98c0904070050p269492eeq89f18191997f230@mail.gmail.com>
	<200904082041.28945.alexander.zarochentsev@sun.com>
Message-ID: <8acda98c0904090158k722a13c5o96d624671734f7e2@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

2009/4/8 Alexander Zarochentsev <Alexander.Zarochentsev@sun.com>

> Hello Nikita!
>
> On 7 April 2009 11:50:29 Nikita Danilov wrote:
> > 2009/4/7 Alex Zhuravlev <bzzz@sun.com>
> >
> > > >>>>> Andreas Dilger (AD) writes:
> >
> > Hello,
> >
>

[...]


> > $ echo > a/b/c/d/file # truncate secret data
> > $ chmod 777 a # relax permissions
> >
> > Note that here an ordering between data and meta-data updates on
> > _different_ objects is important.
>
> If we only guarantee no reordering in MD updates, Lustre behavior would
> be like ext3 without data journalling? I think it is not terrible.


It's not terrible, but it is non-intuitive, in my opinion. More enlightened
file systems, like ZFS, reiser4, and NTFS provide stronger consistency
guarantees, ignoring the petty distinctions between data and meta-data. :-)

But even limiting consistency to meta-data leaves some issues opened. For
example, think about an md proxy server acting as a WBC client for a higher
tier server. To be efficient such proxy might need to cache very large
amount of meta-data, and it most likely cannot afford to keep a log of all
operations. In this situation, when a lock on a top-level directory gets a
blocking AST, proxy would have --to guarantee ordering of visible meta-data
updates-- to write back all cached dirty meta-data under this directory
before the lock can be cancelled, which might result in unacceptable
latency.

>
> > > thanks, Alex
> >
> > Nikita.
>
> --
> Alexander "Zam" Zarochentsev
>

Nikita.
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20090409/ffcd5ed0/attachment.htm>
