From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 23 Apr 2018 15:08:37 +0200
Subject: [lustre-devel] [PATCH 00/20] staging: lustre: convert to
 rhashtable
In-Reply-To: <152348312863.12394.11915752362061083241.stgit@noble>
References: <152348312863.12394.11915752362061083241.stgit@noble>
Message-ID: <20180423130837.GA25183@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Thu, Apr 12, 2018 at 07:54:48AM +1000, NeilBrown wrote:
> libcfs in lustre has a resizeable hashtable.
> Linux already has a resizeable hashtable, rhashtable, which is better
> is most metrics. See https://lwn.net/Articles/751374/ in a few days
> for an introduction to rhashtable.
> 
> This series converts lustre to use rhashtable.  This affects several
> different tables, and each is different is various ways.
> 
> There are two outstanding issues.  One is that a bug in rhashtable
> means that we cannot enable auto-shrinking in one of the tables.  That
> is documented as appropriate and should be fixed soon.
> 
> The other is that rhashtable has an atomic_t which counts the elements
> in a hash table.  At least one table in lustre went to some trouble to
> avoid any table-wide atomics, so that could lead to a regression.
> I'm hoping that rhashtable can be enhanced with the option of a
> per-cpu counter, or similar.
> 
> 
> I have enabled automatic shrinking on all tables where it makes sense
> and doesn't trigger the bug.  I have also removed all hints concerning
> min/max size - I cannot see how these could be useful.
> 
> The dump_pgcache debugfs file provided some interesting challenges.  I
> think I have cleaned it up enough so that it all makes sense.  An
> extra pair of eyes examining that code in particular would be
> appreciated.
> 
> This series passes all the same tests that pass before the patches are
> applied.

I've taken the first 4 patches of this series, as they were "obviously
correct".  I'll let you and James argue about the rest.  Feel free to
resend when there's some sort of agreement.

thanks,

greg k-h
