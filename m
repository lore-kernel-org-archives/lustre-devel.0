From: rf at q-leap.de <rf@q-leap.de>
Date: Tue, 17 May 2011 13:05:01 +0200
Subject: [Lustre-devel] F/S stats visualisation
In-Reply-To: <20110502163259.GI14743@granier.hd.free.fr>
References: <008a01cc05f8$a6b26840$f41738c0$@com>
	<84D90924-025F-4ABA-89BD-58C43C8FCDD9@ddn.com>
	<20110502154328.GG14743@granier.hd.free.fr>
	<19902.54024.358967.444979@gargle.gargle.HOWL>
	<20110502163259.GI14743@granier.hd.free.fr>
Message-ID: <19922.22109.288864.530108@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>>>>> "Johann" == Johann Lombardi <johann@whamcloud.com> writes:

    Johann> On Mon, May 02, 2011 at 05:51:36PM +0200, rf at q-leap.de
    Johann> wrote:
    >> It seems lfs df -i is indeed buggy showing totally bogus numbers
    >> (see https://bugzilla.lustre.org/show_bug.cgi?id=24489)

    Johann> In this case, you run df on the server directly, so you are
    Johann> comparing statfs information as returned by ext4/ldiskfs
    Johann> with what you get through lustre (i.e. lfs df or df on a
    Johann> lustre client).  Lustre takes for granted that 1 EA block is
    Johann> needed for each inode (conservative approach) and adjusts
    Johann> the total number of inodes accordingly (see
    Johann> fsfilt_ext3_statfs()).  That being said, with large inode
    Johann> support and mkfs.lustre adapting the inode size based on the
    Johann> default stripe count, i am not sure this "adjustment" makes
    Johann> sense any more. We could instead print a warning at mkfs
    Johann> time when the default stripe count cannot fit in the inode
    Johann> core and #inodes > #blocks.

Sorry, but I'm not sure, what I'm supposed to understand from this. It's
a fact that 'lfs df -i ' numbers are bogus. I can fill up the whole
filesystem with as many inodes as df on the server shows (tested this
with the installation mentioned in bug 24489), so the latter inode
number is correct. In my opinion this is a clear bug, and deserves
fixing.

Roland
