From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 25 Sep 2015 19:22:31 +0200
Subject: [lustre-devel] [Y2038] [PATCH 32/37] staging/lustre: use
	64-bit	times for exp_last_request_time
In-Reply-To: <DD44D8F2-C54F-4A8F-A667-327DC391A761@intel.com>
References: <1443035640-1617003-1-git-send-email-arnd@arndb.de>
	<5823166.8kAioJAUND@wuerfel>
	<DD44D8F2-C54F-4A8F-A667-327DC391A761@intel.com>
Message-ID: <1630881.hYYUDfogQZ@wuerfel>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Friday 25 September 2015 16:53:14 Drokin, Oleg wrote:
> 
> On Sep 25, 2015, at 12:09 PM, Arnd Bergmann wrote:
> > 
> > I have updated the branch now to reflect our discussions so far. Can you handle
> > forwarding the patches to Greg from there, or complain if there are still
> > problems with them?
> 
> Aha, sure.
> Do you want me to send the y2038 patches too?

Yes, I meant both the y2038 patches and the code removal.

> > I still had problems with removing ptlrpc_update_export_timer(), so I left
> > a small patch for that, which you probably want to do differently, and
> > while I split out the nontrivial parts of the large removal patch, most of
> > it still is in one chunk that contains purely removals of whole lines.
> 
> Ok, I'll take care of this as well.
> 
> Thank you!

Thanks!

	Arnd
