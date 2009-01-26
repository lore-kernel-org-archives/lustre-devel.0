From: Andreas Dilger <adilger@sun.com>
Date: Mon, 26 Jan 2009 03:08:56 -0700
Subject: [Lustre-devel] Sub Tree lock ideas.
In-Reply-To: <7D9ABF96-6BD8-4F7A-A5AE-F08BF04854B2@sun.com>
References: <7D9ABF96-6BD8-4F7A-A5AE-F08BF04854B2@sun.com>
Message-ID: <20090126100856.GD3652@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jan 21, 2009  15:49 -0500, Oleg Drokin wrote:
>     So, I think it is a given we do not want to revoke a subtree lock  
> every time somebody steps through it, because that will be too costly  
> in a lot of cases.

A few comments that I have from the later discussions:
- you previously mentioned that only a single client would be able to
  hold a subtree lock.  I think it is critical that multiple clients be
  able to get read subtree locks on the same directory.  This would be
  very important for uses like many clients and a shared read-mostly
  directory like /usr/bin or /usr/lib.

- Alex (I think) suggested that the STL locks would only be on a single
  directory and its contents, instead of being on an arbitrary depth
  sub-tree.  While it seems somewhat appealing to have a single lock
  that covers an entire subtree, the complexity of having to locate
  and manage arbitrary-depth locks on the MDS might be too high.

  In most use cases it is pretty rare to have very deep subtrees, and
  the common case will be a large number of files in a single directory
  and a subtree lock will serve this use case equally well.

  Having only a single-level of subtree lock would avoid the need to
  pass cookies to the MDS for anything other than the directory in
  which names are being looked up.

>     Anyway here is what I have in mind.
> 
>     STL locks could be granted by server regardless if they were  
> requested by the client or not.
> 
>     We would require clients to provide a lock "cookie" with every  
> operation they perform, in normal case that would be a handle they  
> have on a parent directory.
>     This cookie should allow a way to find out what server this cookie  
> originates from (needed for CMD support).
> 
>     For the case of a different client stepping into area covered by  
> STL lock, this client would get STL lock's cookie and will start  
> present it for all subsequent
>     operations (also a special flag meaning that the client is not  
> operating within STL).
>     When the server receives a request with a cookie that is found out  
> to be for STL lock, a callback is made to that lock (if necessary -  
> through other server in CMD case)
>     and information about currently-accessed fid and access mode is  
> included, the client where the callback ends up on will do necessary  
> writeout of the object content (flush dirty data
>     for the case of a file, flush any metadata changes in case of a  
> directory (needed for metadata writeback cache. Would be a server-noop  
> for r/o access to directories before
>     WBC is implemented) and aside from that if the operation is  
> modifying, the STL-holding client would have to release the STL lock  
> and would have a choice of completely
>     flushing its cache for the subtree protected by the STL or  
> obtaining STLs for parts of the tree below STL and retain its cache  
> for those subtrees.
>     Additionally for r/o access the STL-holding client would have  
> extra choices of doing nothing (besides cache writeout flush for the  
> object content) or allowing a server to
>     issue a lock on that fid, in which case the client would flush its  
> own cache for entire subtree starting with that fid first.
>     If the lock cookie presented by the accessing client is determined  
> to be invalid (rogue client, or lock was already released), a reverse  
> lookup is performed up the tree
>     (possibly crossing MDT boundaries) by the server in search of an  
> already granted (to a client) lock or the root of the tree, whatever  
> is met first. If during this
>     lookup a lock is met, and it happens to be STL lock, its cookie is  
> returned to the client along with indication of the STL lock presence,  
> otherwise normal
>     operations with normal lock granting occur.
> 
>     When a client gets STL lock for itself, it also performs all  
> subsequent operations by presenting the STL lock handle. It might get  
> a reply from a server indicating that
>     the entry being accessed is "shared" (determined by server as an  
> opened file or inode on which there are any locks granted to any  
> clients) and a normal lock (or in case this
>     area of the tree is covered by somebody else's STL - that STL's  
> cookie) if needed. All metadata cached on behalf of STL lock is marked  
> as such in the client's cache.
> 
>     This approach allows for dynamically growing STL tree with ability  
> to cut it at any level (by a presence of a lock in some part of the  
> tree). Originally after issued, STL
>     lock would span from the root of the subtree it was issued on to  
> any points where other clients might have any cached information (or  
> if no other clients hold locks there -
>     for entire subtree), and then there is a possibility to cut some  
> of the subsubtrees from the subtree protected by STL. This also allows  
> for nested STLs held by different
>     clients.
>     One important thing that needs to be done in this scenario is we  
> must ensure any process with CWD on lustre would have a lock on that  
> directory if possible (of course we
>     cannot refuse this lock revocation if other clients want to modify  
> directory content). This would allow us to avoid costly reverse  
> lookups to find if we are under any STL
>     lock when we operate from a CWD on lustre (STL lock would just be  
> cut at the CWD point with the normal lock).
> 
>     We would need to implement cross-MDT lock callbacks.
> 
>     I think it is safe to depend on clients to provide locks since if  
> they don't or provide invalid ones - we can find this out (and we can  
> couple locks with
>     some secure tokens if needed too), the only downside is rogue  
> clients would be able to slow down servers to do all the reverse  
> lookups (though if we just
>     refuse to speak with clients that present invalid locks that were  
> never present in the system on a non-root of the FS inode, that should  
> be somewhat mitigated).
>     The other alternative is to mark every server dentry with a STL  
> marker during traversal, but in that case recovery in case of server  
> restart becomes somewhat
>     problematic, so I do not think this is a good idea.
> 
> 
> Bye,
>      Oleg
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
