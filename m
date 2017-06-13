From: Greg KH <gregkh@linuxfoundation.org>
Date: Tue, 13 Jun 2017 11:25:31 +0200
Subject: [lustre-devel] [PATCH v3] staging: lustre: llite: Replace the
 symbolic file permission mode with the numeric one
In-Reply-To: <20170613062830.GA4822@home>
References: <20170613062830.GA4822@home>
Message-ID: <20170613092531.GF5677@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Jun 13, 2017 at 09:28:30AM +0300, Roman Storozhenko wrote:
> Replaces S_IRWXUGO with 0777. The reason is that symbolic permissions
> considered harmful:
> https://lwn.net/Articles/696229/
> 
> Signed-off-by: Roman Storozhenko <romeusmeister@gmail.com>
> ---
>  drivers/staging/lustre/lustre/llite/dir.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

What changed in this version of the patch?  You always have to say that
below the --- line, like the documentation says to do.

Please fix, make a v4, and resend.

thanks,

greg k-h
