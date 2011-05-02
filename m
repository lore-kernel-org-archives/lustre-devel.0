From: Johann Lombardi <johann@whamcloud.com>
Date: Mon, 2 May 2011 18:32:59 +0200
Subject: [Lustre-devel] F/S stats visualisation
In-Reply-To: <19902.54024.358967.444979@gargle.gargle.HOWL>
References: <008a01cc05f8$a6b26840$f41738c0$@com>
	<84D90924-025F-4ABA-89BD-58C43C8FCDD9@ddn.com>
	<20110502154328.GG14743@granier.hd.free.fr>
	<19902.54024.358967.444979@gargle.gargle.HOWL>
Message-ID: <20110502163259.GI14743@granier.hd.free.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, May 02, 2011 at 05:51:36PM +0200, rf at q-leap.de wrote:
> It seems lfs df -i is indeed buggy showing totally bogus numbers
> (see https://bugzilla.lustre.org/show_bug.cgi?id=24489)

In this case, you run df on the server directly, so you are comparing statfs information as returned by ext4/ldiskfs with what you get through lustre (i.e. lfs df or df on a lustre client).
Lustre takes for granted that 1 EA block is needed for each inode (conservative approach) and adjusts the total number of inodes accordingly (see fsfilt_ext3_statfs()).
That being said, with large inode support and mkfs.lustre adapting the inode size based on the default stripe count, i am not sure this "adjustment" makes sense any more. We could instead print a warning at mkfs time when the default stripe count cannot fit in the inode core and #inodes > #blocks.

Johann

-- 
Johann Lombardi
Whamcloud, Inc.
www.whamcloud.com
