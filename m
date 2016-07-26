From: Joe Perches <joe@perches.com>
Date: Tue, 26 Jul 2016 09:59:21 -0700
Subject: [lustre-devel] [PATCH v2 30/58] staging: lustre: create striped
	directory
In-Reply-To: <1469550997-2180-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-31-git-send-email-jsimmons@infradead.org>
	<1469550997-2180-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469552361.1900.214.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>

On Tue, 2016-07-26 at 12:36 -0400, James Simmons wrote:
> From: wang di <di.wang@intel.com>
> 
> 1. client send create request to the master MDT, which
> ? will allocate FIDs and create slaves. for all of slaves.
> 
> 2. Client needs to revalidate slaves during intent getattr
> ???and open request.
> 
> 3. lmv_stripe_md will include attributes(size, nlink etc)
> ???from all of stripe, which will be protected by UPDATE lock.
> ???client needs to merge these attributes when update inode.
> 
> 4. send create request to the MDT where the file is located,
> ???which can help creating master stripe of striped directory.
> 
> Changelog
> 
> v1) Original submitted patch
> 
> v2) fixed lmv_hash_fnv1a function to use do_div64 to fix
> ????__umoddi3 undefined bug on 32 bit platforms.
> 
> Signed-off-by: wang di <di.wang@intel.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3529
> Reviewed-on: http://review.whamcloud.com/7196

Updated?	2 years, 5 months ago

how many of these old changes are yet to be integrated?
