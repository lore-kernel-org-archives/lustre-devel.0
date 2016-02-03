From: Greg KH <gregkh@linuxfoundation.org>
Date: Wed, 3 Feb 2016 14:44:32 -0800
Subject: [lustre-devel] [PATCH] staging:lustre:obdclass:linux:convert
	&foo[0] to foo
In-Reply-To: <1453320069-9788-1-git-send-email-bhumirks@gmail.com>
References: <1453320069-9788-1-git-send-email-bhumirks@gmail.com>
Message-ID: <20160203224432.GA4597@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bhumika Goyal <bhumirks@gmail.com>
Cc: oleg.drokin@intel.com, joe@perches.com, andreas.dilger@intel.com, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, lustre-devel@lists.lustre.org

On Thu, Jan 21, 2016 at 01:31:09AM +0530, Bhumika Goyal wrote:
> Replace &foo[0] with foo,to follow Linux coding style.

That's a coding style change?  Why?  They aren't always the same
thing...

thanks,

greg k-h
