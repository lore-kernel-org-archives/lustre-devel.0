From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Sat, 19 Aug 2017 00:07:13 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: lustre: Off by two in
	lmv_fid2path()
In-Reply-To: <20170817154752.GA18912@kroah.com>
References: <20170728144227.uml3x27mqug3ciox@mwanda>
	<alpine.LFD.2.20.1708141559060.14369@casper.infradead.org>
	<20170817154752.GA18912@kroah.com>
Message-ID: <62C696A2-E013-4473-85DB-F378ADF61605@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> On Aug 17, 2017, at 09:47, Greg Kroah-Hartman <gregkh@linuxfoundation.org> wrote:
> 
> On Mon, Aug 14, 2017 at 04:01:17PM +0100, James Simmons wrote:
>> 
>>> We want to concatonate join string one, a '/' character, string two and
>>> then a NUL terminator.  The destination buffer holds ori_gf->gf_pathlen
>>> characters.  The strlen() function returns the number of characters not
>>> counting the NUL terminator.  So we should be adding two extra spaces,
>>> one for the foward slash and one for the NUL.
>>> 
>>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>>> ---
>>> Not tested.  Please review this one carefully.
>> 
>> This is a real bug which is impacting users. The bug is being tracked
>> at https://jira.hpdd.intel.com/browse/LU-9863. It passed our test suite
>> and its being reviewed.
> 
> So what am I supposed to do with this patch?

The patch has been reviewed and you could add them before landing:

Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: frank zago <fzago@cray.com>

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
