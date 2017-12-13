From: Luis de Bethencourt <luisbg@kernel.org>
Date: Wed, 13 Dec 2017 10:22:24 +0000
Subject: [lustre-devel] [PATCH 12/12] staging: lustre: libcfs: discard
 LASSERT_CHECKED
In-Reply-To: <BN6PR1101MB21324C5DC6B6CF85ACD8EF00CB350@BN6PR1101MB2132.namprd11.prod.outlook.com>
References: <151313493380.27582.16490205348451477393.stgit@noble>
 <151313495511.27582.5936753382372514332.stgit@noble>
 <BN6PR1101MB21324C5DC6B6CF85ACD8EF00CB350@BN6PR1101MB2132.namprd11.prod.outlook.com>
Message-ID: <05f81a0a-adda-63d5-b7fe-8e6d2399e643@kernel.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick Farrell <paf@cray.com>, NeilBrown <neilb@suse.com>, Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>

On 12/13/2017 03:33 AM, Patrick Farrell wrote:
> Thanks, Neil - lots of small but nice cleanups.
> 
> Full series acked.
> ________________________________
> From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of NeilBrown <neilb@suse.com>
> Sent: Tuesday, December 12, 2017 9:15:55 PM
> To: Oleg Drokin; James Simmons; Andreas Dilger; Greg Kroah-Hartman
> Cc: linux-kernel at vger.kernel.org; lustre-devel at lists.lustre.org
> Subject: [lustre-devel] [PATCH 12/12] staging: lustre: libcfs: discard LASSERT_CHECKED
> 
> This macro isn't used, and comment is about some earlier version
> of the lustre code that never reached the mainline kernel.
> Just discard it.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---

Thanks Neil! Nice cleanup indeed.

Acked-by: Luis de Bethencourt <luisbg@kernel.org>
