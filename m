From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Dec 2018 01:53:26 +0000 (GMT)
Subject: [lustre-devel] [PATCH RFC 00/28] lustre: PFL port to linux
 client
In-Reply-To: <87y38lt1qz.fsf@notabene.neil.brown.name>
References: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
 <87mup39wy8.fsf@notabene.neil.brown.name>
 <87y38lt1qz.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1812270113001.5850@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> On Tue, Dec 18 2018, NeilBrown wrote:
> 
> > On Mon, Dec 17 2018, James Simmons wrote:
> >
> >> This is the initial PFL port to the linux lustre client. This opens
> >> up feed back on the port so far. Currently sanity passes but the
> >> test for sanity-pfl fail as below. I have been tracking downing
> >> various bugs but this one remains and I haven't found out why its
> >> failing. So far from what I can tell is lov_io_setattr_iter_init()
> >> it returning -ENODATA due to lsm_entry_inited() is not initialized.
> >
> > Having that invariant in cl_io_iter_fini() seems strange.
> > It is guaranteed to fir eif cl_io_iter_init() fails - if that is not
> > permitted, I would expect an invariant a lot closer to the failure.
> >
> > What happens if you just remove the LINVRNT() ??
> 
> I dug through the code some more, and I'm sure that LINVRNT() is wrong.
> 
> The cl_io_iter() call is meant to fail early, before ci_state gets to
> CIS_LOCKED, let alone CIS_UNLOCKED.  It sets ->ci_need_write_intent when
> it records the failure.  The code is then meant to fall through to
> the cl_io_fini() call in cl_setattr_ost(), which calls into vvp_io_fini)_
> which notices ->ci_need_write_intent, and calls ll_layout_write_intent(),
> which presumably initializes the things that weren't initialized before.
> This also sets ->ci_need_restart = 1 so that cl_setattr_ost() loops
> around to "again:" and calls cl_io_init() again.
> 
> So the invariant in cl_io_iter_fini() should probably be
> 
> 	LINVRNT(io->ci_state == CIS_INIT || io->ci_state == CIS_UNLOCKED);
> 
> or something like that.  Maybe needs CIS_IT_ENDED as well.
> 
> 	LINVRNT(io->ci_state <= CIS_INIT || io->ci_state >= CIS_UNLOCKED);
> 
> ??

You are right. I spent two weeks thinking I did the port wrong :-( I used
the second version which worked and saw only sanity-pfl test 11 failing.
I opened a ticket on this issue : 

https://jira.whamcloud.com/browse/LU-11828

and have pushed a patch for Bobi Jam to look at. We should have something
worked out soon. So PFL mostly worked outside of that. I will combine this
fix with a bunch others. I tracked down the majority of the causes of the
failures seen in the sanity testing.
