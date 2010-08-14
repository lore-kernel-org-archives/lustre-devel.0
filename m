From: Alexey Lyashkov <alexey.lyashkov@clusterstor.com>
Date: Sat, 14 Aug 2010 11:19:32 +0300
Subject: [Lustre-devel] Caching the root directory
In-Reply-To: <201008121912.o7CJCauK006951@hedwig.cmf.nrl.navy.mil>
References: <201008121912.o7CJCauK006951@hedwig.cmf.nrl.navy.mil>
Message-ID: <BBB6342B-87C9-44DF-830C-4F1FB9E73DC9@clusterstor.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Ken,

I hope attached patches will help in your's work.
two patches resolve some performance degradation with access to dentry.
and one patch avoid sending two extra RPC when client want access to LOV EA,
that strickly need you use use lustre reexport to SMB network, because samba ask xattr for each directory entry when do listing.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: generate-lovea.diff
Type: application/octet-stream
Size: 2538 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20100814/ad013a72/attachment.obj>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: xattr-interop-1.8.diff
Type: application/octet-stream
Size: 2187 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20100814/ad013a72/attachment-0001.obj>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: xattr-interop-HEAD.diff
Type: application/octet-stream
Size: 1322 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20100814/ad013a72/attachment-0002.obj>
-------------- next part --------------
