From: Yong, Fan <fan.yong@intel.com>
Date: Wed, 1 Aug 2018 04:15:51 +0000
Subject: [lustre-devel] [PATCH 30/31] lustre: fid: race between
 client_fid_fini and seq_client_flush
In-Reply-To: <87600urdx1.fsf@notabene.neil.brown.name>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
 <1533003983-29311-31-git-send-email-jsimmons@infradead.org>
 <87y3drqalt.fsf@notabene.neil.brown.name>
 <7FB055E0B36B6F4EB93E637E0640A56FCB68C93C@fmsmsx118.amr.corp.intel.com>
 <87600urdx1.fsf@notabene.neil.brown.name>
Message-ID: <7FB055E0B36B6F4EB93E637E0640A56FCB68D9A1@fmsmsx118.amr.corp.intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From the logic view, the client_fid_fini() should wait all the client_obd::cl_seq users (in spite of flush() or fid_allocation() or other possible new users in the future) done or abort their things before destroying the client_obd::cl_seq. The rwsem build up the framework for that.

> In either case, I cannot see any justification for holding the lock in client_fid_init().
As for holding the rwsem during the initiation, honestly, it is unnecessary since currently there is neither concurrent initialization nor other accessing during the initialization. And just because of no contend on the rwsem, holding such rwsem here will not cause too much overhead. On the other hand, if someone will change the caller logic as to there will be possible concurrent initialization, then we need to hold the rwsem during the initialization instead of atomically assigning it to cli->cl_seq.

--
Cheers,
Nasf

-----Original Message-----
From: NeilBrown [mailto:neilb at suse.com] 
Sent: Wednesday, August 1, 2018 10:58 AM
To: Yong, Fan <fan.yong@intel.com>; James Simmons <jsimmons@infradead.org>; Andreas Dilger <adilger@whamcloud.com>; Oleg Drokin <green@whamcloud.com>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>; James Simmons <jsimmons@infradead.org>
Subject: RE: [PATCH 30/31] lustre: fid: race between client_fid_fini and seq_client_flush

On Wed, Aug 01 2018, Yong, Fan wrote:

> The client_obd::cl_seq_rwsem protects the client_obd::cl_seq itself, 
> not the internal members inside client_obd::cl_seq. I do not think 
> simple refcount can work here. For example, if the client_fid_fini() 
> is destroying the client_obd::cl_seq, we need some mechanism, such as 
> the mutex, to pervert others accessing the client_obd::cl_seq. Under 
> such case, even though someone could acquire refcount (after the
> client_fid_fini() start), it still cannot prevent the in-processing 
> destroy.

A common pattern with refcounts is to free the object when the refcount reaches zero.
   kref_put(&cli->cl_refcount, free_cl_seq(cli))

or similar.
So we start with a refcount of 1,
the code that currently does 'down_read()' instead does
   if (kref_get_unless_zero(&cli->cl_refcount)) {
              do something with cli->cl_seq
              kref_put(.....);
   }

and client_fid_fini() just does the kref_put().

An important question is whether client_fid_fini() really needs to wait for seq_client_flush() or seq_client_alloc_fid() to complete.
If it does, then we probably can't do much better than the rwsem.
If it doesn't, then kref_put() is the better way to go.

In either case, I cannot see any justification for holding the lock in client_fid_init().
It would be better to completely initialize the lu_client_seq, and then atomically assign it to cli->cl_seq.

Thanks,
NeilBrown
