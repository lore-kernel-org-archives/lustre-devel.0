From: Johann Lombardi <johann@whamcloud.com>
Date: Tue, 17 May 2011 14:03:05 +0200
Subject: [Lustre-devel] F/S stats visualisation
In-Reply-To: <19922.22109.288864.530108@gargle.gargle.HOWL>
References: <008a01cc05f8$a6b26840$f41738c0$@com>
	<84D90924-025F-4ABA-89BD-58C43C8FCDD9@ddn.com>
	<20110502154328.GG14743@granier.hd.free.fr>
	<19902.54024.358967.444979@gargle.gargle.HOWL>
	<20110502163259.GI14743@granier.hd.free.fr>
	<19922.22109.288864.530108@gargle.gargle.HOWL>
Message-ID: <20110517120305.GD2142@granier.hd.free.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, May 17, 2011 at 01:05:01PM +0200, rf at q-leap.de wrote:
> Sorry, but I'm not sure, what I'm supposed to understand from this.

Lustre intentionally reduces the number of inodes returned via lfs df -i when #blocks > #inodes.

> It's a fact that 'lfs df -i ' numbers are bogus.
> I can fill up the whole filesystem with as many inodes as df on the server shows (tested this
> with the installation mentioned in bug 24489), so the latter inode
> number is correct.

That's because your default striping does not require an additional EA block.

Johann
