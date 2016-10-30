From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Sun, 30 Oct 2016 10:59:59 -0400
Subject: [lustre-devel] [PATCH 22/29] staging: lustre: llite: add
	LL_IOC_FUTIMES_3
In-Reply-To: <1477606323-30325-23-git-send-email-jsimmons@infradead.org>
References: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
	<1477606323-30325-23-git-send-email-jsimmons@infradead.org>
Message-ID: <20161030145959.GA31097@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, "John L. Hammond" <john.hammond@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Thu, Oct 27, 2016 at 06:11:56PM -0400, James Simmons wrote:
> From: John L. Hammond <john.hammond@intel.com>
> 
> Add a new regular file ioctl LL_IOC_FUTIMES_3 similar to futimes() but
> which allows setting of all three inode timestamps. Use this ioctl
> during HSM restore to ensure that the volatile file has the same
> timestamps as the file to be restored. Strengthen sanity-hsm test_24a
> to check that archive, release, and restore do not change a file's
> ctime. Add sanity-hsm test_24e to check that tar will succeed when it
> encounters a HSM released file.

This sounds odd, why is this filesystem the only one that needs a
"special" futimes?  Don't make up new syscalls by making an ioctl
please, make a new syscall if that's what you really need!

thanks,

greg k-h
