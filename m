From: NeilBrown <neilb@suse.com>
Date: Wed, 01 Aug 2018 13:41:43 +1000
Subject: [lustre-devel] [PATCH 00/31] lustre: missing fixes and cleanups
 from lustre 2.10
In-Reply-To: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
Message-ID: <87zhy6pxc8.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Jul 30 2018, James Simmons wrote:

> This covers all the missing patches landed from the start of the
> lustre 2.10 development cycle until right before the PFL feature
> landed. Several bug fixes as well as cleanups. This is based on
> top of the recent list patches as well as my mount code for llite
> patch series.

I've applied all these to my lustre-testing branch, plus the fixups
I promised.
I cannot review them for correctness, just for whether the code looks
sensible and appears consistent with upstream style.

If my testing shows no problems and I don't hear any complaints I
suspect they will migrate to 'lustre' in a week or so.

BTW I've created a new branch 'lustre-wip' which contains patches that
depend on changes to non-lustre code, and so are likely to be delayed
more than I would like...

Thanks,
NeilBrown

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180801/5bdd3769/attachment.sig>
