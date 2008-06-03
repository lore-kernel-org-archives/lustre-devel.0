From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Tue, 03 Jun 2008 11:49:45 +0400
Subject: [Lustre-devel] Moving forward on Quotas
In-Reply-To: <48449569.4080406@sun.com>
References: <18493.29199.765234.755534@gargle.gargle.HOWL>
	<C46829E1.5610%peter.braam@sun.com>
	<20080601045302.GA29979@eng.sun.com>
	<18498.43788.847173.750390@gargle.gargle.HOWL>
	<48449569.4080406@sun.com>
Message-ID: <18500.63385.570359.425911@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Matthew Ahrens writes:
 > Nikita Danilov wrote:
 > > Jeff Bonwick writes:
 > >  > I'd suggest working with Matt Ahrens on this.
 > > 
 > > Hello,
 > > 
 > > we were discussing recently what is needed from the DMU to implement quotas
 > > and other forms of space accounting. Our basic premise is that it is desirable
 > > to keep DMU part of the quota support at minimum, and to implement only
 > > mechanism here, leaving policy to the upper layers.
 > 
 > I agree with this premise.  However, your proposed implementation (especially 
 > the asynchronous update mechanism and associated pending file) seems 
 > unnecessarily complicated.
 > 
 > I would suggest that we simply update a "database" (eg. ZAP object or sparse 
 > array) of userid -> space usage from syncing context when the space is 
 > allocated/freed (ie, dsl_dataset_block_{born,kill}).  I believe that the 
 > problems this presents[*] will be more tractable than the method you outlined.

Indeed, this solution is much simpler, and it was considered
initially. I see following drawbacks in it:

     - a notion of a user identifier (or some opaque identifier) has to
       be introduced in DMU interface. DMU doesn't interpret these
       identifiers in any way, except for using them as keys in a space
       usage database. A set of these identifiers has to be passed to
       every DMU entry point that might result in space allocation (a
       set is needed because there are group quotas, and to keep
       interface more or less generic).

     - an implementation of chown, chgrp, and distributed quota require
       DMU user to modify this database. Also, an interface to iterate
       over this database is most likely needed for things like
       distributed fsck, and user level quote reporting tools. It seems
       that it would be quite difficult to encapsulate such a database
       within DMU.

 > 
 > --matt
 > 
 > [*] eg, if the DB object is stored in the user's objset, then updating it in 
 > syncing context may be problematic.  if it is stored in the MOS, carrying it 

The proposal was to update the database in the context of currently open
transaction group. That is, when transaction group T has just committed,
commit call-back is invoked and the database is updated in the context
of some transaction belonging to transaction group T + 2 (T + 1 being in
sync). It is because of this that pending file has to keep track of
objects from two last transaction groups.

 > along when doing snapshot operations will be painful (snapshot, clone, send, 
 > recv, rollback, etc).

Nikita.
