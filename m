From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Wed, 29 Nov 2017 10:40:23 +0100
Subject: [lustre-devel] [PATCH 08/10] staging: lustre: lov: use
 list_for_each_entry in lov_obd.c
In-Reply-To: <87r2shwzyf.fsf@notabene.neil.brown.name>
References: <150933945578.22133.8029060522107378499.stgit@noble>
 <150933956729.22133.13130557672702877610.stgit@noble>
 <20171124154341.GA16654@kroah.com>
 <87r2shwzyf.fsf@notabene.neil.brown.name>
Message-ID: <20171129094023.GA7597@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

On Wed, Nov 29, 2017 at 02:01:12PM +1100, NeilBrown wrote:
> Subject: [PATCH] staging: lustre: lov: use list_for_each_entry in lov_obd.c

Why is there a subject line in the body of the text here?  Will git
figure this out correctly?

> Using the *_entry macro simplifies the code slightly.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> 
> Resubmitted with non-empty changelog text.

Did I apply the others?  Can you just send a new series of whatever I
didn't apply so it's obvious for me as to what to do?

thanks,

greg k-h
