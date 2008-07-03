From: Peter Braam <Peter.Braam@Sun.COM>
Date: Thu, 03 Jul 2008 15:10:19 -0600
Subject: [Lustre-devel] How store HSM metadata in MDT ?
In-Reply-To: <486CBB59.4080206@cea.fr>
Message-ID: <C4929C5B.4D77%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I do understand that we need HSM related metadata, but I learned more from
Rick Matthews (cc'd) who is the architect of Sun's ADM project.  Now I am
not sure I am in agreement with what has been discussed so far.

If there is more than one copy in the archive, it would be preferable if the
archive could maintain a mapping from the Lustre fid of the file to the
archived copies.  Associated with the FID of the data would then be a list
of archived copies, timestamps etc.

Can that be done in HPSS?

If not, policy related operations like purging older files etc will become
very complex and not scalable.  For example, a search to find older files in
the archive would require an e2scan operation to find the inodes and then
the objects in the archive.  If the file system was not available anymore
(for whatever reason), it is not even clear that such a purge could still
happen.

With an archive based database this can be an indexed search in the archive,
which is faster and more appropriate.

Clearly this has a major impact on how much attribute space we need.

Thoughts?

Peter




On 7/3/08 5:43 AM, "Aurelien Degremont" <aurelien.degremont@cea.fr> wrote:

> HSM MetaData
> 
> For Lustre HSM project, it will be needed to store, for each file, a
> list of information describing how many copies the file has in the HSM,
> what is their HSM ID, the copy date, and so on. This data could easily
> reach 500 bytes (I think we will need between 40 and 50 bytes per HSM
> copy, and we should be able to save at least 10 copies, surely more).
> The question is: where could we store this data on MDT, in which place
> (EA?) and how manage this.
> 
> We had a discussion about this with Andreas and Nathan and it is not
> very clear what is the best solution here regarding to:
> - We must keep in mind that there is 2 available backends for MDT:
> ldiskfs and ZFS and both must be supported here.
> - EA space is not very wide on ldiskfs and quite used by several other
> features (stripping, ACL, ...)
> - Clients will need to read this data and so the RPC mechanism should be
> available and large enough to handle it.
> 
> Moreover, we will store a purged data range on OST and MDT. This could
> easily fit in a EA.
> 
> What is the possible solutions we have here ?
