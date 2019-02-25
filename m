From: Andreas Dilger <adilger@whamcloud.com>
Date: Mon, 25 Feb 2019 18:16:15 +0000
Subject: [lustre-devel] [PATCH 12/37] lustre: remove unused function in
 linkea.
In-Reply-To: <155053494549.24125.14755296858886216830.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494549.24125.14755296858886216830.stgit@noble.brown>
Message-ID: <297EF5E9-FF08-489E-AD60-BAADA85B5A02@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 18, 2019, at 16:09, NeilBrown <neilb@suse.com> wrote:
> 
> Much of the linkea functionality is server-only.
> Keep the parts used on the client, but remove the rest.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>


Reviewed-by: Andreas Dilger <adilger@whamcloud.com>


Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
