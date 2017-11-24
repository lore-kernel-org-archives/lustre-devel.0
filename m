From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 24 Nov 2017 16:43:41 +0100
Subject: [lustre-devel] [PATCH 08/10] staging: lustre: lov: use
 list_for_each_entry in lov_obd.c
In-Reply-To: <150933956729.22133.13130557672702877610.stgit@noble>
References: <150933945578.22133.8029060522107378499.stgit@noble>
 <150933956729.22133.13130557672702877610.stgit@noble>
Message-ID: <20171124154341.GA16654@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

On Mon, Oct 30, 2017 at 03:59:27PM +1100, NeilBrown wrote:
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/lov/lov_obd.c |    6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)

I can't take patches with no changelog text at all, sorry.

greg k-h
