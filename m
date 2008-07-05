From: Andreas Dilger <adilger@sun.com>
Date: Sat, 05 Jul 2008 10:50:25 -0600
Subject: [Lustre-devel] How store HSM metadata in MDT ?
In-Reply-To: <486E35AB.7010405@cea.fr>
References: <C4929C5B.4D77%peter.braam@sun.com> <486E35AB.7010405@cea.fr>
Message-ID: <20080705165025.GI6239@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jul 04, 2008  16:37 +0200, Aurelien Degremont wrote:
> Peter Braam a ?crit :
> > If there is more than one copy in the archive, it would be preferable if the
> > archive could maintain a mapping from the Lustre fid of the file to the
> > archived copies.  Associated with the FID of the data would then be a list
> > of archived copies, timestamps etc.
> 
> Do you mean that the HSM will be aware of various versions of one same 
> file, identified in Lustre by a FID ?
> Or this will be masked by the archiving tool , doing some tricks to 
> simulate it ?
> 
> > Can that be done in HPSS?
> 
> HPSS alone cannot do versioning on its files presently.

When HPSS acts as both backup and HSM, is it still dependent on an external
space/backup manager to track all of the files for the filesystem, or does
it have a space manager built into it?

> > If not, policy related operations like purging older files etc will become
> > very complex and not scalable.  For example, a search to find older files in
> > the archive would require an e2scan operation to find the inodes and then
> > the objects in the archive.  If the file system was not available anymore
> > (for whatever reason), it is not even clear that such a purge could still
> > happen.
> > 
> > With an archive based database this can be an indexed search in the archive,
> > which is faster and more appropriate.
> 
> By purgin do mean purging in Lustre or in the HSM?

Purging old backups of the file in the offline storage (it isn't quite
right to call this the HSM at this point, because there are multiple
backup copies of the file, not strictly a heirarchy).

> There's no issue with purging in Lustre because this do not imply the HSM.
> And removal of oldest copies in the HSM could be done asynchronously, 
> slowly.

What manages removal of the older copies in HPSS?  If HPSS can purge older
files based on policy (leaving at least the most recent copy always), then
it would be possible to defer the backup policy to HPSS and Lustre would
only ever need to reference a single offline file.  Any queries for listing
older versions of the file would be passed on from Lustre to HPSS in that
case.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
