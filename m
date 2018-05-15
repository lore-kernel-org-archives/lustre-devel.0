From: James Simmons <jsimmons@infradead.org>
Date: Tue, 15 May 2018 03:11:48 +0100 (BST)
Subject: [lustre-devel] [PATCH 4/4] staging: lustre: obdclass: change
 object lookup to no wait mode
In-Reply-To: <87efid7l6z.fsf@notabene.neil.brown.name>
References: <1525285308-15347-1-git-send-email-jsimmons@infradead.org>
 <1525285308-15347-5-git-send-email-jsimmons@infradead.org>
 <876044fcgg.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1805150133430.576@casper.infradead.org>
 <87efid7l6z.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1805150308400.576@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, Lai Siyao <lai.siyao@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>


> >> On Wed, May 02 2018, James Simmons wrote:
> >> 
> >> > From: Lai Siyao <lai.siyao@intel.com>
> >> >
> >> > Currently we set LU_OBJECT_HEARD_BANSHEE on object when we want
> >> > to remove object from cache, but this may lead to deadlock, because
> >> > when other process lookup such object, it needs to wait for this
> >> > object until release (done at last refcount put), while that process
> >> > maybe already hold an LDLM lock.
> >> >
> >> > Now that current code can handle dying object correctly, we can just
> >> > return such object in lookup, thus the above deadlock can be avoided.
> >> 
> >> I think one of the reasons that I didn't apply this to mainline myself
> >> is that "Now that" comment.  When is the "now" that it is referring to?
> >> Are were sure that all code in mainline "can handle dying objects
> >> correctly"??
> >
> > So I talked to Lai and he posted the LU-9049 ticket what patches need to
> > land before this one. Only one patch is of concern and its for LU-9203
> > which doesn't apply to the staging tree since we don't have the LNet SMP
> > updates in our tree. I saved notes about making sure LU-9203 lands 
> > together with the future LNet SMP changes. As it stands it is safe to
> > land to staging.
> 
> Thanks a lot for looking into this.  Nice to have the safety of this
> change confirmed.
> 
> What do you think of:
> 
> >> > @@ -713,36 +691,46 @@ struct lu_object *lu_object_find_at(const struct lu_env *env,
> >> >  	 * It is unnecessary to perform lookup-alloc-lookup-insert, instead,
> >> >  	 * just alloc and insert directly.
> >> >  	 *
> >> > +	 * If dying object is found during index search, add @waiter to the
> >> > +	 * site wait-queue and return ERR_PTR(-EAGAIN).
> >> 
> >> It seems odd to add this comment here, when it seems to describe code
> >> that is being removed.
> >> I can see that this comment is added by the upstream patch
> >> Commit: fa14bdf6b648 ("LU-9049 obdclass: change object lookup to no wait mode")
> >> but I cannot see what it refers to.
> >> 
> 
> ??
> 
> Am I misunderstanding something, or is that comment wrong?

I think the comment is wrong. That comment was in the other tree before 
the patch was landed. It got included with this push due to me diffing the
tree by accident. I will remove it with the next push.
