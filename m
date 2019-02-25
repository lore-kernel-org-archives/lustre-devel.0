From: Andreas Dilger <adilger@whamcloud.com>
Date: Mon, 25 Feb 2019 18:16:21 +0000
Subject: [lustre-devel] [PATCH 25/37] lustre: deprecate
 libcfs_debug_vmsg2
In-Reply-To: <155053494619.24125.5150721300459339252.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494619.24125.5150721300459339252.stgit@noble.brown>
Message-ID: <E7A2B4D2-236D-401C-A15F-5B64B441F07A@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 18, 2019, at 16:09, NeilBrown <neilb@suse.com> wrote:
> 
> Since 2.6.36, Linux' vsprintf has supported %pV
> which supports "recursive sprintf" - exactly the task
> that libcfs_debug_vmsg2 aims to provide.
> 
> Instead of calling libcfs_debug_vmsg2(), we can put the fmt and
> args in a 'struct va_format', and pass the address of that structure
> to the "%pV" format.
> 
> So do this to remove all users of libcfs_debug_vmsg2().

Interesting.  This code was always more complex than I'd like.

> Signed-off-by: NeilBrown <neilb@suse.com>

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
