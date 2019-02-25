From: Andreas Dilger <adilger@whamcloud.com>
Date: Mon, 25 Feb 2019 18:16:18 +0000
Subject: [lustre-devel] [PATCH 15/37] lustre: llog_obd: Convert
 loc_refcount to refcount_t
In-Reply-To: <155053494563.24125.5471194386420442456.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494563.24125.5471194386420442456.stgit@noble.brown>
Message-ID: <266DFBB3-84F6-4E10-99FB-0F37636D60AE@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 18, 2019, at 16:09, NeilBrown <neilb@suse.com> wrote:
> 
> Make this a refcount_t for clarity, and also
> use refcount_dec_and_lock() rather than having separate
> lock and dec calls.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
