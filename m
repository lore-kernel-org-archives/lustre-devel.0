From: Aurelien Degremont <aurelien.degremont@cea.fr>
Date: Fri, 04 Jul 2008 16:37:31 +0200
Subject: [Lustre-devel] How store HSM metadata in MDT ?
In-Reply-To: <C4929C5B.4D77%peter.braam@sun.com>
References: <C4929C5B.4D77%peter.braam@sun.com>
Message-ID: <486E35AB.7010405@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Peter Braam a ?crit :
> If there is more than one copy in the archive, it would be preferable if the
> archive could maintain a mapping from the Lustre fid of the file to the
> archived copies.  Associated with the FID of the data would then be a list
> of archived copies, timestamps etc.

Do you mean that the HSM will be aware of various versions of one same 
file, identified in Lustre by a FID ?
Or this will be masked by the archiving tool , doing some tricks to 
simulate it ?

> Can that be done in HPSS?

HPSS alone cannot do versioning on its files presently.


> If not, policy related operations like purging older files etc will become
> very complex and not scalable.  For example, a search to find older files in
> the archive would require an e2scan operation to find the inodes and then
> the objects in the archive.  If the file system was not available anymore
> (for whatever reason), it is not even clear that such a purge could still
> happen.
> 
> With an archive based database this can be an indexed search in the archive,
> which is faster and more appropriate.

By purgin do mean purging in Lustre or in the HSM?
There's no issue with purging in Lustre because this do not imply the HSM.
And removal of oldest copies in the HSM could be done asynchronously, 
slowly.

I'm not sure I see what you mean here


-- 
Aurelien Degremont
CEA
