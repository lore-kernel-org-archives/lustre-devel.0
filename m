From: James Simmons <jsimmons@infradead.org>
Date: Mon, 15 Aug 2016 22:40:29 +0100 (BST)
Subject: [lustre-devel] [PATCH 19/58] staging: lustre: llite: add
 md_op_data parameter to ll_get_dir_page
In-Reply-To: <20160815163815.GA21426@kroah.com>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
	<1469155491-15265-20-git-send-email-jsimmons@infradead.org>
	<20160815163815.GA21426@kroah.com>
Message-ID: <alpine.LFD.2.20.1608152239170.7973@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>


> > From: wang di <di.wang@intel.com>
> > 
> > Pass in struct md_op_data for ll_get_dir_page function.
> > 
> > Signed-off-by: wang di <di.wang@intel.com>
> > Reviewed-on: http://review.whamcloud.com/7043
> > Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3531
> > Reviewed-by: John L. Hammond <john.hammond@intel.com>
> > Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
> > Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
> > Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> > Signed-off-by: James Simmons <jsimmons@infradead.org>
> > ---
> >  drivers/staging/lustre/lustre/llite/dir.c          |    8 ++++----
> >  .../staging/lustre/lustre/llite/llite_internal.h   |    4 ++--
> >  drivers/staging/lustre/lustre/llite/statahead.c    |   15 +++++++++++----
> >  3 files changed, 17 insertions(+), 10 deletions(-)
> 
> This patch fails to apply, so I have to stop here in the patch series.
> 
> So I'm guesing your second patch series also will fail to apply, so can
> you resend all of the outstanding patches you have sent me after
> rebasing on my staging-testing branch?

Do you mind if I combine them into one series? Also I have a few more 
patches I like to include. Is it okay to add those as well?
