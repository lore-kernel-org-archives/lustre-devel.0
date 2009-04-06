From: Nikita Danilov <danilov@gmail.com>
Date: Mon, 6 Apr 2009 11:43:01 +0400
Subject: [Lustre-devel] OSD iterator interface
In-Reply-To: <m3tz526ycz.fsf@bzzz.home.net>
References: <E14DEA02-826C-4F15-8A22-9FA616EFDBC4@Sun.COM>
	<49D51B32.2020404@sun.com> <m3tz526ycz.fsf@bzzz.home.net>
Message-ID: <8acda98c0904060043j289382dfodea4616cb6883f9c@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

2009/4/6 Alex Zhuravlev <bzzz@sun.com>

Hello,


> I agree with what Oleg said. I think there are two-stages processing here:
> 1) osd should be able to clean "value" from compatibility stuff like inodes
> 2) mdd should be able to store this value in own buffer in, possible, some
>   efficient form
>
> >>>>> di wang (dw) writes:
>

[...]


>
>  >>
>  >> Am I missing something stupid? Are there any objections, would
>  >> this break anything?
>

the  reason dt_it_ops have one-entry-at-a-time interface is that originally
iterators were able to update indices as well. *E.g.*, it was expected that
/orphan index processing would read one entry, handle it, and then delete it
from the index (a possibly mistaken belief in the virtue of simplicity and
evilness of premature optimization also played its r?le). Eventually all
existing use cases for the updating iterators were eliminated and ->set_*()
methods were dropped from dt_it_ops.


>  >>
>  >> Bye,
>  >> Oleg
>

Nikita.
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20090406/5b040647/attachment.htm>
