From: Johann Lombardi <johann@whamcloud.com>
Date: Tue, 17 May 2011 15:56:54 +0200
Subject: [Lustre-devel] F/S stats visualisation
In-Reply-To: <19922.31602.740562.879134@gargle.gargle.HOWL>
References: <008a01cc05f8$a6b26840$f41738c0$@com>
	<84D90924-025F-4ABA-89BD-58C43C8FCDD9@ddn.com>
	<20110502154328.GG14743@granier.hd.free.fr>
	<19902.54024.358967.444979@gargle.gargle.HOWL>
	<20110502163259.GI14743@granier.hd.free.fr>
	<19922.22109.288864.530108@gargle.gargle.HOWL>
	<20110517120305.GD2142@granier.hd.free.fr>
	<19922.26225.948666.896428@gargle.gargle.HOWL>
	<20110517124757.GG2142@granier.hd.free.fr>
	<19922.31602.740562.879134@gargle.gargle.HOWL>
Message-ID: <20110517135653.GC14133@granier.hd.free.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, May 17, 2011 at 03:43:14PM +0200, rf at q-leap.de wrote:
> I see. Unfortunately, we need that many inodes ...

Well, in your case, you could just remove the culprit code from fsfilt_ext3_statfs(), as done here:
http://review.whamcloud.com/#patch,sidebyside,480,8,lustre/lvfs/fsfilt_ext3.c

> Great. Thanks a lot for this hint. Do you know whether this will eneter
> the 1.8 branch as well?

I would ask this question in the bugzilla ticket to have an answer from someone from Oracle.

Johann

-- 
Johann Lombardi
Whamcloud, Inc.
www.whamcloud.com
