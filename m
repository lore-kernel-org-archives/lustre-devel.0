From: Nathaniel Rutman <Nathan.Rutman@Sun.COM>
Date: Mon, 04 Feb 2008 14:39:36 -0800
Subject: [Lustre-devel] [Fwd: feed api, rev2]
In-Reply-To: <20080201231102.GA21120@webber.adilger.int>
References: <47A16787.4030402@sun.com>
	<20080201231102.GA21120@webber.adilger.int>
Message-ID: <47A79428.9060702@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas Dilger wrote:
>
> With the change to force the "ONESHOT" behaviour, this hurts the ability
> of the userspace process to pipeline operations.  No matter how large a
> read the user process does, it will eventually have to finish processing
> ALL of the records before it can read any more, or they will be lost on
> the next read and any application failure will result in lost records
> if they are not completely processed.  I preferred the ability to
> explicitly cancel records.
>   
There are arguments on both sides.   I'd really like to stay away from 
having
multiple cancellation mechanisms though - I think this will be extra 
work and
extra confusion.
With explicit cancel and a regular file we can have multiple readers all 
reading the same audit log,
which is a big plus. (Record would be purged at first cancel.) This adds 
complication
for the users though, which is a minus: they must now a) persistently 
keep track of
their last-processed record ID, b) explicitly cancel records, c) map 
record numbers
to file offsets.  I think c) is a real hassle.
With explicit cancel and a FIFO we have a) and b), but not c), but not 
multiple
readers either.
