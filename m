From: NeilBrown <neilb@suse.com>
Date: Sat, 02 Jun 2018 10:28:38 +1000
Subject: [lustre-devel] [PATCH] staging: lustre: delete the filesystem
 from the tree.
In-Reply-To: <20180601091133.GA27521@kroah.com>
References: <20180601091133.GA27521@kroah.com>
Message-ID: <87bmcurpzd.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, selinux@tycho.nsa.gov, lustre-devel@lists.lustre.org

On Fri, Jun 01 2018, Greg Kroah-Hartman wrote:

>
> So, let's just delete the whole mess.  Now the lustre developers can go
> off and work in their out-of-tree codebase and not have to worry about
> providing valid changelog entries and breaking their patches up into
> logical pieces.

I find it incredible that anyone would think that not having to "worry
about providing valid changelogs" and not "breaking their patches up
into logic pieces" could ever be seen as a good idea.  I hope that if
lustre development is excluded from mainline for a time, that we can
still maintain the practices that demonstrably work so well.

For the record: I'm not in favor of ejecting this code from mainline.  I
think that the long term result may be that it never comes back, and
will like at least delay the process.
But you must do what you think is best.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180602/30a54852/attachment.sig>
