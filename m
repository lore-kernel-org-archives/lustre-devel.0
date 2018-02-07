From: NeilBrown <neilb@suse.com>
Date: Thu, 08 Feb 2018 08:31:54 +1100
Subject: [lustre-devel] testing lustre
In-Reply-To: <alpine.LFD.2.21.1801081607120.1698@casper.infradead.org>
References: <151538168618.23920.8261096424342988792.stgit@noble>
 <20180108145943.GA5761@kroah.com>
 <alpine.LFD.2.21.1801081607120.1698@casper.infradead.org>
Message-ID: <87po5gmqph.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Hi,
 I've set up a little virtual cluster to run the sanity tests.
 One problem I have is that the test harness expects that after it
 creates a filesystem, the label (reported by e2label) will
 spontaneously change from e.g. "lustre:MDT-0000" to "lustre-MDT-0000"
 and that doesn't happen for me.
 If I go and change the label manually while the test is waiting,
 then the test continues and appears to run correctly.

 Can anyone tell me what this name change in meant to indicate, when
 where in the code it is expected to happen?

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180208/672f963b/attachment.sig>
