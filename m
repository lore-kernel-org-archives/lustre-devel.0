From: NeilBrown <neilb@suse.com>
Date: Fri, 01 Jun 2018 15:38:15 +1000
Subject: [lustre-devel] [PATCH v2 6/6] staging: lustre: mdc: use large
 xattr buffers for old servers
In-Reply-To: <AE3B1D00-46A8-42FA-9025-2E680C185294@intel.com>
References: <1527603705-30450-1-git-send-email-jsimmons@infradead.org>
 <1527603705-30450-7-git-send-email-jsimmons@infradead.org>
 <20180531165426.GA23414@kroah.com>
 <AE3B1D00-46A8-42FA-9025-2E680C185294@intel.com>
Message-ID: <87po1brrqw.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Dilger, Andreas" <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: James Simmons <jsimmons@infradead.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, "Hammond, John" <john.hammond@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Thu, May 31 2018, Dilger, Andreas wrote:

> On May 31, 2018, at 18:54, Greg Kroah-Hartman <gregkh@linuxfoundation.org> wrote:
>> 
>> On Tue, May 29, 2018 at 10:21:45AM -0400, James Simmons wrote:
>>> From: "John L. Hammond" <john.hammond@intel.com>
>>> 
>>> Pre 2.10.1 MDTs will crash when they receive a listxattr (MDS_GETXATTR
>>> with OBD_MD_FLXATTRLS) RPC for an orphan or dead object. So for
>>> clients connected to these older MDTs, try to avoid sending listxattr
>>> RPCs by making the bulk getxattr (MDS_GETXATTR with OBD_MD_FLXATTRALL)
>>> more likely to succeed and thereby reducing the chances of falling
>>> back to listxattr.
>>> 
>>> +#if LUSTRE_VERSION_CODE < OBD_OCD_VERSION(3, 0, 53, 0)
>> 
>> Why are you adding pointless version checks to mainline?  Please don't
>> add new ones of these, you need to be working on removing the existing
>> ones.
>
> These are not Linux kernel version checks, but rather Lustre release version
> checks.  This allows us to remove workarounds like this in the future when
> they are no longer needed, rather than accumulating cruft forever.  It's like
> the separation of NFSv2 vs NFSv3 vs NFSv4.

It looks very different to the separation of NFSv{2,3,4}.  Those are
conditionally compiled on a whole-file basis.
If we ever want to remove this code it should be hard to search for
occurances of OBD_OCD_VERSION() in the code, we don't need the C
preprocessor to be able to remove them for us.
In this particular example:

+	if (exp->exp_connect_data.ocd_version < OBD_OCD_VERSION(2, 10, 1, 0))
+		min_buf_size = exp->exp_connect_data.ocd_max_easize;

if you want to be able to compile without that one test, you could arrange
that OBD_OSC_VERSION(2, 10, 1, 0) evaluates to 0.
As ocd_version is unsigned, the comparison will always be false, and
the compiler will optimize the code away.

As a general rule, you need a very good reason to have #if or #ifdef in
.c files.  They are usually OK in .h files.

Thanks,
NeilBrown

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180601/78892757/attachment.sig>
