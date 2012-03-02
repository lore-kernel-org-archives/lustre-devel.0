From: Andreas Dilger <adilger@whamcloud.com>
Date: Fri, 2 Mar 2012 11:28:54 -0800
Subject: [Lustre-devel] Does LUSTRE supports setfsuid/setfsgid ?
In-Reply-To: <4F50BC30.5090602@cea.fr>
References: <4F50BC30.5090602@cea.fr>
Message-ID: <9EB68D7F-0152-4148-8330-B40E6BA0F719@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2012-03-02, at 4:25 AM, DENIEL Philippe wrote:
> I am the maintener of NFS-Ganesha, a NFS server running in User Space. 
> The server has several backends on different filesystems. One of the 
> backend is dedicated to LUSTRE, using liblustreapi.a .
> The server is generic and I faced the problem to "su" to a user inside a 
> thread for backends whose calls have no specific credentials parameter. 
> For backends like XFS, GPFS and VFS (they are accessed via the "open by 
> handle" feature in kernel > 2.6.39) I can use setfsuid/setfsgid. I works 
> pretty well and provides a way to "become" a different user in different 
> threads. I plan to use the same kind of logic with LUSTRE.
> Here comes my question : does LUSTRE supports setfsuid and setfsgid and 
> it behaves a every filesystem accessed by the VFS ?

Yes, Lustre supports this, as far as I know.  Potential difficulties include
that if the "su" process is only partial, then the fsuid/fsgid may be wrong
on the MDS, so the supplementary group upcall on the MDS may return the wrong
group list for that UID.

Another difficulty is that Lustre does not yet support the "open by handle"
feature, though I worked with the original developer to ensure that it would
work reasonably well with Lustre.  I don't think this would be too hard for
someone to implement, but I haven't yet looked into the details.  Lustre
already allows lookup-by-FID, which would be necessary for this feature.

Cheers, Andreas
--
Andreas Dilger                       Whamcloud, Inc.
Principal Lustre Engineer            http://www.whamcloud.com/
