From: Nicolas Williams <Nicolas.Williams@sun.com>
Date: Tue, 5 Jan 2010 15:55:12 -0600
Subject: [Lustre-devel] SOM safety
In-Reply-To: <FCF9512F-B081-4307-AA58-9A161790073D@sun.com>
References: <079601ca8e36$70c5f480$5251dd80$@com>
	<FCF9512F-B081-4307-AA58-9A161790073D@sun.com>
Message-ID: <20100105215512.GB1516@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Jan 05, 2010 at 02:50:51PM -0700, Andreas Dilger wrote:
> On 2010-01-05, at 11:39, Eric Barton wrote:
> > The MDS must guarantee that any SOM attributes it provides to its
> > clients are valid at the moment they are requested - i.e. that no file
> > stripes were updated while the SOM attributes were computed and
> > cached.  This guarantee must hold in the presence of all possible
> > failures.
> >
> > Clients notify the MDS before they could possibly update any stripe of
> > a file (e.g. on OPEN) so that the MDS can invalidate any cached SOM
> > attributes.  Clients also notify the MDS with "done writing" when all
> > their stripe updates have committed so that the MDS can determine when
> > it may resume caching SOM attributes.
> 
> This brings up an interesting question.  When the client does a lookup  
> on a file, or first opens it, the client gets the cached size from the  
> MDS (assuming SOM cache is valid).  However, after this initial  
> update, what guarantee does the client have that the size is still  
> valid?  Must it do further MDS getattr or OST glimpse operations in  
> order to revalidate the size?  I don't recall any lock bit that the  
> MDS gives the client that tells the client that the file size it has  
> is still valid.

Well, the guarantee should be from the time the MDS responds to the
client until the stat() call returns to the application.  After all,
POSIX talks about system calls, not client/server messaging.  That means
that the client effectively holds a lock on the cached attributes for a
bit.

> In this regard, it seems that SOM would only provide an improvement on  
> the initial "ls -l" operation, and subsequent "ls -l" operations would  
> be slower than the current "readdir + statahead + DLM lock  
> cache" (which would not need to do any RPCs for the second "ls -l").

If the client can hold that lock for as long as no one is writing, then
the client can cache that information for that long.

Nico
-- 
