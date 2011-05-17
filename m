From: rf at q-leap.de <rf@q-leap.de>
Date: Tue, 17 May 2011 15:43:14 +0200
Subject: [Lustre-devel] F/S stats visualisation
In-Reply-To: <20110517124757.GG2142@granier.hd.free.fr>
References: <008a01cc05f8$a6b26840$f41738c0$@com>
	<84D90924-025F-4ABA-89BD-58C43C8FCDD9@ddn.com>
	<20110502154328.GG14743@granier.hd.free.fr>
	<19902.54024.358967.444979@gargle.gargle.HOWL>
	<20110502163259.GI14743@granier.hd.free.fr>
	<19922.22109.288864.530108@gargle.gargle.HOWL>
	<20110517120305.GD2142@granier.hd.free.fr>
	<19922.26225.948666.896428@gargle.gargle.HOWL>
	<20110517124757.GG2142@granier.hd.free.fr>
Message-ID: <19922.31602.740562.879134@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>>>>> "Johann" == Johann Lombardi <johann@whamcloud.com> writes:

    Johann> On Tue, May 17, 2011 at 02:13:37PM +0200, rf at q-leap.de
    Johann> wrote:
    >> Which #blocks? The one of the MDT or the one of the whole FS?

    Johann> The #blocks on the MDT.

Ah, OK, that's definitely the case here.

    >> Does that imply I'm doing something wrong?

    Johann> Lustre is just *very* conservative. If you format your MDT
    Johann> with a #blocks/#inodes ratio of 1, you won't get this
    Johann> problem.

I see. Unfortunately, we need that many inodes ...

    >> What is an EA block anyway?

    Johann> The file striping configuration is stored in an extended
    Johann> attribute. Depending on the number of file stripes (can be
    Johann> changed dynamically with lfs setstripe), this extended
    Johann> attribute is stored either in the inode core or in an
    Johann> additional data block. In the latter, you need to alloate
    Johann> one data block for each file creation.

Got it.

    >> We haven't activated any striping.

    Johann> Then you use the default stripe count which is 1 and the
    Johann> extended attribute fits in the inode.  As i said in my first
    Johann> email, we could probably do better and handle this at mkfs
    Johann> time. Andreas' patch
    Johann> (http://review.whamcloud.com/#change,480) introducing
    Johann> --stripe-count-hint should help in this regard.

Great. Thanks a lot for this hint. Do you know whether this will eneter
the 1.8 branch as well?

Roland
