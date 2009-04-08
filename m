From: Alexander Zarochentsev <Alexander.Zarochentsev@Sun.COM>
Date: Wed, 08 Apr 2009 20:41:28 +0400
Subject: [Lustre-devel] WBC HLD outline
In-Reply-To: <8acda98c0904070050p269492eeq89f18191997f230@mail.gmail.com>
References: <200903240058.30343.alexander.zarochentsev@sun.com>
	<m3k55x3rik.fsf@bzzz.home.net>
	<8acda98c0904070050p269492eeq89f18191997f230@mail.gmail.com>
Message-ID: <200904082041.28945.alexander.zarochentsev@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello Nikita!

On 7 April 2009 11:50:29 Nikita Danilov wrote:
> 2009/4/7 Alex Zhuravlev <bzzz@sun.com>
>
> > >>>>> Andreas Dilger (AD) writes:
>
> Hello,
>
> >  AD> On Apr 06, 2009  13:23 +0300, Alexander Zarochentsev wrote:
> >  >> On 1 April 2009 12:17:17 Eric Barton wrote:
> >  >> I think we can't avoid tagging OST object creation w/ epoch
> >  >> counter. Would Lustre users complain if file writes are
> >  >> out-of-epochs?
> >  >>
> >  >> There is a security problem with out-of-epochs writes and
> >  >> setting file attributes (especially permissions):
> >  >> chmod 400 foo; cat /etc/secret-file >> foo. Chmod/chown can be
> >  >> a
> >
> > special
> >
> >  >> case which triggers wbc flush.
> >
> >  AD> While this example has been given many times as a security
> > issue that AD> forces many strange actions on the part of Lustre,
> > the example is AD> fundamentally broken because POSIX allows "foo"
> > to be opened before the
> >  AD> chmod, and kept open until after the write and then read the
> > "secret-file"
> >  AD> content.  The "foo" file needs to be created securely in the
> > first place
> >  AD> to be safe.
>
> the original "partial write-back" problem was demonstrated with the
> use case
>
> $ mkdir -m 0700 a # nobody but me can access things under "a"
> $ umask 000
> $ mkdir -m 0777 -p a/b/c/d
> $ echo "secret data" > a/b/c/d/file
> $ sync # time passes...
> $ echo > a/b/c/d/file # truncate secret data
> $ chmod 777 a # relax permissions
>
> Note that here an ordering between data and meta-data updates on
> _different_ objects is important.

If we only guarantee no reordering in MD updates, Lustre behavior would 
be like ext3 without data journalling? I think it is not terrible.

> > yup, and there is no way in posix to even check whether file is
> > opened.
> >
> > my take on this and similar security related issues is that we
> > probably should provide two modes:
> > 1) strict, when no optimizations in order of flush is done
> > 2) relaxed, when order is not garanteed and user should use some
> > form of sync
> >   but lustre can improve performance
>
> The old (and outdated) WBC HLD has a section "Partial write-out"
> describing these issues.
>
> --
>
> > thanks, Alex
>
> Nikita.

-- 
Alexander "Zam" Zarochentsev
Staff Engineer
Lustre Group, Sun Microsystems
