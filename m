From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 24 Nov 2017 16:44:27 +0100
Subject: [lustre-devel] [PATCH 00/10] staging: lustre: assorted code
 improvements for list manipulations.
In-Reply-To: <150933945578.22133.8029060522107378499.stgit@noble>
References: <150933945578.22133.8029060522107378499.stgit@noble>
Message-ID: <20171124154427.GA19111@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

On Mon, Oct 30, 2017 at 03:59:27PM +1100, NeilBrown wrote:
> There are mostly conversions of list_for_each() to
> list_for_each_entry() and similar.  list_first_entry()
> also makes a few appearances.

I've taken the patches that had a changelog text.

thanks,

greg k-h
