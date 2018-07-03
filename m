From: NeilBrown <neilb@suse.com>
Date: Wed, 04 Jul 2018 08:03:27 +1000
Subject: [lustre-devel] [PATCH 05/18] lustre: llite: fast read
 implementation
In-Reply-To: <DM3PR1101MB121395BDC6EC6AA3130F42EFCB420@DM3PR1101MB1213.namprd11.prod.outlook.com>
References: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
 <1530573875-20465-6-git-send-email-jsimmons@infradead.org>
 <87woud0xip.fsf@notabene.neil.brown.name>
 <DM3PR1101MB121395BDC6EC6AA3130F42EFCB420@DM3PR1101MB1213.namprd11.prod.outlook.com>
Message-ID: <87fu100yfk.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Jul 03 2018, Patrick Farrell wrote:

> They do.  It?s probably gone unnoticed because those updates are mostly directly triggered by users or one time only during initialization, so there?s little risk of colliding.

Agreed.  Had there been no locking in this new patch I possibly wouldn't
have noticed.  But I don't like inconsistencies.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180704/76065dfc/attachment.sig>
