From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Thu, 31 May 2018 17:30:24 +0000
Subject: [lustre-devel] [PATCH v2 6/6] staging: lustre: mdc: use large
 xattr buffers for old servers
In-Reply-To: <20180531165426.GA23414@kroah.com>
References: <1527603705-30450-1-git-send-email-jsimmons@infradead.org>
 <1527603705-30450-7-git-send-email-jsimmons@infradead.org>
 <20180531165426.GA23414@kroah.com>
Message-ID: <AE3B1D00-46A8-42FA-9025-2E680C185294@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: James Simmons <jsimmons@infradead.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>, "Hammond, John" <john.hammond@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On May 31, 2018, at 18:54, Greg Kroah-Hartman <gregkh@linuxfoundation.org> wrote:
> 
> On Tue, May 29, 2018 at 10:21:45AM -0400, James Simmons wrote:
>> From: "John L. Hammond" <john.hammond@intel.com>
>> 
>> Pre 2.10.1 MDTs will crash when they receive a listxattr (MDS_GETXATTR
>> with OBD_MD_FLXATTRLS) RPC for an orphan or dead object. So for
>> clients connected to these older MDTs, try to avoid sending listxattr
>> RPCs by making the bulk getxattr (MDS_GETXATTR with OBD_MD_FLXATTRALL)
>> more likely to succeed and thereby reducing the chances of falling
>> back to listxattr.
>> 
>> +#if LUSTRE_VERSION_CODE < OBD_OCD_VERSION(3, 0, 53, 0)
> 
> Why are you adding pointless version checks to mainline?  Please don't
> add new ones of these, you need to be working on removing the existing
> ones.

These are not Linux kernel version checks, but rather Lustre release version
checks.  This allows us to remove workarounds like this in the future when
they are no longer needed, rather than accumulating cruft forever.  It's like
the separation of NFSv2 vs NFSv3 vs NFSv4.

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
