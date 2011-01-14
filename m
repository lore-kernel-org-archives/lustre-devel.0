From: James Simmons <jsimmons@infradead.org>
Date: Fri, 14 Jan 2011 20:04:11 +0000 (GMT)
Subject: [Lustre-devel] Setting attributes at open.
In-Reply-To: <op.vpba9oe9f7bdb6@garden>
References: <alpine.LFD.2.00.1101141827450.5594@casper.infradead.org>
	<op.vpba9oe9f7bdb6@garden>
Message-ID: <alpine.LFD.2.00.1101142000590.5594@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> Hello,
> 
> just quick idea. The mdd_open_sanity_check() is called under  
> mdd_write_lock():
> >         mdd_write_lock(env, mdd_obj, MOR_TGT_CHILD);
> > -        rc = mdd_open_sanity_check(env, mdd_obj, flags);
> > +        rc = mdd_open_sanity_check(env, obj, ma, flags);
> 
> You've added mdd_attr_set(env, o, ma); in it causing deadlock it seems,
> because it calls mdd_attr_set_internal_locked() which is taking the same  
> lock.

Perhaps mdd_attr_set is to heavy of a function. I wonder would calling
mdd_setattr_txn_param_build be light enough to do what we want or do we 
really need to write to the change logs that happs in mdd_attr_set.
