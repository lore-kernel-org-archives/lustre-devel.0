From: Andreas Dilger <adilger@sun.com>
Date: Thu, 20 Dec 2007 15:46:09 -0700
Subject: [Lustre-devel] SNS and existing Lustre striping.
In-Reply-To: <476AD60C.1080803@sun.com>
References: <200712202333.57536.alexander.zarochentsev@sun.com>
	<476AD60C.1080803@sun.com>
Message-ID: <20071220224609.GD3214@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Dec 20, 2007  13:52 -0700, Peter Braam wrote:
> I was hoping for 1. to keep things simple.

Presumably, an SNS layer would replace (or just extend?) the existing
LOV functionality on the clients.  We would definitely want to allow
existing RAID 0 striped files to be usable by having the SNS-aware client
understand the old LOV EA format, even if all new files are created with
an enhanced SNS EA format.

One feature that is quite desirable with SNS is to be able to add and
remove full mirrors of the file (as opposed to restriping to change the
layout in more complex ways) in an efficient manner.  Since this
functionality is already required to be able to reconstruct a missing
mirror copy of a file it seems relatively straightforward to create a
"ghost" mirror copy and then have the normal resync mechanism copy it.

More complex layout changes (e.g. RAID0 striping to RAID5/6) can be
done via the planned normal file migration/restripe mechanisms, and it
should be up to the administrator to do this, as for some cases (e.g.
scratch filesystem) it might not be worth the extra IO to restripe all
the files and instead leave it up to normal file aging/purge to catch
most of the files, and then have a later pass later to handle files that
have a longer lifetimes.

> Alexander Zarochentsev wrote:
> > Coming SNS feature somehow duplicates and extents existing Lustre 
> > striping functionality.  How will they (SNS and striping) coexist 
> > in the future versions of Lustre?
> >
> > I see 3 possible variants:
> >
> > 1. SNS replaces striping everywhere.
> > 2. one file can be SNS striped object or lustre striping object.
> > 3. one file can be SNS on top of Lustre-striping or Lustre-striping on 
> > SNS and, probably, one part of file can be SNS and another part is 
> > Lustre-striped.
> >
> > Does #3 makes any sense?
> >
> > I would prefer to assume that correct answer is (2) -- there are SNS 
> > files and Lustre-striped files, because Lustre-striped files probably 
> > have less overhead.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
