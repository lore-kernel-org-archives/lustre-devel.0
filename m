From: Greg KH <gregkh@linuxfoundation.org>
Date: Sun, 11 Jun 2017 09:44:41 +0200
Subject: [lustre-devel] [PATCH v2] staging: lustre: llite: Replace the
 symbolic file permission mode with the numeric one
In-Reply-To: <20170608172541.GA2314@home>
References: <20170608172541.GA2314@home>
Message-ID: <20170611074441.GA30102@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sat, Jun 10, 2017 at 02:48:34PM +0300, Roman Storozhenko wrote:
> Replaces S_IRWXUGO with 0777. The reason is that symbolic permissions
> considered harmful:
> https://lwn.net/Articles/696229/
> 
> The second version of that patch fixes the mistype in the first version.
> There were "0007" in the description instead of correct "0777" value.
> Thanks to Cory Spitz, who pointed out this error here:
> http://lists.lustre.org/pipermail/lustre-devel-lustre.org/2017-June/005726.html

This info doesn't need to be in the patch itself, it should go below the
--- line.

Please fix up and resend.

And also don't make your v3 of the patch with the same exact message-id
of the previous ones.  That's ripe for getting automatically deleted by
mail filters and email clients.

thanks,

greg k-h
