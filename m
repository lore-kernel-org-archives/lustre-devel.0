From: Greg KH <gregkh@linuxfoundation.org>
Date: Tue, 3 Jan 2017 15:15:28 +0100
Subject: [lustre-devel] [PATCH] staging : lustre : Remove braces from
	single-line body.
In-Reply-To: <1482934209-10857-1-git-send-email-khan.tabrez21@gmail.com>
References: <1482934209-10857-1-git-send-email-khan.tabrez21@gmail.com>
Message-ID: <20170103141528.GA10415@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tabrez khan <khan.tabrez21@gmail.com>
Cc: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

On Wed, Dec 28, 2016 at 07:40:09PM +0530, Tabrez khan wrote:
> Remove unnecessary braces from single-line if statement.
> This warning is found using checkpatch.pl.
> 
> Signed-off-by: Tabrez khan <khan.tabrez21@gmail.com>
> ---
>  drivers/staging/lustre/lustre/ptlrpc/import.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

You have sent me 5 patches, with 4 of them having duplicated subject
lines, yet they do different things.  Also, what order am I supposed to
apply these patches in?

Please resend them as a patch series, properly numbered, and with unique
subjects.

thanks,

greg k-h
