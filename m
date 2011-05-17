From: Johann Lombardi <johann@whamcloud.com>
Date: Tue, 17 May 2011 14:47:57 +0200
Subject: [Lustre-devel] F/S stats visualisation
In-Reply-To: <19922.26225.948666.896428@gargle.gargle.HOWL>
References: <008a01cc05f8$a6b26840$f41738c0$@com>
	<84D90924-025F-4ABA-89BD-58C43C8FCDD9@ddn.com>
	<20110502154328.GG14743@granier.hd.free.fr>
	<19902.54024.358967.444979@gargle.gargle.HOWL>
	<20110502163259.GI14743@granier.hd.free.fr>
	<19922.22109.288864.530108@gargle.gargle.HOWL>
	<20110517120305.GD2142@granier.hd.free.fr>
	<19922.26225.948666.896428@gargle.gargle.HOWL>
Message-ID: <20110517124757.GG2142@granier.hd.free.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, May 17, 2011 at 02:13:37PM +0200, rf at q-leap.de wrote:
> Which #blocks? The one of the MDT or the one of the whole FS?

The #blocks on the MDT.

> Does that imply I'm doing something wrong?

Lustre is just *very* conservative. If you format your MDT with a #blocks/#inodes ratio of 1, you won't get this problem.

> What is an EA block anyway?

The file striping configuration is stored in an extended attribute. Depending on the number of file stripes (can be changed dynamically with lfs setstripe), this extended attribute is stored either in the inode core or in an additional data block. In the latter, you need to alloate one data block for each file creation.

> We haven't activated any striping.

Then you use the default stripe count which is 1 and the extended attribute fits in the inode.
As i said in my first email, we could probably do better and handle this at mkfs time. Andreas' patch (http://review.whamcloud.com/#change,480) introducing --stripe-count-hint should help in this regard.

Johann
