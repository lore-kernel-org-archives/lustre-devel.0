From: Peter Braam <Peter.Braam@Sun.COM>
Date: Wed, 16 Jul 2008 13:00:40 -0600
Subject: [Lustre-devel] How store HSM metadata in MDT ?
In-Reply-To: <487DCCCC.7060206@cea.fr>
Message-ID: <C4A3A178.6621%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This continues the Lustre design discussion for HSM.

On 7/16/08 4:26 AM, "Jacques-Charles Lafoucriere" <jc.lafoucriere@cea.fr>
wrote:

> Space Manager needs are:
> 1) generate a candidate list for copy out (pre-migration)
> 2) generate a candidate list for purge
> 
> For 1) the criteria is : not up to date in HSM and not recently modified
> For 2) the criteria is : up to date in HSM and not recently accessed
> 
> Needed changelogs events are "modifications" like :
> - file creation
> - mtime change
> - atime change

1) the files are in the log (and in ZFS the log can be reconstructed through
a fast search)

The issue here that makes me worried is the following.  Is the coordinator
managing "archiving" or is the space manager?

Whatever entity does it, it needs to WAIT until a file is quiescent for some
time.  ADM's event manager can do that, but how do we do it with HPSS?

Now interestingly the Size On MDS (SOM) project does almost precisely this,
it monitors a file going idle and transfers size from OSS's / clients to the
MDS inode.  So Lustre is pretty close, but this completes too quickly,
commonly archiving is postponed 20 minutes or so.


> 
> The things I do not like in events mode are:
> - if a file is created, filled and remove before copy-out (like a
> temporary file), we will have useless interaction with the spacemanger
> (and useless load)

A stat call to the file is quick and required anyway to eliminate race
conditions.

> - if for some issue, events are missed we will have HSM unknown files in
> Lustre. To resume this issue we can use a scan or find a way to warranty
> we will never missed an event.

Lustre logs and ZFS searches are guaranteed NOT to miss anything.  No finds
are necessary.

> This last point is a strong constraint because Lustre should be able to
> operate with a dead space manager.
> 
> I agree, I not fond of scanning, but  a low priority, background scan
> will solve these 2 issues.

We only need the scan for 2), and as indicated earlier it can be a rare
scan.

I will not accept scanning for 1).

> 
> For me the spacemanager and it's DB are common to all HSM and will have
> no HSM specific information.

And they will be a major bottleneck.   I definitely want to avoid a DB.

It is fair to state that all events belong with Lustre.  Lustre should
define adequate high performance features for distributed storage of events.

The logs or ZFS searches are a good example, similarly file sets, collecting
small files might be good examples.

A key consideration for the design is that by integrating it into Lustre we
control the performance of these event management systems much better than
through upcalls and databases.  Keep two systems in sync has proven to be
the problem when archiving small files (a ridiculously small number of small
files can be archived by current HSM's (100's) we need MILLIONS.  So our
architecture has to plan a major improvement here.  The database should go
away.

> HSM specific rules (like in which HSM internal storage class I will put
> a file) will be managed by HSM copy tool
> Do you agree ?

Yes. 

Peter
> 
> JC
> 
> 
