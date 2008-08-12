From: Kevan <kfr@sgi.com>
Date: Tue, 12 Aug 2008 11:40:48 -0700 (PDT)
Subject: [Lustre-devel] Summary of our HSM discussion
In-Reply-To: <C4BCA140.5486%peter.braam@sun.com>
References: <C4BCA140.5486%peter.braam@sun.com>
Message-ID: <ad5eac64-b140-4ebc-9e78-0e4e7baa924b@k13g2000hse.googlegroups.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Peter,

Apologies, but I am having some difficulty determining where the
boundary
between Lustre and the HSM lies within the first release.  Plus I have
a few newbie Lustre questions.

I think your #4 is saying that Lustre will still provide a Space
Manager in
the first release, responsible for monitoring filesystem fullness,
using
e2scan to pick archive/purge candidates and issuing archive/purge
requests
to the HSM, that these tasks are not performed by the HSM itself.
True?
Is the Space Manager logic part of the Coordinator, or is it a
separate entity?
Is there one Coordinator/Space Manager pair per filesystem or one
total
per site?

Users will need commands that allow them to archive and recall their
files
and/or directory subtrees, and they will want commands like ls and
find
that show them the current HSM archive/purge state of their files so
that
they can pre-stage purged files before they are needed, and so that
they
can purge unneeded files to effectively manage their own quotas.  Will
these
commands be provided by Lustre, or by the HSM?

Given that files are only recalled on open, this implies that a file
which
is open for either read or write by any client can never be purged,
correct?
And a file open for write by any client should never be archived since
it
could be silently changing while the archive is in progress.  And if
a file is opened for write after an archive has begun, the HSM will
be sent a cancel request?  Is the necessary information available to
the
Space Manager and/or Coordinator so that these rules can be enforced?

The HSM data mover needs to be able to open a file by FID without
encountering the adaptive timeout that other users are seeing.  The
data
mover's I/Os must not change the file's read and write timestamps.
The
data mover needs a get_extents(int fd) function to read the file's
extent
map so that it can find the location of holes in sparse files and
preserve
those holes within its HSM copies.  Is there an interface available
that
provides this functionality?

In the FID HLD I find mention of a object version field within the
FID,
which apparently gets incremented with each modification of the file.
Is that currently implemented in Lustre?  I'm thinking of the case
where
a file is archived, recalled, modified, archived, recalled,
modified...
The HSM will need a way to map the correct HSM copies to the correct
version
of the file, so hopefully the version field is already supported.

Does Lustre already support snapshot capabilities, or will it in the
future?
When a snapshot is made, each archived/purged file within the snapshot
effectively creates another reference to its copies within the HSM
database.
An HSM file copy cannot be removed until it is known that no
references
remain to that particular version of the file, either within the live
filesystem or within any snapshot.  Will the Coordinator be able to
see the
snapshot references, and avoid sending delete requests to the HSM
until all
snapshot references for a particular file version have been removed?
Are snapshots read-write or read-only?  If read-only, how to you
intend to
have users access purged files in snapshots?

I haven't been able to figure out how backup/restore works, or will
work
in Lustre.  Standard utilities like tar will wreak havoc by triggering
file recall storms within the HSM.  Better is an intelligent backup
package
which understands that the HSM already has multiple copies of the file
data,
and so the backup program only needs to back up the metadata.  The
problem
here again is that new references to the HSM copies are being created,
yet those
references are not visible to the HSM, it doesn't know they exist, so
methods are needed to ensure that seemly-obsolete HSM copies are not
deleted before the backups that reference them have also been deleted.
If you could provide a short description of how you intend backup/
restore to
work in combination with an HSM, or if you could provide pointers,
that would
be great.

Regards, Kevan

On Aug 4, 1:06 pm, Peter Braam <Peter.Br...@Sun.COM> wrote:
> We spoke about the HSM plans some 10 days ago.  I think that the conclusions
> are roughly as follows:
>
> 1. It is desirable to reach a first implementation as soon as possible.
> 2. Some design puzzles remain to insure that HSM can keep up with Lutre
> metadata clusters
>
> The steps to reach a first implementation can be summarized as:
>
> 1. Include file closes in the changelog, if the file was opened for write.
> Include timestamps in the changelog entries.  This allows the changelog
> processor to see files that have become inactive and pass them on for
> archiving.
> 2. Build an open call that blocks for file retrieval and adapts timeouts to
> avoid error returns.
> 3. Until a least-recently-used log is built, use the e2scan utility to
> generate lists of candidates for purging.
> 4. Translate events and scan results into a form that they can be understood
> by ADM.
> 5. Work with a single coordinator, whose role it is to avoid getting
> multiple ?close? records for the same file (a basic filter for events).
> 6. Do not use initiators ? these can come later and assist with load
> balancing and free-ing space on demand (both of which we can ignore for the
> first release)
> 7. Do not use multiple agents ? the agents can move stripes of files etc,
> and this is not needed with a basic user level solution, based on consuming
> the log.  The only thing the agent must do in release one is get the
> attention of a data mover to restore files on demand.
>
> Peter
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-de... at lists.lustre.orghttp://lists.lustre.org/mailman/listinfo/lustre-devel
