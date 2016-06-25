From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Sat, 25 Jun 2016 14:45:14 -0700
Subject: [lustre-devel] [PATCH v3 15/24] drivers: staging: lustre:
 Replace CURRENT_TIME with current_time()
In-Reply-To: <1466890668-23400-16-git-send-email-deepa.kernel@gmail.com>
References: <1466890668-23400-1-git-send-email-deepa.kernel@gmail.com>
	<1466890668-23400-16-git-send-email-deepa.kernel@gmail.com>
Message-ID: <20160625214514.GA11267@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Deepa Dinamani <deepa.kernel@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, arnd@arndb.de, tglx@linutronix.de, torvalds@linux-foundation.org, tytso@mit.edu, viro@zeniv.linux.org.uk, y2038@lists.linaro.org, lustre-devel@lists.lustre.org

On Sat, Jun 25, 2016 at 02:37:39PM -0700, Deepa Dinamani wrote:
> CURRENT_TIME macro is not appropriate for filesystems as it
> doesn't use the right granularity for filesystem timestamps.
> Use current_time() instead.
> 
> This is also in preparation for the patch that transitions
> vfs timestamps to use 64 bit time and hence make them
> y2038 safe. As part of the effort current_time() will be
> extended to do range checks. Hence, it is necessary for all
> file system timestamps to use current_time().
> 
> Also change format string for prints so that these are valid
> when vfs is transitioned to use 64 bit timestamps.
> 
> Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: lustre-devel at lists.lustre.org
> Acked-by: James Simmons <jsimmons@infradead.org>

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
