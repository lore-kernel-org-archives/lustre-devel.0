From: NeilBrown <neilb@suse.com>
Date: Wed, 04 Jul 2018 07:59:34 +1000
Subject: [lustre-devel] [PATCH 01/18] lustre: grant: add support for
 OBD_CONNECT_GRANT_PARAM
In-Reply-To: <DM3PR1101MB1213CBD340C2EC3D7BECF557CB420@DM3PR1101MB1213.namprd11.prod.outlook.com>
References: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
 <1530573875-20465-2-git-send-email-jsimmons@infradead.org>
 <87601x2f5b.fsf@notabene.neil.brown.name>
 <DM3PR1101MB1213CBD340C2EC3D7BECF557CB420@DM3PR1101MB1213.namprd11.prod.outlook.com>
Message-ID: <87in5w0ym1.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Jul 03 2018, Patrick Farrell wrote:

> Neil,
>
> Compute vs consume: Honestly either would work.  The client consumes grant when it writes data, this fix to the calculation allows it to consume more accurately. *shrugs*

Good - thanks.
I would have said "this fix to the calculation allows it to track what it
has consumed more accurately", but it is a small point.  I just wanted to
be sure I understood, and now I'm sure I do.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180704/a4870fe1/attachment.sig>
