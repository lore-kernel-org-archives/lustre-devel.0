From: Anand Jain <anand.jain@oracle.com>
Date: Thu, 10 Nov 2016 16:16:45 -0000
Subject: [lustre-devel] [PATCH] f2fs: support multiple devices
In-Reply-To: <749156c9-2b3e-4210-a89b-2d664f9d2fc2@gmail.com>
References: <20161109205653.70061-1-jaegeuk@kernel.org>
	<0D1876A8-BB77-4C1A-BE4F-B4A0E81DD4EA@dilger.ca>
	<4ec4d8f2-da23-762d-ba81-12e76ed09793@cn.fujitsu.com>
	<749156c9-2b3e-4210-a89b-2d664f9d2fc2@gmail.com>
Message-ID: <b68b3de1-3036-fce6-b27c-dbf78e6469b8@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Austin S. Hemmelgarn" <ahferroin7@gmail.com>, Qu Wenruo <quwenruo@cn.fujitsu.com>, Andreas Dilger <adilger@dilger.ca>, Jaegeuk Kim <jaegeuk@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Lustre Development <lustre-devel@lists.lustre.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-f2fs-devel@lists.sourceforge.net, linux-btrfs <linux-btrfs@vger.kernel.org>, "Darrick J. Wong" <darrick.wong@oracle.com>



(this is deviating from the subject, sorry about that)

>  Pretty much, if you're using just raid1 mode, without
> compression, on reasonable storage devices, things are rock-solid
> relative to the rest of BTRFS.

IMO, BTRFS volume manger feature is incomplete and there is RAID1
critical bug which affects availability, so its not suitable for 
enterprise solutions yet. However it should be fine in a setup
where dedicated sysadmin and maintenance downtime is a choice.
