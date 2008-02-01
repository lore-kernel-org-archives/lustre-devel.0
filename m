From: Andreas Dilger <adilger@sun.com>
Date: Fri, 01 Feb 2008 16:11:02 -0700
Subject: [Lustre-devel] [Fwd: feed api, rev2]
In-Reply-To: <47A16787.4030402@sun.com>
References: <47A16787.4030402@sun.com>
Message-ID: <20080201231102.GA21120@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jan 30, 2008  22:15 -0800, Nathaniel Rutman wrote:
> hm, I tried to send this before, but it's not showing up in my mailbox.  
> Anyhow, fixed it up a little more...

In general, it would be nicer to export as text for the mailing list
unless there are graphics or something - makes it easier to comment on.

struct feed entry {
     __u32 fe_len;    total record length
     __u32 fe_ttype;   transaction type
     __u64 fe_seq;    local feed sequence number
     __u64 fe_cookie; synchronization cookie (for distributed events)
     __u64 fe_time;   event time, server-local
     __u32 fe_result; return code (0=success)
     void *fe_data;  transaction type-specific struct
}

struct feed_entry_open {
     ll_fid fid;          (see lustre idl.h)
     ll_fid parent_fid;
     nid_t clientnid;
     __u32 fsuid;
     __u32 fsgid;
     __u32 cap;
     __u32 flags;
     __u32 mode;
     __u32 filename_len;
     char *filename;
}

Do you think it makes more sense to add the client nid to the feed_entry
instead of the feed_entry_open?  I'd think the client (or server) that
performed the operation is common to every operation.


For abort_size - I suspect that the default 1000 records is much too small
for practical use.  I'd think some millions of records would be reasonable,
if there are many operations going on, so that a service that died had any
chance of reconnecting before the records are lost.  Alternately, it is
probably safer to specify some timeout (e.g. 1h) instead of a record count.

Of course, it is better if this is specified by the application, but I
suspect the apps won't have a good idea of what an appropriate default
value is, as that is highly dependent upon the filesystem size and usage.


With the change to force the "ONESHOT" behaviour, this hurts the ability
of the userspace process to pipeline operations.  No matter how large a
read the user process does, it will eventually have to finish processing
ALL of the records before it can read any more, or they will be lost on
the next read and any application failure will result in lost records
if they are not completely processed.  I preferred the ability to
explicitly cancel records.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
