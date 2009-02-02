From: Andreas Dilger <adilger@sun.com>
Date: Mon, 02 Feb 2009 15:50:44 -0700
Subject: [Lustre-devel] Sub Tree lock ideas.
In-Reply-To: <5EF2479C-CFC4-4CD5-95E8-50368A7D5083@Sun.COM>
References: <7D9ABF96-6BD8-4F7A-A5AE-F08BF04854B2@sun.com>
	<20090126100856.GD3652@webber.adilger.int>
	<5EF2479C-CFC4-4CD5-95E8-50368A7D5083@Sun.COM>
Message-ID: <20090202225044.GL28818@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jan 27, 2009  23:39 -0500, Oleg Drokin wrote:
> On Jan 26, 2009, at 5:08 AM, Andreas Dilger wrote:
>> A few comments that I have from the later discussions:
>> - you previously mentioned that only a single client would be able to
>>  hold a subtree lock.  I think it is critical that multiple clients be
>>  able to get read subtree locks on the same directory.  This would be
>>  very important for uses like many clients and a shared read-mostly
>>  directory like /usr/bin or /usr/lib.
>
> In fact I see zero benefit for read-only subtree lock except memory
> conservation, which should not be such a big issue. Much more important
> is to reduce amount of RPCs, esp. synchronous ones.

Memory conservation on the server is very important.  If there are 100k
clients and a DLM lock is 2kB in size then we are looking at 200MB for
each lock given to all clients.  With an MDS having, say, 32GB of RAM and
we would consume all of the server RAM with only 160 locks/client.

>> - Alex (I think) suggested that the STL locks would only be on a  
>> single
>>  directory and its contents, instead of being on an arbitrary depth
>>  sub-tree.  While it seems somewhat appealing to have a single lock
>>  that covers an entire subtree, the complexity of having to locate
>>  and manage arbitrary-depth locks on the MDS might be too high.
>
> That's right.
>
>>  Having only a single-level of subtree lock would avoid the need to
>>  pass cookies to the MDS for anything other than the directory in
>>  which names are being looked up.
>
> I had a lengthly call with Eric today and at the end we came to a
> conclusion that perhaps STL at the moment is a total overkill.
>
> What we need is ability to reduce metadata RPCs traffic.

And to reduce memory usage for read locks on the server.  Having READ
STL for cases like read-mostly directories (/usr/bin, /usr/lib, ~/bin)
can avoid many thousands/millions of locks and their RPCs.

> We can start with implementation of just allowing WRITE locks on a
> directory that would be only responsible for this directory and its
> content (HELPS: by allowing to aggregate creates into bunches before
> sending) + a special "entire file lock" (perhaps implemented by just
> WRITE lock on a file) metadata lock that would guard all file data
> without obtaining any locks from OSTs (would be revoked by open from
> another client, perhaps would need to support glimpses too).

Well, if the client will generate the layout on the newly-created
files, or will request the layout (LOV EA) lock on the files it wants
exclusive access to this is essentially the "entire file lock" you need.
For existing files the client holding the layout lock needs to cancel
the OST extent locks first, to ensure they flush their cache.

> The WRITE directory lock only helps us to aggregate metadata RPCs if we
> just created the empty directory OR if we have entire list of entries in
> that directory. If we do not have entire directory content, we must  
> issue synchronous create RPC to avoid cases where we locally create a file  
> that already exists in that dir, for example. So perhaps in a lot of cases
> obtaining a write lock on a dir would need to be followed by some sort  
> of bulk directory read (readdir+ of sorts). This is also not always  
> feasible, as I can imagine there could be directories much bigger than
> what we would like to cache, in which case we would need to resort to
> one-by-one creates.


> Another important thing we would need is lock conversion (downconversion 
> and try-up conversion) so that we do not lose our entire cached directory  
> content after conflicting ls came in and we wrote it out. (we do not care
> all that much about writing out entire content of the dirty metadata cache
> at this point, since we still achieve the aggregation and asynchronous
> creation, even just asynchronous creation would help).

We also want to have lock conversion for regular files (write->read) and
for the layout lock bit (so clients can drop the LOV EA lock without
dropping the LOOKUP or UPDATE bits).

> Perhaps another useful addition would be to deliver multiple blocking  
> and glimpse callbacks from server to the client in a single RPC (as a
> result of a readdir+ sort of operation inside a dir where many files have  
> "entire file lock") (we already have aggregated cancels in the other
> direction).

Well, I'm not sure how much batching we will get from this, since it will
be completely non-deterministic whether multiple independent client
requests can be grouped into a single RPC.

> This WRITE metadata lock is in fact a reduced subset of STL lock without 
> any of its advanced features, but perhaps easier to implement because of  
> that.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
