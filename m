From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Dec 2018 01:59:10 +0000 (GMT)
Subject: [lustre-devel] [PATCH 02/28] lustre: lov: move code for PFL work
In-Reply-To: <87sgyvael2.fsf@notabene.neil.brown.name>
References: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
 <1545064202-22483-3-git-send-email-jsimmons@infradead.org>
 <87sgyvael2.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1812270157520.5850@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> On Mon, Dec 17 2018, James Simmons wrote:
> 
> > From: Bobi Jam <bobijam@hotmail.com>
> >
> > Move lov_tgt_maxbytes() and lsm_free_plain() toward the top of
> > lov_ea.c for upcoming PFL work.
> 
> No mention of the lsm_op_find() move??
> That function is still in lov_internal.h in OpenSFS lustre !!

Added details of that move. This is one of those changes that Greg
asked for in the past. He didn't like extern struct .... in a header
file along with a inline function to handle those external structs.
