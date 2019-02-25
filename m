From: Andreas Dilger <adilger@whamcloud.com>
Date: Mon, 25 Feb 2019 18:16:21 +0000
Subject: [lustre-devel] [PATCH 26/37] lustre: remove libcfs_debug_vmsg2
In-Reply-To: <155053494624.24125.18162964077735119291.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494624.24125.18162964077735119291.stgit@noble.brown>
Message-ID: <7CFD9DE8-8DC3-429F-BF67-96318718293A@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 18, 2019, at 16:09, NeilBrown <neilb@suse.com> wrote:
> 
> Now that libcfs_debug_vmsg2 has no (external) users, we can remove it.
> It is used to implement libcfs_debug_msg(), so simply move
> the body of the function (suitably modified) into that one caller.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
