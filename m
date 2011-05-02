From: rf at q-leap.de <rf@q-leap.de>
Date: Mon, 2 May 2011 17:51:36 +0200
Subject: [Lustre-devel] F/S stats visualisation
In-Reply-To: <20110502154328.GG14743@granier.hd.free.fr>
References: <008a01cc05f8$a6b26840$f41738c0$@com>
	<84D90924-025F-4ABA-89BD-58C43C8FCDD9@ddn.com>
	<20110502154328.GG14743@granier.hd.free.fr>
Message-ID: <19902.54024.358967.444979@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>>>>> "Johann" == Johann Lombardi <johann@whamcloud.com> writes:

Hi Johann, Ashley, 

    Johann> Hi Ashley, On Fri, Apr 29, 2011 at 12:06:06AM -0700, Ashley
    Johann> Pittman wrote:

    >> What do you think of the blue lines showing total number of
    >> inodes?  It appears to me as though df -i and lfs df -i are
    >> reporting different numbers for this value which I'm not able to
    >> easily explain.

    Johann> The total number of inodes can indeed be different between
    Johann> df (statfs(2)) and lfs df (lustre's ioctl). File creation
    Johann> can also fail with ENOSPC if you run out of objects on the
    Johann> OSTs, although the MDT might still have free
    Johann> inodes. Therefore the number of free inodes as well as the
    Johann> total number of inodes returned through statfs(2) are
    Johann> adjusted if the MDT has more free inodes than the OSTs.  You
    Johann> can check ll_statfs_internal() to see how this is computed.

It seems lfs df -i is indeed buggy showing totally bogus numbers
(see https://bugzilla.lustre.org/show_bug.cgi?id=24489)

Roland
