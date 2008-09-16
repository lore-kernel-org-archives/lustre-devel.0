From: Eric Barton <eeb@sun.com>
Date: Tue, 16 Sep 2008 12:05:56 +0100
Subject: [Lustre-devel] CMD directory split
In-Reply-To: <20080916082246.GN3241@webber.adilger.int>
References: <20080912071835.GP3086@webber.adilger.int>
	<1FEE196D-471A-4D96-A722-1479B7192ACF@Sun.COM>
	<245E1B64-9341-48B9-B6A4-E88153D5B7A7@Sun.COM>
	<20080915021630.GB4090@webber.adilger.int>
	<18638.14045.141758.231275@gargle.gargle.HOWL>
	<20080916082246.GN3241@webber.adilger.int>
Message-ID: <831F789FF0CC4FFD8D5C15DC082731AF@ebpc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Guys,

I'm cc-ing lustre-devel - it's of general interest.

I definitely think the first CMD product releases should stick to
static directory layouts with all directories contained within a
single MDT by default - i.e. you have to do something special to
create a striped dir.  Meanwhile we should start ASAP on completing
the design of automatic dir splitting to handle _all_ the recovery
cases.

IMHO, a one-time-only directory split seems a bit too all-or-nothing.
What is the reasoning behind the assumption that further splitting is
not required?  Also, directory size doesn't necessarily seem like the
only or even the best clue about when to split and how.  So here are a
couple of suggestions.

1. Consider the split from 1 MDT to several just as a special case of
   migration - i.e. allow arbitrary n->m re-layout over MDTs.  We
   would like to support metadata migration in any case for space
   management.  Andreas' ideas about migration by mirroring seem
   equally applicable to directories (furthermore mirrored directories
   seem like a valuable component of a namespace availability and
   resilience feature).

2. Keep the discussion on policy (when to split) separate from
   mechanism (how to split).

    Cheers,
              Eric

> 
> -----Original Message-----
> From: Andreas.Dilger at Sun.COM [mailto:Andreas.Dilger at Sun.COM] On Behalf Of Andreas Dilger
> Sent: 16 September 2008 9:23 AM
> To: Nikita Danilov
> Cc: Yury Umanets; Eric Barton; Alex Zhuravlev
> Subject: Re: CMD directory split
> 
> On Sep 15, 2008  14:20 +0400, Nikita Danilov wrote:
> > Andreas Dilger writes:
> >  > I think we can have a very simple directory split if we
> >  > consider the directory split like file IO instead of inserting
> >  > thousands of dirents.
> > 
> > In some sense this is already done. Split (cmm/cmm_split.c) uses
> > the same interface as readdir to construct a pagesful of directory
> > entries and to send them to a slave mdt, where they are
> > inserted. It is not raw `write', because actual directory page
> > format is encapsulated within osd
> 
> Yes, I was thinking of something like this, I didn't know that is
> how it is actually handled.  The other issue is that the directory
> creation and insertions should be done in a single transaction in
> order to simplify recovery.  In that case we don't have to worry
> about the case where the directory is partially created and
> populated.
> 
> > It's my impression that other source of trouble with split is a
> > complicated locking scheme that it requires to keep clients happy.
> 
> How is the locking of the directory any different than the locking
> on the LOV EA needed to restripe a file for migration?  The locks on
> the inodes themselves do not change, because the inodes are not
> moving.  The pages on the directory itself are revoked on a regular
> basis whenever there is a new insertion in any case (i.e. when the
> directory is split).
> 
> It would seem that the only thing which needs to be changed is the
> LMV EA on the clients.
> 
> > It would be _much_ easier if directories were split at the time of
> > creation like files are. That would also eliminate almost all
> > recovery issues and page-shuffling mechanics.
> 
> This might be possible for a simple initial implementation, but it
> isn't a good long-term solution.  Consider the problems we face even
> today with widely-striped files - stat slowdowns to track the
> size/mtime/ctime, readdir will always have to do RPCs to each MDT to
> get the entries even if there are only a few entries, unlinks will
> need multiple RPCs, etc.
> 
> In contrast, we can tune the split threshold so that the majority of
> small directories remain on a single MDT, and only large directories
> are split (with some small overhead for the split).
> 
> In the future we have to consider configurations with hundreds or
> even thousands of MDTs, perhaps one on each OST, in order to scale
> metadata and small file performance dramatically.
> 
> Cheers, Andreas
> --
> Andreas Dilger
> Sr. Staff Engineer, Lustre Group
> Sun Microsystems of Canada, Inc.
> 
> 
