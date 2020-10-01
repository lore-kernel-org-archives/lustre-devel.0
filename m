From: Andreas Dilger <adilger@whamcloud.com>
Date: Thu, 1 Oct 2020 12:13:33 +0000
Subject: [lustre-devel] Does lustre support reflink?
In-Reply-To: <tencent_30F86FF11DA69E7061A0F031@qq.com>
References: <tencent_30F86FF11DA69E7061A0F031@qq.com>
Message-ID: <2D8A48C4-4563-4944-8FBE-99A086905ED1@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sep 27, 2020, at 00:25, Maixuchang <maixuchang at nobleprog.cn<mailto:maixuchang@nobleprog.cn>> wrote:

Hey? Guys

Does lustre support reflink? Is it under development?

Currently it does not.  There has been some discussion about it might be implemented, but since neither ext4 or ZFS support reflink themselves, this may be complex.  As yet, there are no plans to implement it.

Cheers, Andreas
--
Andreas Dilger
Principal Lustre Architect
Whamcloud






-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20201001/93e27373/attachment.html>
