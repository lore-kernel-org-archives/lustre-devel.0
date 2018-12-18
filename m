From: NeilBrown <neilb@suse.com>
Date: Tue, 18 Dec 2018 11:00:41 +1100
Subject: [lustre-devel] [PATCH 02/28] lustre: lov: move code for PFL work
In-Reply-To: <1545064202-22483-3-git-send-email-jsimmons@infradead.org>
References: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
 <1545064202-22483-3-git-send-email-jsimmons@infradead.org>
Message-ID: <87sgyvael2.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Dec 17 2018, James Simmons wrote:

> From: Bobi Jam <bobijam@hotmail.com>
>
> Move lov_tgt_maxbytes() and lsm_free_plain() toward the top of
> lov_ea.c for upcoming PFL work.

No mention of the lsm_op_find() move??
That function is still in lov_internal.h in OpenSFS lustre !!

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181218/65953ebc/attachment.sig>
